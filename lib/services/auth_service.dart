import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  // Sign up with email and password
  Future<String?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send email verification
      await result.user?.sendEmailVerification();
      
      // Create user profile in Firestore
      await _firestore.collection('users').doc(result.user?.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'notificationEnabled': true,
        'emailUpdates': true,
      });
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
       //Check if email is verified
       if (result.user != null && !result.user!.emailVerified) {
        await _auth.signOut();
        return 'Please verify your email before signing in';
      }
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // Get user settings
  Future<Map<String, dynamic>?> getUserSettings() async {
    if (currentUser == null) return null;
    
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    
    return doc.data() as Map<String, dynamic>?;
  }

  // Update user settings
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    if (currentUser == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .update(settings);
    
    notifyListeners();
  }
}
