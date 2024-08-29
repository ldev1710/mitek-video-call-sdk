library mitek_video_call_sdk;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/models/queue.dart';
import 'package:mitek_video_call_sdk/models/room.dart';
import 'package:mitek_video_call_sdk/models/user.dart';
import 'package:mitek_video_call_sdk/utils/constants.dart';
import 'package:mitek_video_call_sdk/utils/log.dart';

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
  bool _isEnableVideo = false;
  bool _isEnableAudio = false;
  String? _wssUrl;
  String? _socketUrl;
  EventsListener<RoomEvent>? _roomListener;
  LocalAudioTrack? _audioTrack;
  LocalVideoTrack? _videoTrack;
  MediaDevice? _selectedVideoDevice;
  MediaDevice? _selectedAudioDevice;
  List<MediaDevice> _audioInputs = [];
  List<MediaDevice> _videoInputs = [];
  String? _videoCallToken;
  final _MTNetwork _instanceNetwork = _MTNetwork();
  List<MTQueue> _queues = [];
  Room? _room;

  /// Listen: onDeviceChange, onParticipantAttended, onDisconnectedRoom, onConnectedRoom
  /// Listen: onParticipantPublishAudioTrack, onParticipantPublishVideoTrack

  /// Authenticating with MITEK system using api key was provided
  Future<bool> authenticate({required String apiKey}) async {
    final response = await _instanceNetwork.get(MTNetworkConstant.authenticate);
    _isAuthenticated = response.statusCode == 200;
    if (_isAuthenticated) {
      _instanceNetwork.setApiKey(apiKey: apiKey);
    }
    String decodeBase64 = utf8.decode(base64.decode(response.data['data']));
    Map<String, dynamic> mapData = json.decode(decodeBase64);
    _queues = mapData['list_queues'].map((e) => MTQueue.fromJson(e));
    _wssUrl = mapData['wss_url'];
    _socketUrl = mapData['socket_url'];
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

  List<MediaDevice> getDeviceAudioInput() {
    _isValid();
    return _audioInputs;
  }

  List<MediaDevice> getDeviceVideoInput() {
    _isValid();
    return _videoInputs;
  }

  void setInputVideo(MediaDevice inputVideo) async {
    _selectedVideoDevice = inputVideo;
    await _changeLocalVideoTrack();
  }

  void setInputAudio(MediaDevice inputAudio) async {
    _selectedAudioDevice = inputAudio;
    await _changeLocalAudioTrack();
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
      MTNetworkConstant.initVideoCall,
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
    _room = Room();
    _roomListener = _room!.createListener();
    _setUpListener();
    await _room!.connect(_wssUrl!, _videoCallToken ?? "");
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
    return true;
  }

  bool _isValid() {
    if (!_isAuthenticated) {
      throw Exception("Please authenticate before!");
    }
    return true;
  }

  Future<void> enableVideo(bool value) async {
    _isEnableVideo = value;
    if (!_isEnableVideo) {
      await _videoTrack?.stop();
      _videoTrack = null;
    } else {
      await _changeLocalVideoTrack();
    }
  }

  Future<void> enableAudio(bool value) async {
    _isEnableAudio = value;
    if (!_isEnableAudio) {
      await _audioTrack?.stop();
      _audioTrack = null;
    } else {
      await _changeLocalAudioTrack();
    }
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

  Future<void> _changeLocalVideoTrack() async {
    if (_videoTrack != null) {
      await _videoTrack!.stop();
      _videoTrack = null;
    }

    if (_selectedVideoDevice != null) {
      _videoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          deviceId: _selectedVideoDevice!.deviceId,
        ),
      );
      await _videoTrack!.start();
    }
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();
  }

  void _setUpListener() {
    _roomListener!
      ..on<RoomDisconnectedEvent>((event) async {
        MTLog.logI(message: "RoomDisconnectedEvent ${event.reason.toString()}");
      })
      ..on<ParticipantConnectedEvent>((event) {
        MTLog.logI(message: "ParticipantConnectedEvent ${event.participant.toString()}");
      })
      ..on<LocalTrackPublishedEvent>((event) {
        MTLog.logI(message: "LocalTrackPublishedEvent ${event.publication.toString()}");
      })
      ..on<LocalTrackUnpublishedEvent>((event) {
        MTLog.logI(message: "LocalTrackUnpublishedEvent ${event.publication.toString()}");
      })
      ..on<TrackSubscribedEvent>((event) {
        MTLog.logI(message: "TrackSubscribedEvent ${event.track.toString()}");
      })
      ..on<TrackUnsubscribedEvent>((event) {
        MTLog.logI(message: "TrackUnsubscribedEvent ${event.track.toString()}");
      })
      ..on<ParticipantMetadataUpdatedEvent>((event) {
        MTLog.logI(message: "ParticipantMetadataUpdatedEvent ${event.metadata}");
      })
      ..on<RoomMetadataChangedEvent>((event) {
        MTLog.logI(message: "RoomMetadataChangedEvent ${event.metadata}");
      })
      ..on<DataReceivedEvent>((event) {
        String decoded = 'Failed to decode';
        try {
          decoded = utf8.decode(event.data);
        } catch (err) {
          print('Failed to decode: $err');
        }
        MTLog.logI(message: "DataReceivedEvent $decoded");
      });
  }
}
