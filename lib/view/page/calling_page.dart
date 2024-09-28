import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/listen/publisher/room_publisher.dart';
import 'package:mitek_video_call_sdk/listen/publisher/track_publisher.dart';
import 'package:mitek_video_call_sdk/mitek_video_call_sdk.dart';
import 'package:mitek_video_call_sdk/models/queue.dart';
import 'package:mitek_video_call_sdk/models/user.dart';
import 'package:mitek_video_call_sdk/view/widget/grid_track.dart';
import 'package:mitek_video_call_sdk/view/widget/local_video.dart';
import 'package:pip_view/pip_view.dart';

class YourPageState extends StatefulWidget {
  const YourPageState({super.key});

  @override
  State<YourPageState> createState() => _YourPageStateState();
}

class _YourPageStateState extends State<YourPageState> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class MTCallingPage extends StatefulWidget {
  MTCallingPage({
    super.key,
    required this.user,
    required this.device,
    required this.queue,
  });

  MTUser user;
  MTQueue queue;
  MediaDevice device;

  @override
  State<MTCallingPage> createState() => _MTCallingPageState();
}

class _MTCallingPageState extends State<MTCallingPage>
    with MTRoomEventListener, MTTrackListener {
  bool isLaunching = true;
  final player = AudioPlayer();
  bool enableCamera = true;
  bool enableMicro = true;
  bool isRemoteEnableCamera = false;
  bool isRemoteEnableMic = false;
  bool participantJoined = false;
  List<Participant> participant = [];
  late MediaDevice inputVideo;
  late Timer _timer;
  int countTime = 0;
  bool isFloating = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MTVideoCallPlugin.instance.addMTRoomEventListener(this);
    MTVideoCallPlugin.instance.addMTTrackEventListener(this);
    initCalling();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (widget.user.name.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Full name of user can not be empty!",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.blue,
                child: const Text(
                  "Back",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        onPopInvoked: (willPop) {
          setState(() => isFloating = true);
        },
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            RawPIPView(
              floatingWidth: size.width * 0.4,
              floatingHeight: size.height * 0.3,
              onTapTopWidget: isFloating ? stopFloating : null,
              topWidget: isLaunching //
                  ? const Center(child: CircularProgressIndicator())
                  : enableCamera
                      ? MTVideoCallPlugin.instance.localVideoTrack != null
                          ? IgnorePointer(
                              ignoring: isFloating,
                              child: LocalVideoWidget(
                                videoTrack:
                                    MTVideoCallPlugin.instance.localVideoTrack!,
                                backgroundWidget: widget,
                                isFloating: isFloating,
                                onPop: () {
                                  setState(() => isFloating = true);
                                },
                              ),
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
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
              bottomWidget: isFloating
                  ? participantJoined &&
                          MTVideoCallPlugin
                                  .instance.currRoom!.remoteParticipants.values
                                  .toList()
                                  .firstOrNull !=
                              null
                      ? GridTrack(
                          lcPart: MTVideoCallPlugin
                              .instance.currRoom!.localParticipant!,
                          rmPart: MTVideoCallPlugin
                              .instance.currRoom!.remoteParticipants.values
                              .toList()
                              .first,
                        )
                      : Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                        )
                  : null,
            ),
            Positioned(
              bottom: 24,
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
                            .where((element) =>
                                element.deviceId != inputVideo.deviceId)
                            .first;
                        MTVideoCallPlugin.instance.changeVideoTrack(inputVideo);
                      });
                    },
                    iconData: Icons.sync,
                    isSelected: false,
                  ),
                  ctnWithOp(
                    onPressed: () {
                      setState(() {
                        enableCamera = !enableCamera;
                        MTVideoCallPlugin.instance.enableVideo(enableCamera);
                      });
                    },
                    iconData:
                        enableCamera ? Icons.videocam : Icons.videocam_off,
                    isSelected: !enableCamera,
                  ),
                  ctnWithOp(
                    onPressed: () {
                      setState(() {
                        enableMicro = !enableMicro;
                        MTVideoCallPlugin.instance
                            .enableMicrophone(enableMicro);
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

  Future<void> initCalling() async {
    if (widget.user.name.isEmpty) return;
    inputVideo = widget.device;
    final room = await MTVideoCallPlugin.instance.startVideoCall(
      user: widget.user,
      queue: widget.queue,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        countTime++;
      });
      if (countTime == room.emptyTimeOut && !participantJoined) {
        await player.play(UrlSource(widget.queue.musicTimeOutUrl));
      }
    });
    setState(() {
      isLaunching = false;
      isFloating = true;
    });
    player.onPlayerComplete.listen((event) async {
      if (countTime >= room.emptyTimeOut && !participantJoined) {
        _timer.cancel();
        MTVideoCallPlugin.instance.disconnectVideoCall();
      }
    });
    await MTVideoCallPlugin.instance.setInputVideo(inputVideo);
    final isCnSuccess = await MTVideoCallPlugin.instance
        .connect2Room(queue: widget.queue, user: widget.user, room: room);
    await player.setVolume(1);
    await player.play(UrlSource(widget.queue.musicHoldUrl));
  }

  void stopFloating() {
    setState(() => isFloating = false);
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
  }

  @override
  void onDisconnectedRoom(DisconnectReason? reason) async {
    // TODO: implement onDisconnectedRoom
    super.onDisconnectedRoom(reason);
    MTVideoCallPlugin.instance.removeMTRoomEventListener(this);
    MTVideoCallPlugin.instance.removeMTTrackEventListener(this);
    _timer.cancel();
    await player.stop();
    Navigator.pop(context);
  }

  @override
  void onParticipantConnectedRoom(RemoteParticipant participant) async {
    // TODO: implement onParticipantConnectedRoom
    super.onParticipantConnectedRoom(participant);
    await player.stop();
    setState(() {
      _timer.cancel();
      participantJoined = true;
    });
  }

  @override
  void onParticipantDisconnectedRoom(RemoteParticipant participant) async {
    // TODO: implement onParticipantDisconnectedRoom
    super.onParticipantDisconnectedRoom(participant);
    await MTVideoCallPlugin.instance.disconnectVideoCall();
  }

  @override
  void onRemoteUnMutedTrack(TrackPublication<Track> publication,
      Participant<TrackPublication<Track>> participant) {
    // TODO: implement onRemoteUnMutedTrack
    super.onRemoteUnMutedTrack(publication, participant);
    print("onRemoteUnMutedTrack: Called");
    setState(() {});
  }

  @override
  void onRemoteMutedTrack(
      TrackPublication<Track> publication, Participant participant) {
    // TODO: implement onRemoteMutedTrack
    super.onRemoteMutedTrack(publication, participant);
    print("onRemoteMutedTrack: Called");
    setState(() {});
  }

  @override
  void onLocalTrackPublished(LocalParticipant localParticipant,
      LocalTrackPublication<LocalTrack> publication) {
    // TODO: implement onLocalTrackPublished
    super.onLocalTrackPublished(localParticipant, publication);
    setState(() {});
  }

  @override
  void onLocalTrackUnPublished(LocalParticipant localParticipant,
      LocalTrackPublication<LocalTrack> publication) {
    // TODO: implement onLocalTrackUnPublished
    super.onLocalTrackUnPublished(localParticipant, publication);
  }

  @override
  void onReceiveData(
      List<int> data, RemoteParticipant? participant, String? topic) {
    // TODO: implement onReceiveData
    super.onReceiveData(data, participant, topic);
  }

  @override
  void onTrackSubscribed(RemoteTrackPublication<RemoteTrack> publication,
      RemoteParticipant participant, Track track) {
    // TODO: implement onTrackSubscribed
    super.onTrackSubscribed(publication, participant, track);
    setState(() {});
  }

  @override
  void onTrackUnSubscribed(RemoteTrackPublication<RemoteTrack> publication,
      RemoteParticipant participant, Track track) {
    // TODO: implement onTrackUnSubscribed
    super.onTrackUnSubscribed(publication, participant, track);
    if (MTVideoCallPlugin.instance.currRoom!.remoteParticipants.values
            .toList()
            .firstOrNull !=
        null) {
      setState(() {});
    }
  }
}
