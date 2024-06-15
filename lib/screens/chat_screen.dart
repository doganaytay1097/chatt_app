import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chatt_app/database.dart';
import 'package:chatt_app/helpers/notification_service.dart';
import 'package:chatt_app/helpers/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String receivedUserName;
  final String receivedUserID;
  final String receivedMToken;
  final String active;
  final String? receivedUserProfilePic;

  const ChatScreen({
    Key? key,
    required this.receivedUserName,
    required this.receivedUserID,
    required this.receivedMToken,
    required this.active,
    required this.receivedUserProfilePic,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = NotificationService();
  final _auth = FirebaseAuth.instance;
  final _scrollController = ScrollController();
  late String? token;
  final TextEditingController _messageController = TextEditingController();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leadingWidth: 85.w,
        leading: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              Gap(10.w),
              Icon(Icons.arrow_back_ios, size: 25.sp),
              widget.receivedUserProfilePic != null &&
                      widget.receivedUserProfilePic!.isNotEmpty
                  ? Hero(
                      tag: widget.receivedUserProfilePic!,
                      child: ClipOval(
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/loading.gif',
                          image: widget.receivedUserProfilePic!,
                          fit: BoxFit.cover,
                          width: 50.w,
                          height: 50.h,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/images/user.png',
                      height: 50.h,
                      width: 50.w,
                      fit: BoxFit.cover,
                    ),
            ],
          ),
        ),
        toolbarHeight: 70.h,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receivedUserName),
            Text(
              widget.active == 'true'
                  ? context.tr('online')
                  : context.tr('offline'),
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color.fromARGB(255, 200, 210, 100),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/chat_backgrond.png"),
            opacity: 0.1,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildMessagesList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String message) async {
    User? currentUser = _auth.currentUser;
    String senderName = currentUser?.displayName ?? 'Unknown';

    await DatabaseMethods.sendMessage(
      message,
      widget.receivedUserID,
    );
    _messageController.clear();
    scrollToDown();

    await _chatService.sendPushMessage(
      widget.receivedMToken,
      message,
      senderName,
      currentUser!.uid,
      currentUser.photoURL,
    );
  }

  Future<void> uploadImage(File image) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(DateTime.now().toIso8601String() + '.jpg');

      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      await sendMessage(url);
    } catch (error) {
      print('Error uploading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to upload image.'),
      ));
    }
  }

  Future getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      await uploadImage(File(pickedFile.path));
    }
  }

  Future getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await uploadImage(File(pickedFile.path));
    }
  }

  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1000));
      scrollToDown();
      await HelperNotification.initialize(flutterLocalNotificationsPlugin);
    });
    getToken();
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        HelperNotification.showNotification(
          message.notification!.title!,
          message.notification!.body!,
          flutterLocalNotificationsPlugin,
        );
      },
    );
  }

  void scrollToDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  Future showOptions() async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: Text(context.tr('photoGallery')),
              onPressed: () {
                Navigator.pop(context);
                getImageFromGallery();
              },
            ),
            CupertinoActionSheetAction(
              child: Text(context.tr('camera')),
              onPressed: () {
                Navigator.pop(context);
                getImageFromCamera();
              },
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(context.tr('photoGallery')),
                onTap: () {
                  Navigator.pop(context);
                  getImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(context.tr('camera')),
                onTap: () {
                  Navigator.pop(context);
                  getImageFromCamera();
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        color: Colors.teal,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.photo_camera, color: Colors.white),
              onPressed: () => showOptions(),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: context.tr('message'),
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () async {
                if (_messageController.text.isNotEmpty) {
                  await sendMessage(_messageController.text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    Stream<QuerySnapshot<Object?>> allMessages =
        DatabaseMethods.getMessages(widget.receivedUserID, _auth.currentUser!.uid);

    return StreamBuilder(
      stream: allMessages,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        List<DocumentSnapshot> messageDocs = snapshot.data!.docs;

        return ListView.builder(
          reverse: false,
          controller: _scrollController,
          itemCount: messageDocs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot currentMessage = messageDocs[index];
            DocumentSnapshot? previousMessage =
                index > 0 ? messageDocs[index - 1] : null;
            DocumentSnapshot? nextMessage =
                index < messageDocs.length - 1 ? messageDocs[index + 1] : null;

            return _buildMessageItem(currentMessage, previousMessage, nextMessage);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot snapshot, DocumentSnapshot? previousMessage, DocumentSnapshot? nextMessage) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    bool isNewDay = previousMessage == null ||
        !_isSameDay(data['timestamp'].toDate(), previousMessage['timestamp'].toDate());
    bool isNewSender = nextMessage == null || data['senderID'] != nextMessage['senderID'];

    return Column(
      children: [
        if (isNewDay)
          CustomDateChip(
            date: data['timestamp'].toDate(),
            textStyle: TextStyle(color: Colors.white),
          ),
        if (data['message'].contains('https://'))
          BubbleNormalImage(
            id: data['timestamp'].toDate().toString(),
            tail: isNewSender,
            isSender: data['senderID'] == _auth.currentUser!.uid,
            color: data['senderID'] == _auth.currentUser!.uid
                ? const Color.fromARGB(255, 0, 107, 84)
                : const Color(0xff273443),
            image: CachedNetworkImage(
              imageUrl: data['message'],
              placeholder: (context, url) =>
                  Image.asset('assets/images/loading.gif'),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error_outline_rounded),
            ),
          ),
        if (!data['message'].contains('https://'))
          BubbleSpecialThree(
            text: data['message'],
            color: data['senderID'] == _auth.currentUser!.uid
                ? const Color.fromARGB(255, 0, 107, 84)
                : const Color(0xff273443),
            tail: isNewSender,
            isSender: data['senderID'] == _auth.currentUser!.uid
                ? context.locale.languageCode == 'ar'
                    ? false
                    : true
                : context.locale.languageCode == 'ar'
                    ? true
                    : false,
            textStyle: TextStyle(
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  bool _isSameDay(DateTime timestamp1, DateTime timestamp2) {
    return timestamp1.year == timestamp2.year &&
        timestamp1.month == timestamp2.month &&
        timestamp1.day == timestamp2.day;
  }
}

class CustomDateChip extends StatelessWidget {
  final DateTime date;
  final TextStyle textStyle;

  const CustomDateChip({
    Key? key,
    required this.date,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xff273443),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        DateFormat('MMM d, yyyy').format(date),
        style: textStyle,
      ),
    );
  }
}
