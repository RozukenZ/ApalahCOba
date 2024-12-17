import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demomodul1pemmob/app/views/chat/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Chats'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        var filteredDocs = snapshot.data!.docs.where((doc) {
          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          String email = data['email'].toLowerCase();
          return email.contains(_searchQuery);
        }).toList();

        return ListView(
          children: filteredDocs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // Pastikan pengguna yang berbeda bisa melihat chat masing-masing
    if (_firebaseAuth.currentUser!.email != data['email']) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(data['profilePicture'] ?? 'https://via.placeholder.com/150'),
          ),
          title: Text(
            data['email'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          subtitle: StreamBuilder<QuerySnapshot>(
            // Perubahan: Gunakan chat room ID yang unik untuk setiap pasangan pengguna
            stream: FirebaseFirestore.instance
                .collection('chat_rooms')
                .doc(_generateChatRoomId(data['uid']))
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  'Loading...',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  'Error fetching last message',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                );
              }

              if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                var lastMessage = snapshot.data!.docs.first;
                return Text(
                  lastMessage['message'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              } else {
                return Text(
                  'No messages yet',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                );
              }
            },
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chat_rooms')
                    .doc(_generateChatRoomId(data['uid']))
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Loading...',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Error',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    );
                  }

                  if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                    var lastMessage = snapshot.data!.docs.first;
                    bool isRead = lastMessage['isRead'] ?? false; // Cek status isRead
                    var timestamp = (lastMessage['timestamp'] as Timestamp).toDate();
                    String time = '${timestamp.hour}:${timestamp.minute}';

                    return Column(
                      children: [
                        Text(
                          time, // Menampilkan waktu pesan
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 5),
                        // Jika pesan belum dibaca, tampilkan centang hijau
                        if (!isRead)
                          const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    );
                  } else {
                    return Text(
                      'No messages yet',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    );
                  }
                },
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserEmail: data['email'],
                  receiverUserID: data['uid'],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  String _generateChatRoomId(String receiverUID) {
    return _firebaseAuth.currentUser!.uid.hashCode < receiverUID.hashCode
        ? '${_firebaseAuth.currentUser!.uid}_${receiverUID}'
        : '${receiverUID}_${_firebaseAuth.currentUser!.uid}';
  }
}
