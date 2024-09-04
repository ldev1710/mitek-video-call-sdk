import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/view/video/video_widget.dart';

class LocalVideoWidget extends StatefulWidget {
  LocalVideoWidget({
    super.key,
    required this.videoTrack,
    required this.backgroundWidget,
  });

  VideoTrack videoTrack;
  Widget backgroundWidget;
  @override
  State<LocalVideoWidget> createState() => _LocalVideoWidgetState();
}

class _LocalVideoWidgetState extends State<LocalVideoWidget> {
  @override
  Widget build(BuildContext context) {
    return MTVideoRender(
      widget.videoTrack,
      fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      mirrorMode: VideoViewMirrorMode.off,
    );
  }
}
