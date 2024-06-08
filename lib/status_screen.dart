import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatusScreen extends StatefulWidget {
  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final _statusController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  void _updateStatus() async {
    final user = _auth.currentUser;
    if (user == null || _statusController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'status': _statusController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Status updated!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Status'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _statusController,
              decoration: InputDecoration(labelText: 'Enter new status'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _updateStatus,
              child: Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }
}
