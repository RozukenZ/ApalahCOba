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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading...');
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

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
            backgroundImage: NetworkImage(data['profilePicture'] ?? 'https://via.placeholder.com/150'), // Placeholder if no profile picture
          ),
          title: Text(
            data['email'],
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            'Last message here...', // Assuming you have a 'lastMessage' field
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              overflow: TextOverflow.ellipsis, // Hide text overflow
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '12:30 PM', // Placeholder for last message time
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 5),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.green, // Status indicator (e.g., online)
                child: Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
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

}
