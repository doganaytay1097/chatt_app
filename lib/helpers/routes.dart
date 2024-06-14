import 'package:chatt_app/screens/auth_screen.dart';
import 'package:chatt_app/screens/chat_screen.dart';
import 'package:chatt_app/screens/display_picture_screen.dart';
import 'package:chatt_app/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
class Routes {
  static const String authScreen = '/';
  static const String userListScreen = '/user-list';
  static const String chatScreen = '/chat';
  static const String displayPictureScreen = '/display-picture';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authScreen:
        return MaterialPageRoute(builder: (_) => AuthScreen());
      case userListScreen:
        return MaterialPageRoute(builder: (_) => UserListScreen());
      case chatScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            receivedUserName: args['receivedUserName'],
            receivedUserID: args['receivedUserID'],
            receivedMToken: args['receivedMToken'],
            active: args['active'],
            receivedUserProfilePic: args['receivedUserProfilePic'],
          ),
        );
      case displayPictureScreen:
        final args = settings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (_) => DisplayPictureScreen(
            imageFile: args[0],
            senderToken: args[1],
            receiverToken: args[2],
            receiverID: args[3],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
