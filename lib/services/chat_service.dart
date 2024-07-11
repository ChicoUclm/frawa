import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:excursiona/model/message.dart';

class ChatService {
  final CollectionReference _excursionCollection =
      FirebaseFirestore.instance.collection('excursions');

  sendGroupMessage(
      {required String excursionId, required Message message}) async {
    try {
      _excursionCollection
          .doc(excursionId)
          .collection('chat')
          .add(message.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Message>> getGroupMessages(String excursionId) {
    try {
      return _excursionCollection
          .doc(excursionId)
          .collection('chat')
          .orderBy('timeSent')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
      });
    } catch (e) {
      return const Stream.empty();
    }
  }
}
