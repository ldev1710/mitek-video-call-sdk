import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/view/widget/video_widget.dart';

class LocalVideoWidget extends StatefulWidget {
  LocalVideoWidget({
    super.key,
    required this.videoTrack,
    required this.backgroundWidget,
    required this.isFloating,
    this.onPop,
  });

  bool isFloating;
  VideoTrack videoTrack;
  Widget backgroundWidget;
  void Function()? onPop;
  @override
  State<LocalVideoWidget> createState() => _LocalVideoWidgetState();
}

class _LocalVideoWidgetState extends State<LocalVideoWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MTVideoRender(
          widget.videoTrack,
          fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          mirrorMode: VideoViewMirrorMode.off,
        ),
        if (!widget.isFloating)
          Positioned(
            top: 48,
            left: 12,
            child: GestureDetector(
              onTap: () {
                if (widget.onPop != null) widget.onPop!();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
