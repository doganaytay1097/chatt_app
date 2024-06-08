import 'package:chatt_app/message_bubble';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  ChatScreen({required this.chatRoomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;

  void _sendMessage() async {
    final user = _auth.currentUser;
    if (_controller.text.isEmpty || user == null) {
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('chat_rooms').doc(widget.chatRoomId).collection('messages').add({
        'text': _controller.text,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
      });
      _controller.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send message.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          DropdownButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
                value: 'logout',
              ),
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                value: 'profile',
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(),
                  ),
                );
              } else if (itemIdentifier == 'profile') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: _auth.currentUser!.uid),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!chatSnapshot.hasData || chatSnapshot.data == null) {
                  return Center(child: Text('No messages available.'));
                }
                final chatDocs = chatSnapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) {
                    final chatData = chatDocs[index].data() as Map<String, dynamic>;
                    return FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(chatData['userId'])
                          .get(),
                      builder: (ctx, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (userSnapshot.hasError) {
                          return Center(child: Text('An error occurred!'));
                        }
                        if (!userSnapshot.hasData || userSnapshot.data == null || !userSnapshot.data!.exists) {
                          return Center(child: Text('User not found!'));
                        }

                        final userDoc = userSnapshot.data!;
                        final userData = userDoc.data() as Map<String, dynamic>?;

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(userId: chatData['userId']),
                              ),
                            );
                          },
                          child: MessageBubble(
                            chatData['text'] ?? '',
                            userData?['username'] ?? 'Anonymous',
                            userData?['avatarUrl'] ?? 'https://example.com/default_avatar.png',
                            userData?['status'] ?? 'https://example.com/default_avatar.png',
                            chatData['userId'] == _auth.currentUser!.uid,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
