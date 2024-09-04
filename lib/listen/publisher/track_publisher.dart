import 'package:livekit_client/livekit_client.dart';
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

  @override
  void onRemoteMutedTrack(TrackPublication<Track> publication, Participant participant) {
    // TODO: implement onRemoteMutedTrack
  }

  @override
  void onRemoteUnMutedTrack(TrackPublication<Track> publication, Participant participant) {
    // TODO: implement onRemoteUnMutedTrack
  }
}
