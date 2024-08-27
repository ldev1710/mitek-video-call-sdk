library mitek_video_call_sdk;

import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/models/language.dart';
import 'package:mitek_video_call_sdk/models/option_video_call.dart';
import 'package:mitek_video_call_sdk/models/user.dart';
import 'package:mitek_video_call_sdk/network/mitek_network.dart';
import 'package:mitek_video_call_sdk/utils/constants.dart';

class MTVideoCallPlugin {
  static final MTVideoCallPlugin _instance = MTVideoCallPlugin._internal();
  static MTVideoCallPlugin get instance => _instance;
  MTVideoCallPlugin._internal();
  factory MTVideoCallPlugin() {
    return _instance;
  }

  String? _videoCallToken;
  final MTNetwork _instanceNetwork = MTNetwork();
  Room? _room;

  /// Authenticating with MITEK system using api key was provided
  Future<bool> authenticate({required String apiKey}) async {
    final body = {
      'apiKey': apiKey,
    };
    return true;
    final response = await _instanceNetwork.post(MTNetworkConstant.authenticate, data: body);
    return !response.data['error'];
  }

  /// Getting list language supported from MITEK system
  Future<List<MTLanguageSp>> getLanguageSupport() async {
    return [
      MTLanguageSp(id: 1, language: "Tiếng Việt"),
      MTLanguageSp(id: 2, language: "Tiếng Anh"),
    ];
    final response = await _instanceNetwork.get(MTNetworkConstant.getLanguageSp);
    return response.data['data'];
  }

  /// Call this function before call 'startVideoCall' function
  /// It will create an session video call in MITEK system
  Future<bool> createVideoCallSession(
      {required MTUser user, required MTLanguageSp languageSp}) async {
    final response = await _instanceNetwork.post(MTNetworkConstant.initVideoCall);
    _videoCallToken = response.data['token'];
    return !response.data['error'];
  }

  /// Call this function to start video call to MITEK system
  Future<bool> startVideoCall({required MTVideoCallOption option}) async {
    // VideoEncoding? cameraEncoding;
    // VideoEncoding? screenEncoding;
    // if (option.cameraEncoding != null) {
    //   cameraEncoding = VideoEncoding(
    //     maxBitrate: option.cameraEncoding!.maxBitrate,
    //     maxFramerate: option.cameraEncoding!.maxFrameRate,
    //   );
    // }
    // if (option.screenEncoding != null) {
    //   screenEncoding = VideoEncoding(
    //     maxBitrate: option.screenEncoding!.maxBitrate,
    //     maxFramerate: option.screenEncoding!.maxFrameRate,
    //   );
    // }
    //
    // final room = Room(
    //   roomOptions: RoomOptions(
    //     adaptiveStream: option.enableAdaptiveStream,
    //     dynacast: option.enableDynacast,
    //     defaultAudioPublishOptions: const AudioPublishOptions(
    //       name: 'custom_audio_track_name',
    //     ),
    //     defaultCameraCaptureOptions: const CameraCaptureOptions(maxFrameRate: 30),
    //     defaultScreenShareCaptureOptions: const ScreenShareCaptureOptions(
    //       useiOSBroadcastExtension: true,
    //       params: VideoParameters(
    //         dimensions: VideoDimensionsPresets.h1080_169,
    //       ),
    //     ),
    //     defaultVideoPublishOptions: VideoPublishOptions(
    //       simulcast: option.enableSimulcast,
    //       videoCodec: option.preferredCodec,
    //       backupVideoCodec: BackupVideoCodec(
    //         enabled: option.enableBackupVideoCodec,
    //       ),
    //       videoEncoding: cameraEncoding,
    //       screenShareEncoding: screenEncoding,
    //     ),
    //   ),
    // );
    // final listener = room.createListener();
    _room = Room();
    await _room!.connect(MTNetworkConstant.url, _videoCallToken ?? "");
    return true;
  }

  /// Call this function to end and disconnect video call
  Future<bool> disconnectVideoCall() async {
    await _room!.disconnect();
    return true;
  }
}
