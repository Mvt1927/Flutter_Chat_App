import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/AuthService.dart';
import 'package:flutter_chat_app/ChatScreen.dart';
import 'package:flutter_chat_app/main.dart';
import 'package:provider/provider.dart';

class ChatMessageListItem extends StatelessWidget {
  final DataSnapshot messageSnapshot;
  final Animation animation;

  ChatMessageListItem({required this.messageSnapshot, required this.animation});

  @override
  Widget build(BuildContext context) {
    var authService = Provider.of<AuthService>(context);
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animation as Animation<double>, curve: Curves.decelerate),
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          children: authService.currentUser!.email ==
                  (messageSnapshot.value as Map<dynamic, dynamic>)['email']
              ? getSentMessageLayout()
              : getReceivedMessageLayout(),
        ),
      ),
    );
  }

  List<Widget> getSentMessageLayout() {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text(
                (messageSnapshot.value as Map<dynamic, dynamic>)['senderName'],
                style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: (messageSnapshot.value
                          as Map<dynamic, dynamic>)['imageUrl'] !=
                      null
                  ? new Image.network(
                      (messageSnapshot.value
                          as Map<dynamic, dynamic>)['imageUrl'],
                      width: 250.0,
                    )
                  : new Text(
                      (messageSnapshot.value as Map<dynamic, dynamic>)['text']),
            ),
          ],
        ),
      ),
      new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: new CircleAvatar(
                backgroundImage: new NetworkImage((messageSnapshot.value
                    as Map<dynamic, dynamic>)['senderPhotoUrl']),
              )),
        ],
      ),
    ];
  }

  List<Widget> getReceivedMessageLayout() {
    return <Widget>[
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: new CircleAvatar(
                backgroundImage: new NetworkImage((messageSnapshot.value
                    as Map<dynamic, dynamic>)['senderPhotoUrl']),
              )),
        ],
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
                (messageSnapshot.value as Map<dynamic, dynamic>)['senderName'],
                style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: (messageSnapshot.value
                          as Map<dynamic, dynamic>)['imageUrl'] !=
                      null
                  ? new Image.network(
                      (messageSnapshot.value
                          as Map<dynamic, dynamic>)['imageUrl'],
                      width: 250.0,
                    )
                  : new Text(
                      (messageSnapshot.value as Map<dynamic, dynamic>)['text']),
            ),
          ],
        ),
      ),
    ];
  }
}
