import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

class StreamingRoomProvider extends ChangeNotifier {
  Room? room;

  void saveRoom(Room newRoom) {
    room = newRoom;
    notifyListeners();
  }

  void deleteRoom() {
    room = null;
    notifyListeners();
  }
}
