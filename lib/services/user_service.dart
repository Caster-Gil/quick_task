import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'name': user.displayName ?? 'Unnamed User',
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'projects': [], // empty list, can later hold joined projects
      });
    }
  }
}
