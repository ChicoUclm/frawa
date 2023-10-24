class LiveStreamingRoom {
  final String roomId;
  final String userId;

  LiveStreamingRoom({
    required this.roomId,
    required this.userId,
  });

  LiveStreamingRoom copyWith({
    String? roomId,
    String? userId,
  }) {
    return LiveStreamingRoom(
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'roomId': roomId,
      'userId': userId,
    };
  }

  factory LiveStreamingRoom.fromMap(Map<String, dynamic> map) {
    return LiveStreamingRoom(
      roomId: map['roomId'] as String,
      userId: map['userId'] as String,
    );
  }
}
