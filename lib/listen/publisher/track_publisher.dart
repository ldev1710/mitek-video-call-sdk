import 'package:livekit_client/src/participant/local.dart';
import 'package:livekit_client/src/participant/remote.dart';
import 'package:livekit_client/src/publication/local.dart';
import 'package:livekit_client/src/publication/remote.dart';
import 'package:livekit_client/src/track/local/local.dart';
import 'package:livekit_client/src/track/remote/remote.dart';
import 'package:livekit_client/src/track/track.dart';
import 'package:mitek_video_call_sdk/listen/prototype/track_prototype.dart';

mixin class MTTrackListener implements MTTrackPrototype {
  @override
  void onLocalTrackPublished(
      LocalParticipant localParticipant, LocalTrackPublication<LocalTrack> publication) {
    // TODO: implement onLocalTrackPublished
  }

  @override
  void onLocalTrackUnPublished(
      LocalParticipant localParticipant, LocalTrackPublication<LocalTrack> publication) {
    // TODO: implement onLocalTrackUnPublished
  }

  @override
  void onTrackSubscribed(
      RemoteTrackPublication<RemoteTrack> publication, RemoteParticipant participant, Track track) {
    // TODO: implement onTrackSubscribed
  }

  @override
  void onTrackUnSubscribed(
      RemoteTrackPublication<RemoteTrack> publication, RemoteParticipant participant, Track track) {
    // TODO: implement onTrackUnSubscribed
  }
}
