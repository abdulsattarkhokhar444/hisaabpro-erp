import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // A01: Create User
  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String employeeId,
    String? territory,
  }) async {
    try {
    // 1. Auth mein user banao
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
    // 2. Firestore mein data save karo
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'name': name,
      'email': email,
      'role': role,
      'employeeId': employeeId,
      'territory': territory?? '',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      throw Exception('Password should be at least 6 characters');
    } else if (e.code == 'email-already-in-use') {
      throw Exception('Email already in use');
    } else {
      throw Exception('Failed to create user: ${e.message}');
    }
  }
}
  // A01: Get All Users Stream
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
       .collection('users')
       .where('isActive', isEqualTo: true) // Only active users
       .orderBy('createdAt', descending: true)
       .snapshots()
       .map((snapshot) => snapshot.docs
           .map((doc) => UserModel.fromMap(doc.data()))
           .toList());
  }

  // A01: Delete User
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  // A01: Deactivate User - SDD safe approach
  Future<void> deactivateUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isActive': false,
    });
  }
}