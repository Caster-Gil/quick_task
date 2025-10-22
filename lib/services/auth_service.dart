import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Email/Password SignUp Error: $e");
      return null;
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Email/Password SignIn Error: $e");
      return null;
    }
  }

  // Sign in with Google
  static Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final googleProvider = OAuthProvider("google.com");
      final userCredential = await _auth.signInWithProvider(googleProvider);

      return userCredential.user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}