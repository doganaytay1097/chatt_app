import 'package:flutter/material.dart';
import 'dart:io';

class DisplayPictureScreen extends StatelessWidget {
  final File imageFile;
  final String senderToken;
  final String receiverToken;
  final String receiverID;

  const DisplayPictureScreen({
    Key? key,
    required this.imageFile,
    required this.senderToken,
    required this.receiverToken,
    required this.receiverID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Picture'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(imageFile),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle send image action
              },
              child: Text('Send Image'),
            ),
          ],
        ),
      ),
    );
  }
}
