import 'package:chatt_app/constants/colors.dart';
import 'package:chatt_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _usernameController = TextEditingController();
  final _statusController = TextEditingController();
  File? _pickedImage;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final userData = userDoc.data();
    if (userData != null) {
      _usernameController.text = userData['username'];
      _statusController.text = userData['status'];
      setState(() {
        _avatarUrl = userData['avatarUrl'] ?? 'https://example.com/default_avatar.png';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImageFile = await ImagePicker().pickImage(source: source);
      if (pickedImageFile != null) {
        setState(() {
          _pickedImage = File(pickedImageFile.path);
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to pick image.'),
      ));
    }
  }

  Future<void> _uploadImage(File image) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(user.uid + '.jpg');

      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      setState(() {
        _avatarUrl = url;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'avatarUrl': url,
      });
    } catch (error) {
      print('Error uploading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to upload image.'),
      ));
    }
  }

  void _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_pickedImage != null) {
      await _uploadImage(_pickedImage!);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'username': _usernameController.text.trim(),
      'status': _statusController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Profile updated!'),
    ));
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Select from Gallery'),
            onTap: () {
              Navigator.of(ctx).pop();
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera),
            title: Text('Take a Photo'),
            onTap: () {
              Navigator.of(ctx).pop();
              _pickImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = _auth.currentUser?.uid == widget.userId;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('User Profile', style: TextStyles.font18White500Weight),
        backgroundColor: ColorsManager.appBarBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_avatarUrl.isNotEmpty)
              CircleAvatar(
                radius: 40,
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : NetworkImage(_avatarUrl) as ImageProvider,
              ),
            if (isCurrentUser)
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red
                ),
                icon: Icon(Icons.image),
                label: Text('Change Image'),
                onPressed: _showImagePickerOptions,
              ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username', labelStyle: TextStyles.font15Green500Weight),
              readOnly: !isCurrentUser,
            ),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(labelText: 'Status', labelStyle: TextStyles.font15Green500Weight),
              readOnly: !isCurrentUser,
            ),
            if (isCurrentUser)
              SizedBox(height: 12),
            if (isCurrentUser)
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile', style: TextStyles.font15Green500Weight),
              ),
          ],
        ),
      ),
    );
  }
}
