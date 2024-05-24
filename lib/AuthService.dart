import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  User? get currentUser => auth.currentUser;

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<bool> signIn() async {
    GoogleSignInAccount? signedInUser = _googleSignIn.currentUser;

    if (signedInUser == null)
      signedInUser = await _googleSignIn.signInSilently();
    if (signedInUser == null) {
      signedInUser = await _googleSignIn.signIn();
      analytics.logLogin();
    }
    if (signedInUser == null) {
      return false;
    }
    if (auth.currentUser == null) {
      GoogleSignInAuthentication googleAuth = await signedInUser.authentication;
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await auth.signInWithCredential(credential);
    }
    return auth.currentUser != null;
  }

  Future<void> signOut() async {
    await auth.signOut();
    await _googleSignIn.signOut();
  }

  Stream<User?> get authStateChanges => auth.authStateChanges();
}
