import 'package:livekit_client/livekit_client.dart';

abstract class MTRoomPrototype {
  void onConnectedRoom(Room room, String? metaData);
  void onDisconnectedRoom(DisconnectReason? reason);
  void onParticipantConnectedRoom(RemoteParticipant participant);
  void onParticipantDisconnectedRoom(RemoteParticipant participant);
  void onReceiveData(List<int> data, RemoteParticipant? participant, String? topic);
}
