import 'package:chatt_app/chat_room_screen';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Clone',
      theme: ThemeData(
        primaryColor: Color(0xFF075E54),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF25D366),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black54),
          titleLarge: TextStyle(color: Colors.black),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthScreen(),
      routes: {
        '/chat-rooms': (ctx) => ChatRoomsScreen(),
        '/profile': (ctx) => ProfileScreen(userId: ''), // Placeholder, not used
      },
    );
  }
}
