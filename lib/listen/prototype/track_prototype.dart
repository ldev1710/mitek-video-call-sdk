import 'package:livekit_client/livekit_client.dart';

abstract class MTTrackPrototype {
  void onLocalTrackUnPublished(
      LocalParticipant localParticipant, LocalTrackPublication<LocalTrack> publication);
  void onLocalTrackPublished(
      LocalParticipant localParticipant, LocalTrackPublication<LocalTrack> publication);
  void onTrackSubscribed(
      RemoteTrackPublication<RemoteTrack> publication, RemoteParticipant participant, Track track);
  void onTrackUnSubscribed(
      RemoteTrackPublication<RemoteTrack> publication, RemoteParticipant participant, Track track);
  void onRemoteMutedTrack(TrackPublication<Track> publication, Participant participant);
  void onRemoteUnMutedTrack(TrackPublication<Track> publication, Participant participant);
}
