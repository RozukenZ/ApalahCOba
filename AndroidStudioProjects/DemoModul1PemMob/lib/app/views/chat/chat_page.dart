import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demomodul1pemmob/app/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FocusNode _focusNode = FocusNode();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  String? _editingMessageId;

  void sendMessages() async {
    if (_messageController.text.isNotEmpty) {
      if (_editingMessageId != null) {
        // If editing, update the message
        await _chatService.editMessage(
            _getChatRoomId(), _editingMessageId!, _messageController.text);
        _editingMessageId = null;
      } else {
        // If sending new message
        await _chatService.sendMessage(
            widget.receiverUserID, _messageController.text);
      }
      _messageController.clear();
      _focusNode.requestFocus(); // Set focus back to the text field
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _deleteMessage(String chatRoomId, String messageId) async {
    await _chatService.deleteMessage(chatRoomId, messageId);
  }

  void _editMessage(String chatRoomId, String messageId, String currentMessage) {
    _editingMessageId = messageId;
    _messageController.text = currentMessage;
  }

  void _showMessageOptions(String chatRoomId, String messageId, String currentMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose an option"),
          actions: [
            TextButton(
              onPressed: () {
                _editMessage(chatRoomId, messageId, currentMessage);
                Navigator.pop(context);
              },
              child: const Text("Edit"),
            ),
            TextButton(
              onPressed: () async {
                await _deleteMessage(chatRoomId, messageId);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  String _getChatRoomId() {
    List<String> ids = [widget.receiverUserID, _firebaseAuth.currentUser!.uid];
    ids.sort();
    return ids.join("_");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121B22), // WhatsApp dark theme background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2C34), // WhatsApp dark theme header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: Text(
                widget.receiverUserEmail[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverUserEmail,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.grey),
            onPressed: () {
              // Ini untuk VideoCall
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.grey),
            onPressed: () {
              // Ini untuk telpon biasa
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              // Ini untuk fitur tambahan
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://i.pinimg.com/originals/97/c0/07/97c00759d90d786d9b6096d274ad3e07.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF00A884), // WhatsApp green
            ),
          );
        }

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.uid;
    String messageId = document.id;
    String chatRoomId = _getChatRoomId();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onLongPress: () {
          if (isCurrentUser) {
            _showMessageOptions(chatRoomId, messageId, data['message']);
          }
        },
        child: Align(
          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? const Color(0xFF005C4B)
                  : const Color(0xFF1F2C34),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['message'] ?? "Pesan telah dihapus",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '12:00 PM',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: const Color(0xFF1F2C34),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode, // Associate the FocusNode here
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2D3A3D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                sendMessages(); // Send message when Enter is pressed
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF00A884)),
            onPressed: sendMessages,
          ),
        ],
      ),
    );
  }
}