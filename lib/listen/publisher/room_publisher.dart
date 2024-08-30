import 'package:livekit_client/src/core/room.dart';
import 'package:livekit_client/src/participant/remote.dart';
import 'package:livekit_client/src/types/other.dart';
import 'package:mitek_video_call_sdk/listen/prototype/room_prototype.dart';

mixin class MTRoomEventListener implements MTRoomPrototype {
  @override
  void onConnectedRoom(Room room, String? metaData) {
    // TODO: implement onConnectedRoom
  }

  @override
  void onDisconnectedRoom(DisconnectReason? reason) {
    // TODO: implement onDisconnectedRoom
  }

  @override
  void onParticipantConnectedRoom(RemoteParticipant participant) {
    // TODO: implement onParticipantConnectedRoom
  }

  @override
  void onParticipantDisconnectedRoom(RemoteParticipant participant) {
    // TODO: implement onParticipantDisconnectedRoom
  }

  @override
  void onReceiveData(List<int> data, RemoteParticipant? participant, String? topic) {
    // TODO: implement onReceiveData
  }
}
