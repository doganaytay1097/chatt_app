import 'package:chatt_app/constants/colors.dart';
import 'package:chatt_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users', style: TextStyles.font18White500Weight),
        backgroundColor: ColorsManager.appBarBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final users = userSnapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (ctx, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              if (FirebaseAuth.instance.currentUser!.uid == users[index].id) {
                return Container(); // Hide current user
              }
              return ListTile(
                title: Text(userData['username'], style: TextStyles.font16Grey400Weight),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receivedUserName: userData['username'],
                        receivedUserID: users[index].id,
                        receivedMToken: userData['mToken'] ?? '',
                        active: userData['active'] ?? 'false',
                        receivedUserProfilePic: userData['avatarUrl'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
