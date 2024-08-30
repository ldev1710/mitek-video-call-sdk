import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/listen/publisher/room_publisher.dart';
import 'package:mitek_video_call_sdk/listen/publisher/track_publisher.dart';
import 'package:mitek_video_call_sdk/mitek_video_call_sdk.dart';
import 'package:mitek_video_call_sdk/models/queue.dart';
import 'package:mitek_video_call_sdk/models/user.dart';
import 'package:mitek_video_call_sdk/view/video/video_widget.dart';
import 'package:mitek_video_call_sdk_eample/app_log.dart';

class CallingPage extends StatefulWidget {
  CallingPage({
    required this.device,
    required this.user,
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
    initTest();
  }

  bool enableCamera = true;
  bool enableMicro = true;

  VideoTrack? _localVideoTrack;

  Future<void> initTest() async {
    final room = await MTVideoCallPlugin.instance.startVideoCall(
      user: widget.user,
      queue: widget.queue,
    );
    final isCnSuccess = await MTVideoCallPlugin.instance
        .connect2Room(queue: widget.queue, user: widget.user, room: room);
    await MTVideoCallPlugin.instance.setInputVideo(widget.device);
    _localVideoTrack = MTVideoCallPlugin.instance.localVideoTrack;
    setState(() {
      isLaunching = false;
    });
    print("isCnSuccess: $isCnSuccess");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: isLaunching
              ? const CircularProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: size.height * 0.7,
                      child: MTVideoRender(_localVideoTrack!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              enableCamera = !enableCamera;
                              MTVideoCallPlugin.instance.enableVideo(enableCamera);
                            });
                          },
                          icon: Icon(
                            enableCamera ? Icons.videocam : Icons.videocam_off,
                          ),
                          iconSize: 42,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              enableMicro = !enableMicro;
                              MTVideoCallPlugin.instance.enableMicrophone(enableMicro);
                            });
                          },
                          icon: Icon(
                            enableMicro ? Icons.mic_rounded : Icons.mic_off,
                          ),
                          iconSize: 42,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          await MTVideoCallPlugin.instance.disconnectVideoCall();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
    MTVideoCallPlugin.instance.removeMTRoomEventListener(this);
    Navigator.pop(context);
  }

  @override
  void onParticipantConnectedRoom(RemoteParticipant participant) {
    // TODO: implement onParticipantConnectedRoom
    super.onParticipantConnectedRoom(participant);
    AppLog.logI("onParticipantConnectedRoom: $participant");
  }

  @override
  void onParticipantDisconnectedRoom(RemoteParticipant participant) async {
    // TODO: implement onParticipantDisconnectedRoom
    super.onParticipantDisconnectedRoom(participant);
    AppLog.logI("onParticipantDisconnectedRoom: $participant");
    await MTVideoCallPlugin.instance.disconnectVideoCall();
  }

  @override
  void onLocalTrackPublished(
      LocalParticipant localParticipant, LocalTrackPublication<LocalTrack> publication) {
    // TODO: implement onLocalTrackPublished
    super.onLocalTrackPublished(localParticipant, publication);
    AppLog.logI("onLocalTrackPublished: $localParticipant");
    // setState(() {
    //   final localParticipantTracks = localParticipant.videoTrackPublications;
    //   for (var t in localParticipantTracks) {
    //     if (t.isScreenShare) {
    //       _localTrack = t.participant.videoTrackPublications
    //           .where((element) {
    //             AppLog.logI("${element.source}");
    //             return element.source == TrackSource.camera;
    //           })
    //           .firstOrNull
    //           ?.track as VideoTrack;
    //     }
    //   }
    // });
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
  }

  @override
  void onTrackUnSubscribed(
      RemoteTrackPublication<RemoteTrack> publication, RemoteParticipant participant, Track track) {
    // TODO: implement onTrackUnSubscribed
    super.onTrackUnSubscribed(publication, participant, track);
    AppLog.logI("onTrackUnSubscribed: $participant");
  }
}
