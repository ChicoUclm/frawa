class LiveStreamingRoom {
  final String roomId;
  final String userId;
  final String excursionId;

  LiveStreamingRoom({
    required this.roomId,
    required this.userId,
    required this.excursionId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'roomId': roomId,
      'userId': userId,
      'excursionId': excursionId,
    };
  }

  factory LiveStreamingRoom.fromMap(Map<String, dynamic> map) {
    return LiveStreamingRoom(
      roomId: map['roomId'] as String,
      userId: map['userId'] as String,
      excursionId: map['excursionId'] as String,
    );
  }
}
