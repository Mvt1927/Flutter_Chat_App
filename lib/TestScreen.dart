import 'package:flutter/material.dart';
import 'package:flutter_chat_app/AuthService.dart';
import 'package:flutter_chat_app/ChatScreen.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    var authService = Provider.of<AuthService>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In'),
      ),
      body: Center(
        child: TextButton(
          child: Text('Sign In with Google'),
          onPressed: () {
            _handleSignIn(authService);
          },
        ),
      ),
    );
  }

  void _handleSignIn(AuthService authService) async {
    authService.signIn().then((success) {
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sign in failed'),
        ));
      }
    });
  }
}
