import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/view/widget/video_track_part.dart';

class GridTrack extends StatefulWidget {
  GridTrack({
    super.key,
    required this.lcPart,
    required this.rmPart,
  });
  LocalParticipant lcPart;
  RemoteParticipant rmPart;

  @override
  State<GridTrack> createState() => _GridTrackState();
}

class _GridTrackState extends State<GridTrack> {
  List<VideoTrack?> videoTracks = [];
  List<AudioTrack?> audioTracks = [];

  void putTracks() {
    videoTracks = [];
    audioTracks = [];
    for (var e in widget.rmPart.videoTrackPublications) {
      videoTracks.add(e.track);
    }
    for (var e in widget.rmPart.audioTrackPublications) {
      audioTracks.add(e.track);
    }
    if (widget.lcPart.videoTrackPublications.length > 1) {
      for (int i = 1; i < widget.lcPart.videoTrackPublications.length; ++i) {
        final e = widget.lcPart.videoTrackPublications[i].track;
        videoTracks.add(e);
      }
      for (int i = 1; i < widget.lcPart.audioTrackPublications.length; ++i) {
        final e = widget.lcPart.audioTrackPublications[i].track;
        audioTracks.add(e);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    putTracks();
    return videoTracks.length == 1
        ? MTVideoTrack(
            videoTrack: widget.rmPart.videoTrackPublications.first.track,
            audioTrack: widget.rmPart.audioTrackPublications.first.track,
            mirrorMode: VideoViewMirrorMode.off,
            fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
        : videoTracks.length == 2
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: videoTracks.length,
                itemBuilder: (context, index) {
                  final track = videoTracks[index];
                  final audio =
                      index >= audioTracks.length ? null : audioTracks[index];
                  return Container(
                    color: Colors.black,
                    child: MTVideoTrack(
                      videoTrack: track,
                      audioTrack: audio,
                      mirrorMode: VideoViewMirrorMode.off,
                      fit: rtc
                          .RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    ),
                  );
                },
              )
            : videoTracks.length == 3
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MTVideoTrack(
                        videoTrack: videoTracks.last,
                        audioTrack: null,
                      ),
                      Row(
                        children: [
                          MTVideoTrack(
                            videoTrack: videoTracks[0],
                            audioTrack: audioTracks[0],
                          ),
                          MTVideoTrack(
                            videoTrack: videoTracks[1],
                            audioTrack: audioTracks[1],
                          ),
                        ],
                      ),
                    ],
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: videoTracks.length,
                    itemBuilder: (context, index) {
                      final track = videoTracks[index];
                      final audio = index >= audioTracks.length
                          ? null
                          : audioTracks[index];
                      return MTVideoTrack(
                        videoTrack: track,
                        audioTrack: audio,
                        mirrorMode: VideoViewMirrorMode.off,
                        fit: rtc
                            .RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                      );
                    },
                  );
  }
}
