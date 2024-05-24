import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/AuthService.dart';
import 'package:flutter_chat_app/ChatScreen.dart';
import 'package:flutter_chat_app/TestScreen.dart';
import 'package:flutter_chat_app/util/Themes.dart';
import 'package:flutter_chat_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

late final FirebaseDatabase database;
late final FirebaseStorage storage;
late final analytics;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  auth = FirebaseAuth.instanceFor(app: app);

  database = FirebaseDatabase.instanceFor(app: app);

  storage = FirebaseStorage.instanceFor(app: app);

  analytics = FirebaseAnalytics.instanceFor(app: app);

  runApp(
    MultiProvider(providers: [
      Provider<AuthService>(
        create: (_) => AuthService(),
      ),
    ], child: FlutterChatApp()),
  );
}

class FlutterChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _authService = Provider.of<AuthService>(context);
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Flutter Chat App",
        theme: defaultTargetPlatform == TargetPlatform.iOS
            ? Themes.kIOSTheme
            : Themes.kDefaultTheme,
        home: StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final User? user = snapshot.data;
              return user == null ? TestScreen() : ChatScreen();
            } else {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        )
        // home: new TestScreen(),
        );
  }
}
