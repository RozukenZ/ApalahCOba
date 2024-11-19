import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demomodul1pemmob/app/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controller/mic_controller.dart'; // Import HomeController di sini

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
  final HomeController _homeController = HomeController(); // Inisialisasi HomeController

  void sendMessages() async {
    if (_messageController.text.isNotEmpty) {
      if (_editingMessageId != null) {
        await _chatService.editMessage(
            _getChatRoomId(), _editingMessageId!, _messageController.text);
        _editingMessageId = null;
      } else {
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
    List<String> ids = [widget.receiverUserID, _firebaseAuth.currentUser !.uid];
    ids.sort();
    return ids.join("_");
  }

  @override
  void initState() {
    super.initState();
    _homeController.onInit(); // Inisialisasi HomeController
  }

  @override
  void dispose() {
    _homeController.stopListening(); // Hentikan mendengarkan ketika halaman dibuang
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121B22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2C34),
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
                  fontWeight: FontWeight.bold ),
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
    // Video call functionality
    },
    ),
    IconButton(
    icon: const Icon(Icons.call, color: Colors.grey),
    onPressed: () {
    // Phone call functionality
    },
    ),
    IconButton(
    icon: const Icon(Icons.more_vert, color: Colors.grey),
    onPressed: () {
    // Additional features
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
          widget.receiverUserID, _firebaseAuth.currentUser  !.uid),
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
              color: Color(0xFF00A884),
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
    bool isCurrentUser  = data['senderId'] == _firebaseAuth.currentUser  !.uid;
    String messageId = document.id;
    String chatRoomId = _getChatRoomId();

    Timestamp timestamp = data['timestamp'];
    String formattedTime = DateFormat.jm().format(timestamp.toDate());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onLongPress: () {
          if (isCurrentUser ) {
            _showMessageOptions(chatRoomId, messageId, data['message']);
          }
        },
        child: Align(
          alignment: isCurrentUser  ? Alignment.centerRight : Alignment.centerLeft,
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
                bottomLeft: Radius.circular(isCurrentUser  ? 16 : 4),
                bottomRight: Radius.circular(isCurrentUser  ? 4 : 16),
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
                  formattedTime,
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
              focusNode: _focusNode,
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
                sendMessages();
              },
            ),
          ),
          GestureDetector(
            onLongPressStart: (details) {
              _homeController.startListening(); // Mulai mendengarkan suara
            },
            onLongPressEnd: (details) {
              _homeController.stopListening(); // Hentikan mendengarkan suara
              _messageController.text = _homeController.text.value; // Update TextField dengan teks yang dikenali
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.mic, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              sendMessages(); // Kirim pesan saat tombol send ditekan
            },
          ),
        ],
      ),
    );
  }
}