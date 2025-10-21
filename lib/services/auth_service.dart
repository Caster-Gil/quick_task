import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      // Trigger the authentication flow
      final googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      // Since tokens are not accessible, use signInWithPopup or signInWithCredential from Firebase Auth if possible.
      // BUT for mobile, we can't do signInWithPopup.

      // Alternative: use signInWithCredential with OAuthProvider

      // Create an OAuthProvider for Google
      final googleProvider = OAuthProvider("google.com");

      // Sign in with Firebase using the OAuthProvider
      final userCredential = await _auth.signInWithProvider(googleProvider);
      
      return userCredential.user;

    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}