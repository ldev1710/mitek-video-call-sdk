class MTRoom {
  String roomId;
  String roomName;
  int emptyTimeOut;
  int maxParticipants;

  MTRoom({
    required this.roomId,
    required this.roomName,
    required this.emptyTimeOut,
    required this.maxParticipants,
  });

  factory MTRoom.fromJson(Map<String, dynamic> json) {
    return MTRoom(
      roomId: json["room_id"],
      roomName: json["room_name"],
      emptyTimeOut: json["emptyTimeout"],
      maxParticipants: json["maxParticipants"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "room_id": roomId,
      "room_name": roomName,
      "emptyTimeout": emptyTimeOut,
      "maxParticipants": maxParticipants,
    };
  }
}
