import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message.dart';

class DatabaseMethods {
  static Future<void> sendMessage(String message, String receiverID) async {
    final senderID = FirebaseAuth.instance.currentUser!.uid;
    final senderName = FirebaseAuth.instance.currentUser!.displayName;
    final timestamp = Timestamp.now();
    final newMessage = Message(
      senderID: senderID,
      senderName: senderName!,
      message: message,
      receiverID: receiverID,
      timestamp: timestamp,
    );

    final chatId = getChatId(senderID, receiverID);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  static Stream<QuerySnapshot<Object?>> getMessages(String userId, String otherUserId) {
    final chatId = getChatId(userId, otherUserId);
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static String getChatId(String userId, String otherUserId) {
    return userId.hashCode <= otherUserId.hashCode ? '$userId-$otherUserId' : '$otherUserId-$userId';
  }
}
