library mitek_video_call_sdk;

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/listen/publisher/room_publisher.dart';
import 'package:mitek_video_call_sdk/listen/publisher/track_publisher.dart';
import 'package:mitek_video_call_sdk/models/queue.dart';
import 'package:mitek_video_call_sdk/models/room.dart';
import 'package:mitek_video_call_sdk/models/user.dart';
import 'package:mitek_video_call_sdk/utils/constants.dart';
import 'package:mitek_video_call_sdk/utils/log.dart';
import 'package:mitek_video_call_sdk/utils/observing.dart';

part 'network/mitek_network.dart';

class MTVideoCallPlugin {
  static final MTVideoCallPlugin _instance = MTVideoCallPlugin._internal();
  static MTVideoCallPlugin get instance => _instance;
  MTVideoCallPlugin._internal();
  factory MTVideoCallPlugin() {
    return _instance;
  }
  bool _isAuthenticated = false;
  bool _isVideoCalling = false;
  final List<MTRoomEventListener> _roomListener = [];
  final List<MTTrackListener> _trackListener = [];
  String? _wssUrl;
  EventsListener<RoomEvent>? _roomCoreListener;
  LocalAudioTrack? _audioTrack;
  LocalVideoTrack? _videoTrack;
  LocalVideoTrack? get localVideoTrack => _videoTrack;
  LocalAudioTrack? get localAudioTrack => _audioTrack;
  MediaDevice? _selectedVideoDevice;
  MediaDevice? _selectedAudioDevice;
  List<MediaDevice> _audioInputs = [];
  List<MediaDevice> _videoInputs = [];
  String? _videoCallToken;
  final _MTNetwork _instanceNetwork = _MTNetwork();
  List<MTQueue> _queues = [];
  Room? _room;

  List<MTRoomEventListener> get roomListener => _roomListener;
  List<MTTrackListener> get trackListener => _trackListener;
  Room? get currRoom => _room;

  /// Listen: onDeviceChange, onParticipantAttended, onDisconnectedRoom, onConnectedRoom
  /// Listen: onParticipantPublishAudioTrack, onParticipantPublishVideoTrack

  /// Authenticating with MITEK system using api key was provided
  Future<bool> authenticate({required String apiKey}) async {
    _instanceNetwork.setApiKey(apiKey: apiKey);
    final response = await _instanceNetwork.get(MTNetworkConstant.authenticate);
    _isAuthenticated = response.statusCode == 200;
    if (_isAuthenticated) {
      _instanceNetwork.setApiKey(apiKey: apiKey);
    } else {
      return false;
    }
    String decodeBase64 = utf8.decode(base64.decode(response.data['data']));
    Map<String, dynamic> mapData = json.decode(decodeBase64);
    _queues = List<MTQueue>.from(mapData['list_queues'].map((e) => MTQueue.fromJson(e)));
    _wssUrl = mapData['wss_url'];
    Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
    List<MediaDevice> devices = await Hardware.instance.enumerateDevices();
    _loadDevices(devices);
    return _isAuthenticated;
  }

  /// Getting list language supported from MITEK system
  Future<List<MTQueue>> getQueues() async {
    _isValid();
    return _queues;
  }

  void enableVideo(bool enable) {
    _room!.localParticipant!.setCameraEnabled(enable);
  }

  void enableMicrophone(bool enable) {
    _room!.localParticipant!.setMicrophoneEnabled(enable);
  }

  List<MediaDevice> getDeviceAudioInput() {
    _isValid();
    return _audioInputs;
  }

  List<MediaDevice> getDeviceVideoInput() {
    _isValid();
    return _videoInputs;
  }

  Future<void> setInputVideo(MediaDevice? inputVideo) async {
    _selectedVideoDevice = inputVideo;
  }

  Future<void> setInputAudio(MediaDevice inputAudio) async {
    _selectedAudioDevice = inputAudio;
  }

  /// Call this function before call 'startVideoCall' function
  /// It will create an session video call in MITEK system
  Future<MTRoom> startVideoCall({required MTUser user, required MTQueue queue}) async {
    _isValid();
    Map<String, dynamic> body = {
      "queue_num": queue.queueNum,
      "created_from": "widget",
      "created_name": user.name,
    };
    final response = await _instanceNetwork.post(
      MTNetworkConstant.createRoom,
      data: body,
    );
    final room = MTRoom.fromJson(response.data['data']);
    return room;
  }

  /// Call this function to start video call to MITEK system
  Future<bool> connect2Room({
    required MTQueue queue,
    required MTUser user,
    required MTRoom room,
  }) async {
    _isValid();
    Map<String, dynamic> body = {
      "queue_num": queue.queueNum,
      "queue_name": queue.queueName,
      "created_from": "widget",
      "created_name": user.name,
      "room_id": room.roomId,
      "room_name": room.roomName,
    };
    final response = await _instanceNetwork.post(
      MTNetworkConstant.createConnection,
      data: body,
    );
    _videoCallToken = response.data['data'];
    log("_videoCallToken: $_videoCallToken");
    _room = Room();
    _videoTrack = await LocalVideoTrack.createCameraTrack(
      CameraCaptureOptions(
        deviceId: _selectedVideoDevice != null
            ? _selectedVideoDevice!.deviceId
            : _videoInputs.first.deviceId,
      ),
    );
    _roomCoreListener = _room!.createListener();
    _setUpListener();
    await _videoTrack!.start();
    await _room!.connect(_wssUrl!, _videoCallToken ?? "");
    await _room!.localParticipant?.publishVideoTrack(_videoTrack!);
    await _room!.localParticipant?.setCameraEnabled(true);
    await _room!.localParticipant?.setMicrophoneEnabled(true);
    _isVideoCalling = true;
    return true;
  }

  /// Call this function to end and disconnect video call
  Future<bool> disconnectVideoCall() async {
    _isValid();
    if (!_isVideoCalling) {
      MTLog.logI(message: "You don't have video calling yet!");
      return false;
    }
    await _room!.disconnect();
    _isVideoCalling = false;
    return true;
  }

  bool _isValid() {
    if (!_isAuthenticated) {
      throw Exception("Please authenticate before!");
    }
    return true;
  }

  Future<void> _changeLocalAudioTrack() async {
    if (_audioTrack != null) {
      await _audioTrack!.stop();
      _audioTrack = null;
    }

    if (_selectedAudioDevice != null) {
      _audioTrack = await LocalAudioTrack.create(AudioCaptureOptions(
        deviceId: _selectedAudioDevice!.deviceId,
      ));
      await _audioTrack!.start();
    }
  }

  Future<void> changeVideoTrack(MediaDevice select) async {
    _selectedVideoDevice = select;

    if (_selectedVideoDevice != null && _isVideoCalling) {
      await _room!.setVideoInputDevice(_selectedVideoDevice!);
    }
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();
  }

  void _setUpListener() {
    _roomCoreListener!
      ..on<ParticipantConnectedEvent>((event) async {
        MTLog.logI(message: "ParticipantDisconnectedEvent ${event.participant.toString()}");
        MTObserving.observingParticipantConnected(event);
      })
      ..on<RoomDisconnectedEvent>((event) async {
        MTLog.logI(message: "RoomDisconnectedEvent ${event.reason.toString()}");
        try {
          MTObserving.observingRoomDisconnected(event.reason);
        } catch (e) {}
      })
      ..on<RoomConnectedEvent>((event) async {
        MTLog.logI(message: "RoomConnectedEvent ${event.room.toString()}");
        try {
          MTObserving.observingRoomConnected(event);
        } catch (e) {}
      })
      ..on<TrackMutedEvent>((event) {
        MTLog.logI(message: "TrackMutedEvent ${event.participant.toString()}");
        if (event.participant is RemoteParticipant) MTObserving.observingRemoteMutedTrack(event);
      })
      ..on<TrackUnmutedEvent>((event) {
        MTLog.logI(message: "TrackUnmutedEvent ${event.participant.toString()}");
        if (event.participant is RemoteParticipant) MTObserving.observingRemoteUnMutedTrack(event);
      })
      ..on<ParticipantEvent>((event) {
        MTLog.logI(message: "ParticipantEvent ${event.runtimeType}");
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        MTLog.logI(message: "ParticipantDisconnectedEvent ${event.participant.toString()}");
        MTObserving.observingParticipantDisconnected(event);
      })
      ..on<LocalTrackPublishedEvent>((event) {
        MTLog.logI(message: "LocalTrackPublishedEvent ${event.publication.toString()}");
        MTObserving.observingLocalTrackPublished(event);
      })
      ..on<LocalTrackUnpublishedEvent>((event) {
        MTLog.logI(message: "LocalTrackUnpublishedEvent ${event.publication.toString()}");
        MTObserving.observingLocalTrackUnPublished(event);
      })
      ..on<TrackSubscribedEvent>((event) {
        MTLog.logI(message: "TrackSubscribedEvent ${event.track.toString()}");
        MTObserving.observingTrackSubscribed(event);
      })
      ..on<TrackUnsubscribedEvent>((event) {
        MTLog.logI(message: "TrackUnsubscribedEvent ${event.track.toString()}");
        MTObserving.observingTrackUnsubscribed(event);
      })
      ..on<ParticipantMetadataUpdatedEvent>((event) {
        MTLog.logI(message: "ParticipantMetadataUpdatedEvent ${event.metadata}");
      })
      ..on<RoomMetadataChangedEvent>((event) {
        MTLog.logI(message: "RoomMetadataChangedEvent ${event.metadata}");
      })
      ..on<DataReceivedEvent>((event) {
        MTLog.logI(message: "DataReceivedEvent $event");
        MTObserving.observingDataReceive(event);
      });
  }

  void removeMTRoomEventListener(MTRoomEventListener listener) {
    _roomListener.remove(listener);
  }

  void addMTRoomEventListener(MTRoomEventListener listener) {
    _roomListener.add(listener);
  }

  void removeMTTrackEventListener(MTTrackListener listener) {
    _trackListener.remove(listener);
  }

  void addMTTrackEventListener(MTTrackListener listener) {
    _trackListener.add(listener);
  }
}
