class MTVideoCallOption {
  final MTVideoEncoding? cameraEncoding;
  final MTVideoEncoding? screenEncoding;
  final bool enableAdaptiveStream;
  final bool enableDynacast;
  final bool enableSimulcast;
  final bool enableBackupVideoCodec;
  final String preferredCodec;

  const MTVideoCallOption({
    this.cameraEncoding,
    this.screenEncoding,
    this.enableAdaptiveStream = false,
    this.enableDynacast = false,
    this.enableSimulcast = true,
    this.enableBackupVideoCodec = true,
    this.preferredCodec = 'VP8',
  });
}

class MTVideoEncoding {
  final int maxBitrate;
  final int maxFrameRate;

  const MTVideoEncoding({
    required this.maxBitrate,
    required this.maxFrameRate,
  });
}
