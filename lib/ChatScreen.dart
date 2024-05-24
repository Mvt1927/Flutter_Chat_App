import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/AuthService.dart';
import 'package:flutter_chat_app/ChatMessageListItem.dart';
import 'package:flutter_chat_app/TestScreen.dart';
import 'package:flutter_chat_app/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

var _scaffoldContext;

class ChatScreen extends StatefulWidget {
  @override
  ChatScreenState createState() {
    return new ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  bool _isComposingMessage = false;

  final reference = database.ref('messages');
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Flutter Chat App"),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.exit_to_app), onPressed: _signOut)
          ],
        ),
        body: new Container(
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new FirebaseAnimatedList(
                  query: reference,
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  sort: (a, b) => (b.key ?? '').compareTo(a.key ?? ''),
                  //comparing timestamp of messages to check which one would appear first
                  itemBuilder: (_, DataSnapshot messageSnapshot,
                      Animation<double> animation, int index) {
                    return new ChatMessageListItem(
                      messageSnapshot: messageSnapshot,
                      animation: animation,
                    );
                  },
                ),
              ),
              new Divider(height: 1.0),
              new Container(
                decoration:
                    new BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
              new Builder(builder: (BuildContext context) {
                _scaffoldContext = context;
                return new Container(width: 0.0, height: 0.0);
              })
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(
                      top: new BorderSide(
                  color: Colors.grey[200] ?? Colors.grey,
                )))
              : null,
        ));
  }

  CupertinoButton getIOSSendButton() {
    return new CupertinoButton(
      child: new Text("Send"),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color: _isComposingMessage
              ? Theme.of(context).iconTheme.color
              : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(
                      Icons.photo_camera,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () async {
                      XFile? imageXFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      int timestamp = new DateTime.now().millisecondsSinceEpoch;
                      String fileName = "img_" + timestamp.toString() + ".jpg";
                      Reference storageReference = storage.ref(fileName);

                      File imageFile = File(imageXFile!.path);
                      await storageReference.putFile(imageFile);
                      String downloadUrl =
                          await storageReference.getDownloadURL();
                      _sendMessage(messageText: null, imageUrl: downloadUrl);
                    }),
              ),
              new Flexible(
                child: new TextField(
                  controller: _textEditingController,
                  onChanged: (String messageText) {
                    setState(() {
                      _isComposingMessage = messageText.length > 0;
                    });
                  },
                  onSubmitted: _textMessageSubmitted,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                ),
              ),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? getIOSSendButton()
                    : getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();

    setState(() {
      _isComposingMessage = false;
    });

    // await _ensureLoggedIn();
    _sendMessage(messageText: text, imageUrl: null);
  }

  void _sendMessage({String? messageText, String? imageUrl}) {
    var authService = Provider.of<AuthService>(context, listen: false);

    reference.push().set({
      'text': messageText,
      'email': authService.currentUser!.email,
      'imageUrl': imageUrl,
      'senderName': authService.currentUser!.displayName,
      'senderPhotoUrl': authService.currentUser!.photoURL,
    });

    analytics.logEvent(name: 'send_message');
  }

  Future _signOut() async {
    var authService = Provider.of<AuthService>(context, listen: false);
    // googleSignIn.signOut();
    authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TestScreen()),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text('User logged out')));
  }
}
