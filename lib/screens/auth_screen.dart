import 'package:chatt_app/constants/colors.dart';
import 'package:chatt_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  final String defaultAvatarUrl = '';

  void _submitAuthForm() async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });

      if (_isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance.collection('users').doc(authResult.user!.uid).set({
          'username': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'avatarUrl': null,
          'status': 'Hey there! I am using ChatApp',
        });
      }

      if (authResult.user != null) {
        Navigator.of(context).pushReplacementNamed('/user-list');
      }
    } on FirebaseAuthException catch (e) {
      var message = 'An error occurred, please check your credentials!';

      if (e.message != null) {
        message = e.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (err) {
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again.'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('WhatsApp Clone', style: TextStyles.font18White500Weight),
        backgroundColor: ColorsManager.appBarBackgroundColor,
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isLogin)
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Username', labelStyle: TextStyles.font16Grey400Weight),
                  ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyles.font16Grey400Weight),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password', labelStyle: TextStyles.font16Grey400Weight),
                  obscureText: true,
                ),
                SizedBox(height: 12),
                if (_isLoading)
                  CircularProgressIndicator(),
                if (!_isLoading)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.coralRed,
                    ),
                    onPressed: _submitAuthForm,
                    child: Text(_isLogin ? 'Login' : 'Signup', style: TextStyles.font16White600Weight),
                  ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin ? 'Create new account' : 'I already have an account', style: TextStyles.font16Grey400Weight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
