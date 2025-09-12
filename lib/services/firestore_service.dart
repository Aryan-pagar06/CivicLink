import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Updated uploadImage function to be cross-platform
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = 'issues/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final imageRef = storageRef.child(fileName);

      if (kIsWeb) {
        // Upload bytes for web
        final bytes = await imageFile.readAsBytes();
        await imageRef.putData(bytes);
      } else {
        // Upload file for mobile
        await imageRef.putFile(File(imageFile.path));
      }

      final downloadUrl = await imageRef.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage Error: ${e.code}');
      print('Details: ${e.message}');
      return null;
    } catch (e) {
      print('Other upload error: $e');
      return null;
    }
  }

  Future<bool> saveIssueReport(String collectionName, Map<String, dynamic> issueData) async {
    try {
      await _db.collection(collectionName).add(issueData);
      return true;
    } on FirebaseException catch (e) {
      print('Firebase Firestore Error: ${e.code}');
      print('Details: ${e.message}');
      return false;
    } catch (e) {
      print('Other save error: $e');
      return false;
    }
  }

  Stream<QuerySnapshot> getAllIssues() {
    return _db
        .collection('issues')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getIssuesByDepartment(String department) {
    return _db
        .collection('issues')
        .where('assignedDepartment', isEqualTo: department)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}