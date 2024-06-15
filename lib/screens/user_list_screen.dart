import 'package:chatt_app/constants/colors.dart';
import 'package:chatt_app/constants/styles.dart';
import 'package:chatt_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'chat_screen.dart';

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundDefaultColor,
      appBar: AppBar(
        title: Text('Users', style: TextStyles.font18White500Weight),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userId: FirebaseAuth.instance.currentUser!.uid,
                  ),
                ),
              );
            },
          ),
          Gap(5),
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
              return Padding (
                padding: EdgeInsets.only(top: 10),
                child: ListTile(
                leading: CircleAvatar(backgroundImage: userData['avatarUrl'] !=null 
                ?NetworkImage(userData['avatarUrl'])
                :AssetImage('assets/images/user.png'),
                backgroundColor: Color(0xffedcfc7),
                radius: 25,
                 ),
                title: Text(userData['username'], style: TextStyles.font13Green500Weight),
                subtitle: Text(userData['status'], style: TextStyles.font10Green300Weight),
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
              ),);
            },
          );
        },
      ),
    );
  }
}
