import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/listen/publisher/room_publisher.dart';
import 'package:mitek_video_call_sdk/listen/publisher/track_publisher.dart';
import 'package:mitek_video_call_sdk/mitek_video_call_sdk.dart';
import 'package:mitek_video_call_sdk/models/queue.dart';
import 'package:mitek_video_call_sdk/models/user.dart';
import 'package:mitek_video_call_sdk/view/video/video_widget.dart';
import 'package:mitek_video_call_sdk_eample/app_log.dart';
import 'package:mitek_video_call_sdk_eample/pages/widget/local_video.dart';
import 'package:pip_view/pip_view.dart';

class CallingPage extends StatefulWidget {
  CallingPage({
    required this.user,
    required this.device,
    required this.queue,
  });

  MTUser user;
  MTQueue queue;
  MediaDevice device;

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> with MTRoomEventListener, MTTrackListener {
  bool isLaunching = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MTVideoCallPlugin.instance.addMTRoomEventListener(this);
    MTVideoCallPlugin.instance.addMTTrackEventListener(this);
    initTest();
  }

  bool enableCamera = true;
  bool enableMicro = true;
  bool isRemoteEnableCamera = false;
  bool isRemoteEnableMic = false;

  VideoTrack? _remoteVideoTrack;
  late MediaDevice inputVideo;
  late Timer _timer;
  int countTime = 0;

  Future<void> initTest() async {
    inputVideo = widget.device;
    final room = await MTVideoCallPlugin.instance.startVideoCall(
      user: widget.user,
      queue: widget.queue,
    );
    await MTVideoCallPlugin.instance.setInputVideo(inputVideo);
    final isCnSuccess = await MTVideoCallPlugin.instance
        .connect2Room(queue: widget.queue, user: widget.user, room: room);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countTime++;
      });
      if (countTime == 30 && _remoteVideoTrack == null) {
        _timer.cancel();
        MTVideoCallPlugin.instance.disconnectVideoCall();
      }
    });
    setState(() {
      isLaunching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: RawPIPView(
        floatingWidth: size.width * 0.4,
        floatingHeight: size.height * 0.3,
        topWidget: isLaunching
            ? const Center(child: CircularProgressIndicator())
            : enableCamera
                ? LocalVideoWidget(
                    videoTrack: MTVideoCallPlugin.instance.localVideoTrack!,
                    backgroundWidget: widget,
                  )
                : Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.videocam_off,
                      color: Colors.black,
                      size: 48,
                    ),
                  ),
        bottomWidget: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            _remoteVideoTrack != null
                ? isRemoteEnableCamera
                    ? MTVideoRender(
                        _remoteVideoTrack!,
                        fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        mirrorMode: VideoViewMirrorMode.off,
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.videocam_off,
                          color: Colors.black,
                          size: 78,
                        ),
                      )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 78,
                      ),
                      Text(
                        "${(countTime ~/ 60).toString().padLeft(2, '0')}:${(countTime % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        "Connecting...",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
            Positioned(
              top: 12,
              left: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isRemoteEnableMic)
                    Container(
                      margin: const EdgeInsets.only(left: 24, top: 32),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.mic_off,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ctnWithOp(
                    onPressed: () {
                      setState(() {
                        inputVideo = MTVideoCallPlugin.instance
                            .getDeviceVideoInput()
                            .where((element) => element.deviceId != inputVideo.deviceId)
                            .first;
                        MTVideoCallPlugin.instance.changeLocalVideoTrack(inputVideo);
                      });
                    },
                    iconData: Icons.cameraswitch,
                    isSelected: false,
                  ),
                  ctnWithOp(
                    onPressed: () {
                      setState(() {
                        enableCamera = !enableCamera;
                        MTVideoCallPlugin.instance.enableVideo(enableCamera);
                      });
                    },
                    iconData: enableCamera ? Icons.videocam : Icons.videocam_off,
                    isSelected: !enableCamera,
                  ),
                  ctnWithOp(
                    onPressed: () {
                      setState(() {
                        enableMicro = !enableMicro;
                        MTVideoCallPlugin.instance.enableMicrophone(enableMicro);
                      });
                    },
                    iconData: enableMicro ? Icons.mic_rounded : Icons.mic_off,
                    isSelected: !enableMicro,
                  ),
                  InkWell(
                    onTap: () async {
                      await MTVideoCallPlugin.instance.disconnectVideoCall();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateRemoteTrack(RemoteParticipant participant) {
    setState(() {
      isRemoteEnableCamera = !participant.videoTrackPublications.first.muted;
      isRemoteEnableMic = !participant.audioTrackPublications.first.muted;
    });
  }

  Widget ctnWithOp({
    required void Function() onPressed,
    required IconData iconData,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: isSelected ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  @override
  void onConnectedRoom(Room room, String? metaData) {
    // TODO: implement onConnectedRoom
    super.onConnectedRoom(room, metaData);
    AppLog.logI("onConnectedRoom: $room");
  }

  @override
  void onDisconnectedRoom(DisconnectReason? reason) async {
    // TODO: implement onDisconnectedRoom
    super.onDisconnectedRoom(reason);
    AppLog.logI("onDisconnectedRoom: $reason");
    _timer.cancel();
    MTVideoCallPlugin.instance.removeMTRoomEventListener(this);
    MTVideoCallPlugin.instance.removeMTTrackEventListener(this);
    Navigator.pop(context);
  }

  @override
  void onParticipantConnectedRoom(RemoteParticipant participant) {
    // TODO: implement onParticipantConnectedRoom
    super.onParticipantConnectedRoom(participant);
    AppLog.logI("onParticipantConnectedRoom: $participant");
    _timer.cancel();
  }

  @override
  void onParticipantDisconnectedRoom(RemoteParticipant participant) async {
    // TODO: implement onParticipantDisconnectedRoom
    super.onParticipantDisconnectedRoom(participant);
    AppLog.logI("onParticipantDisconnectedRoom: $participant");
    await MTVideoCallPlugin.instance.disconnectVideoCall();
  }

  @override
  void onRemoteUnMutedTrack(
      TrackPublication<Track> publication, Participant<TrackPublication<Track>> participant) {
    // TODO: implement onRemoteUnMutedTrack
    super.onRemoteUnMutedTrack(publication, participant);
    print("onRemoteUnMutedTrack: Called");
    updateRemoteTrack(participant as RemoteParticipant);
  }

  @override
  void onRemoteMutedTrack(TrackPublication<Track> publication, Participant participant) {
    // TODO: implement onRemoteMutedTrack
    super.onRemoteMutedTrack(publication, participant);
    print("onRemoteMutedTrack: Called");
    updateRemoteTrack(participant as RemoteParticipant);
  }

  @override
  void onLocalTrackPublished(
      LocalParticipant localParticipant, LocalTrackPublication<LocalTrack> publication) {
    // TODO: implement onLocalTrackPublished
    super.onLocalTrackPublished(localParticipant, publication);
    AppLog.logI("onLocalTrackPublished: $localParticipant");
    setState(() {});
  }

  @override
  void onLocalTrackUnPublished(
      LocalParticipant localParticipant, LocalTrackPublication<LocalTrack> publication) {
    // TODO: implement onLocalTrackUnPublished
    super.onLocalTrackUnPublished(localParticipant, publication);
    AppLog.logI("onLocalTrackUnPublished: $localParticipant");
  }

  @override
  void onReceiveData(List<int> data, RemoteParticipant? participant, String? topic) {
    // TODO: implement onReceiveData
    super.onReceiveData(data, participant, topic);
    AppLog.logI("onReceiveData: $data");
  }

  @override
  void onTrackSubscribed(
      RemoteTrackPublication<RemoteTrack> publication, RemoteParticipant participant, Track track) {
    // TODO: implement onTrackSubscribed
    super.onTrackSubscribed(publication, participant, track);
    AppLog.logI("onTrackSubscribed: $participant");
    setState(() {
      if (publication.source == TrackSource.camera) {
        _remoteVideoTrack = publication.track as VideoTrack?;
      }
      updateRemoteTrack(participant);
    });
  }

  @override
  void onTrackUnSubscribed(
      RemoteTrackPublication<RemoteTrack> publication, RemoteParticipant participant, Track track) {
    // TODO: implement onTrackUnSubscribed
    super.onTrackUnSubscribed(publication, participant, track);
    AppLog.logI("onTrackUnSubscribed: $participant");
  }
}
