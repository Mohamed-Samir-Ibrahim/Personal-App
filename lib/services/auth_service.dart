import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_app/models/user_model.dart';
import 'package:personal_app/services/encrypt_decrypt_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  AuthService() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (userDoc.exists) {
          _currentUser = UserModel.fromMap(
            userDoc.data() as Map<String, dynamic>,
          );
        } else {
          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<UserModel?> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? profileImageUrl,
  }) async {
    try {
      final hashedPassword = EncryptionService.hashPassword(password);
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: hashedPassword.trim(),
          );

      await userCredential.user!.updateDisplayName(name);

      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone,
        profileImageUrl: profileImageUrl,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toMap());

      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      print('Error in Register: $e');
      return null;
    }
  }

  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final hashedPassword = EncryptionService.hashPassword(password);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: hashedPassword.trim(),
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        _currentUser = UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
        );
        notifyListeners();
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Error in Login: $e');
      return null;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Stream<UserModel?> get currentUserStream {
    return _auth.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (userDoc.exists) {
          return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        }
      }
      return null;
    });
  }

  // services/auth_service.dart - أضف هذه الدالة
  Future<bool> updateProfileImage(String userId, String imageUrl) async {
    try {
      // تحديث في Firestore
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // تحديث المستخدم الحالي في الذاكرة
      if (_currentUser != null && _currentUser!.uid == userId) {
        _currentUser!.profileImageUrl = imageUrl;
        notifyListeners();
      }

      return true;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }

  // تأكد أن دالة updateUserProfile تدعم تحديث الصورة
  Future<void> updateUserProfile(UserModel user) async {
    try {
      // تحديث display name في Firebase Auth إذا تغير
      if (_auth.currentUser != null &&
          _auth.currentUser!.displayName != user.name) {
        await _auth.currentUser!.updateDisplayName(user.name);
      }

      // تحديث بيانات المستخدم في Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': user.name,
        'phone': user.phone,
        'profileImageUrl': user.profileImageUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // تحديث المستخدم الحالي في الذاكرة
      if (_currentUser != null && _currentUser!.uid == user.uid) {
        _currentUser!.name = user.name;
        _currentUser!.phone = user.phone;
        _currentUser!.profileImageUrl = user.profileImageUrl;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}
