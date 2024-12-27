import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UpdateNameScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Ambil UID pengguna
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Username'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Text('Error fetching user data');
                }

                // Menampilkan nama lama
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                String currentName = userData['name'] ?? 'No Name';
                nameController.text = currentName;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Name:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      currentName,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              },
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter new name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  if (uid != null) {
                    await updateUserName(uid, newName);
                  } else {
                    Get.snackbar(
                      'Error',
                      'User not logged in',
                      backgroundColor: Colors.red,
                    );
                  }
                } else {
                  Get.snackbar(
                    'Error',
                    'Name cannot be empty',
                    backgroundColor: Colors.red,
                  );
                }
              },
              child: Text('Update Name'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateUserName(String uid, String newName) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'name': newName});
      Get.snackbar(
        'Success',
        'Name updated successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update name: $e',
        backgroundColor: Colors.red,
      );
    }
  }
}
