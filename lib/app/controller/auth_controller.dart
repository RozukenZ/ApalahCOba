import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SharedPreferences _prefs = Get.find<SharedPreferences>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    isLoggedIn.value = _prefs.containsKey('user_token');
  }

  Future<UserCredential> registerUser(String name, String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(seconds: 1));
      await updateFcmToken(userCredential.user!.uid);

      // Notifikasi berhasil menggunakan ScaffoldMessenger
      _showSnackbar('Success', 'Registration successful', Colors.green);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'isLogin': false,
      });

      Get.toNamed('/login');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      // Notifikasi gagal menggunakan ScaffoldMessenger
      _showSnackbar('Error', 'Registration failed: ${e.message}', Colors.red);

      throw Exception(e.code);
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential> loginUser(String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        bool isLoginInUse = userDoc['isLogin'] ?? false;
        if (isLoginInUse) {
          _showSnackbar(
            'Error',
            'Akun sedang digunakan di perangkat lain',
            Colors.red,
          );

          await _auth.signOut();
          isLoggedIn.value = false;
          return Future.error('Akun sedang digunakan di perangkat lain');
        } else {
          await Future.delayed(const Duration(seconds: 1)); // Simulasi penundaan
          await _prefs.setString('user_token', _auth.currentUser!.uid);

          _firestore.collection('users').doc(userCredential.user!.uid).set(
            {'uid': userCredential.user!.uid, 'email': email, 'isLogin': true},
            SetOptions(merge: true),
          );

          await updateFcmToken(userCredential.user!.uid);

          _showSnackbar('Success', 'Login successful', Colors.green);

          Get.toNamed('/home');
          isLoggedIn.value = true;
          return userCredential;
        }
      } else {
        throw Exception("User data not found in Firestore");
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      _showSnackbar('Error', 'Login failed: ${e.message}', Colors.red);

      return Future.error('Login failed: ${e.message}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserName(String uid, String newName) async {
    try {
      isLoading.value = true; // Indikator proses sedang berjalan

      await _firestore.collection('users').doc(uid).update({'name': newName});

      _showSnackbar(
        'Success',
        'Name updated successfully',
        Colors.green,
      );

      Get.back();
    } catch (e) {
      _showSnackbar(
        'Error',
        'Failed to update name: $e',
        Colors.red,
      );
      throw Exception('Failed to update name: $e');
    } finally {
      isLoading.value = false; // Selesaikan proses loading
    }
  }

  Future<void> updateFcmToken(String uid) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      await _firestore.collection('users').doc(uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      _prefs.setString('user_token', uid);
    }
  }

  void logout() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .set({'isLogin': false, 'fcmToken': FieldValue.delete()}, SetOptions(merge: true));
    _prefs.remove('user_token');
    isLoggedIn.value = false;
    _auth.signOut();
    Get.offAllNamed('/welcome');
  }

  // Metode untuk menampilkan notifikasi menggunakan ScaffoldMessenger
  void _showSnackbar(String title, String message, Color backgroundColor) {
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title: $message'),
          backgroundColor: backgroundColor,
        ),
      );
    } else {
      debugPrint("Unable to show snackbar because context is null.");
    }
  }

}
