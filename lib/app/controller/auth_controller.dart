import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    checkLoginStatus(); // Periksa status login saat controller diinisialisasi
  }

  Future<void> checkLoginStatus() async {
    isLoggedIn.value = _prefs.containsKey('user_token');
  }

  Future<UserCredential> registerUser(String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.snackbar('Success', 'Registration successful',
          backgroundColor: Colors.green);
      _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'uid': userCredential.user!.uid, 'email': email});
      Get.offAllNamed('/login'); // Navigasi ke halaman Login
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', 'Registration failed: $e',
          backgroundColor: Colors.red);
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
      _prefs.setString('user_token', _auth.currentUser!.uid);
      Get.snackbar('Success', 'Login successful',
          backgroundColor: Colors.green);
      _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'uid': userCredential.user!.uid, 'email': email}, SetOptions(merge: true));
      Get.offAllNamed('/home');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', 'Login failed: $e', backgroundColor: Colors.red);
      throw Exception(e.code);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    _prefs.remove('user_token');
    isLoggedIn.value = false;
    _auth.signOut();
    Get.offAllNamed(
        '/welcome'); // Menghapus semua halaman dari stack dan kembali ke halaman login.
  }

}
