import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateNameScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Ambil UID pengguna
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Username'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('Error fetching user data');
                }

                // Menampilkan nama lama
                var userData =
                snapshot.data!.data() as Map<String, dynamic>;
                String currentName = userData['name'] ?? 'No Name';
                nameController.text = currentName;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Name:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentName,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter new name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tombol Update Name dengan animasi saat ditekan
            GestureDetector(
              onTap: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  if (uid!.isNotEmpty) {
                    await updateUserName(context, uid, newName);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('User not logged in'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Name cannot be empty'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Material(
                color: nameController.text.isEmpty
                    ? Colors.grey.withOpacity(0.6)
                    : Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () async {
                    String newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      if (uid!.isNotEmpty) {
                        await updateUserName(context, uid, newName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('User not logged in'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Name cannot be empty'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Ink(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Update Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateUserName(BuildContext context, String uid, String newName) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'name': newName});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Name updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update name: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
