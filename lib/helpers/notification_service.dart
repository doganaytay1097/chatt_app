import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String serverToken = 'YOUR_SERVER_KEY_HERE';

  Future<void> sendPushMessage(
    String recipientToken,
    String message,
    String senderName,
    String uid,
    String? photoURL,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': message,
              'title': senderName,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'message': message,
              'sender_name': senderName,
              'uid': uid,
              'photoURL': photoURL,
            },
            'to': recipientToken,
          },
        ),
      );

      if (response.statusCode != 200) {
        print('Failed to send push notification');
      }
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }
}
