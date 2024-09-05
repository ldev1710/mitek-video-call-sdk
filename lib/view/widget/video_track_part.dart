import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/view/widget/video_widget.dart';

class MTVideoTrack extends StatefulWidget {
  MTVideoTrack({
    super.key,
    required this.videoTrack,
    required this.audioTrack,
    this.fit = rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirrorMode = VideoViewMirrorMode.auto,
    this.renderMode = VideoRenderMode.auto,
  });

  rtc.RTCVideoViewObjectFit fit;
  VideoViewMirrorMode mirrorMode;
  VideoRenderMode renderMode;
  VideoTrack? videoTrack;
  AudioTrack? audioTrack;

  @override
  State<MTVideoTrack> createState() => _MTVideoTrackState();
}

class _MTVideoTrackState extends State<MTVideoTrack> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.videoTrack == null
            ? _cameraDisabledWidget()
            : !widget.videoTrack!.muted
                ? MTVideoRender(widget.videoTrack!)
                : _cameraDisabledWidget(),
        if (widget.audioTrack == null || (widget.audioTrack != null && widget.audioTrack!.muted))
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_off,
                color: Colors.white,
              ),
            ),
          )
      ],
    );
  }

  Widget _cameraDisabledWidget() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.videocam_off,
        color: Colors.black,
        size: 48,
      ),
    );
  }
}
