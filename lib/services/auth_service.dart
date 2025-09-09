import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login with Email/Password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // Send OTP to Aadhaar (Simulated)
  Future<bool> sendAadhaarOTP(String aadhaarNumber) async {
    // In real app, integrate with SMS API
    await Future.delayed(Duration(seconds: 2));
    return true; // Simulated success
  }

  // Verify Aadhaar OTP
  Future<User?> verifyAadhaarOTP(String aadhaarNumber, String otp) async {
    // Simulated verification
    if (otp == "123456") { // Hardcoded for demo
      // Check if user exists with this Aadhaar
      final user = await _getUserByAadhaar(aadhaarNumber);
      return user;
    }
    return null;
  }

  // Register new user
  Future<User?> registerUser({
    required String email,
    required String password,
    required String fullName,
    required int age,
    required String gender,
    required String aadhaarNumber,
    required GeoPoint location,
  }) async {
    try {
      // 1. Create auth account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'fullName': fullName,
        'age': age,
        'gender': gender,
        'aadhaarNumber': aadhaarNumber,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } catch (e) {
      print("Registration error: $e");
      return null;
    }
  }

  // Helper method to find user by Aadhaar
  Future<User?> _getUserByAadhaar(String aadhaarNumber) async {
    final snapshot = await _firestore.collection('users')
        .where('aadhaarNumber', isEqualTo: aadhaarNumber)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userDoc = snapshot.docs.first;
      return _auth.currentUser; // Return current user or fetch by UID
    }
    return null;
  }
}