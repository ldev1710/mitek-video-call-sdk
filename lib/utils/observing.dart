import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/mitek_video_call_sdk.dart';

class MTObserving {
  static void observingRoomDisconnected(DisconnectReason? reason) {
    for (var e in MTVideoCallPlugin.instance.roomListener) {
      e.onDisconnectedRoom(reason);
    }
  }

  static void observingRoomConnected(RoomConnectedEvent event) {
    for (var e in MTVideoCallPlugin.instance.roomListener) {
      e.onConnectedRoom(event.room, event.metadata);
    }
  }

  static void observingParticipantConnected(ParticipantConnectedEvent event) {
    for (var e in MTVideoCallPlugin.instance.roomListener) {
      e.onParticipantConnectedRoom(event.participant);
    }
  }

  static void observingParticipantDisconnected(ParticipantDisconnectedEvent event) {
    for (var e in MTVideoCallPlugin.instance.roomListener) {
      e.onParticipantDisconnectedRoom(event.participant);
    }
  }

  static void observingDataReceive(DataReceivedEvent event) {
    for (var e in MTVideoCallPlugin.instance.roomListener) {
      e.onReceiveData(event.data, event.participant, event.topic);
    }
  }

  static void observingLocalTrackPublished(LocalTrackPublishedEvent event) {
    for (var e in MTVideoCallPlugin.instance.trackListener) {
      e.onLocalTrackPublished(event.participant, event.publication);
    }
  }

  static void observingLocalTrackUnPublished(LocalTrackUnpublishedEvent event) {
    for (var e in MTVideoCallPlugin.instance.trackListener) {
      e.onLocalTrackUnPublished(event.participant, event.publication);
    }
  }

  static void observingTrackSubscribed(TrackSubscribedEvent event) {
    for (var e in MTVideoCallPlugin.instance.trackListener) {
      e.onTrackSubscribed(event.publication, event.participant, event.track);
    }
  }

  static void observingTrackUnsubscribed(TrackUnsubscribedEvent event) {
    for (var e in MTVideoCallPlugin.instance.trackListener) {
      e.onTrackUnSubscribed(event.publication, event.participant, event.track);
    }
  }
}
