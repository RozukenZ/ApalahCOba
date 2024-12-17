import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demomodul1pemmob/app/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/connectivity_controller.dart';
import '../../controller/mic_controller.dart';
import '../../controller/controller_tts.dart';
import '../../controller/location_controller.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({
    Key? key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Controller Initializations
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FocusNode _focusNode = FocusNode();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final GetStorage _storage = GetStorage();

  // GetX Controllers
  late HomeController _homeController;
  late TTSController _ttsController;
  late LocationController _locationController;
  late ConnectivityController _connectivityController;

  String? _editingMessageId;

  @override
  void initState() {
    super.initState();

    // Initialize GetX Controllers
    _homeController = Get.put(HomeController());
    _ttsController = Get.put(TTSController());
    _locationController = Get.put(LocationController());
    _connectivityController = Get.put(ConnectivityController());

    // Initialize home controller
    _homeController.onInit();

    // Listen to connectivity changes
    ever(_connectivityController.isConnected, (isConnected) {
      if (isConnected) {
        // Sync offline messages when connection is restored
        _syncOfflineMessages();
      } else {
        _showOfflineWarning();
      }
    });
  }

  @override
  void dispose()
  {
    // Clean up controllers
    _homeController.stopListening();
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  void _showOfflineWarning()
  {
    Get.snackbar(
      'No Internet',
      'Connection Lost. Messages may not be sent.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void sendMessages() async {
    // Check if message is empty
    if (_messageController.text.trim().isEmpty) return;

    // Check connectivity
    if (!_connectivityController.isConnected.value) {
      _saveOfflineMessage(_messageController.text.trim());
      _showOfflineWarning();
      _messageController.clear();
      return;
    }

    try {
      if (_editingMessageId != null) {
        await _chatService.editMessage(
          _getChatRoomId(),
          _editingMessageId!,
          _messageController.text.trim(),
        );
        _editingMessageId = null;
      } else {
        await _chatService.sendMessage(
          widget.receiverUserID,
          _messageController.text.trim(),
        );
      }

      // Clear input and scroll to bottom
      _messageController.clear();
      _focusNode.requestFocus();
      _scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Send Error',
        'Unable to send message: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _saveOfflineMessage(String message)
  {
    List<dynamic> offlineMessages = _storage.read('offline_messages') ?? [];
    offlineMessages.add({
      'message': message,
      'receiverUserId': widget.receiverUserID,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _storage.write('offline_messages', offlineMessages);
  }

  void _syncOfflineMessages() async {
    List<dynamic> offlineMessages = _storage.read('offline_messages') ?? [];

    if (offlineMessages.isNotEmpty) {
      for (var messageData in offlineMessages) {
        try {
          await _chatService.sendMessage(
              messageData['receiverUserId'],
              messageData['message']
          );
        } catch (e) {
          print('Failed to send offline message: $e');
        }
      }

      // Clear offline messages after sending
      _storage.remove('offline_messages');
    }
  }

  Future<void> _deleteMessage(String chatRoomId, String messageId) async {
    await _chatService.deleteMessage(chatRoomId, messageId);
  }

  void _editMessage(String chatRoomId, String messageId, String currentMessage) {
    _editingMessageId = messageId;
    _messageController.text = currentMessage;
  }

  void _scrollToBottom()
  {
    if (_scrollController.hasClients)
    {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showMessageOptions(String chatRoomId, String messageId, String currentMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose an option"),
          actions: [
            TextButton(
              onPressed: ()
              {
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
              onPressed: () async {
                // Memanggil fungsi TTS untuk membaca pesan
                await _ttsController.speak(currentMessage);
                Navigator.pop(context);
              },
              child: const Text("Read Message"),
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

  String _getChatRoomId()
  {
    List<String> ids = [widget.receiverUserID, _firebaseAuth.currentUser!.uid];
    ids.sort();
    return ids.join("_");
  }

  Widget _buildMessageList()
  {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUserID,
          _firebaseAuth.currentUser!.uid
      ),
      builder: (context, snapshot)
      {
        // Error handling
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading messages: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting)
        {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF00A884),
            ),
          );
        }

        // No messages
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet',
              style: TextStyle(color: Colors.grey),
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
  Widget _buildMessageItem(DocumentSnapshot document)
  {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.uid;
    String messageId = document.id;
    String chatRoomId = _getChatRoomId();

    Timestamp timestamp = data['timestamp'];
    String formattedTime = DateFormat.jm().format(timestamp.toDate());
    String message = data['message'] ?? "Pesan telah dihapus";

    // New status tracking
    bool isSent = data['isSent'] ?? false;
    bool isDelivered = data['isDelivered'] ?? false;
    bool isRead = data['isRead'] ?? false;

    // Fungsi untuk membuka URL
    Future<void> _launchURL(String url) async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    }

    // Periksa apakah pesan adalah URL
    final bool isUrl = message.startsWith('http://') || message.startsWith('https://');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onLongPress: () async {
          if (isCurrentUser) {
            _showMessageOptions(chatRoomId, messageId, message);
          } else {
            await _ttsController.speak(message);
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: isUrl
                          ? GestureDetector(
                        onTap: () => _launchURL(message),
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      )
                          : Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Status Indicator for sent messages
                    if (isCurrentUser)
                      Icon(
                        isRead
                            ? Icons.done_all
                            : isDelivered
                            ? Icons.done_all
                            : isSent
                            ? Icons.done
                            : Icons.access_time,
                        color: isRead
                            ? Colors.blue
                            : Colors.white54,
                        size: 16,
                      ),
                  ],
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
              _homeController.startListening();
            },
            onLongPressEnd: (details) {
              _homeController.stopListening();
              _messageController.text = _homeController.text.value;
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.mic, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.red),
            onPressed: () => _locationController.shareLocation(widget.receiverUserID),
          ),

          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              sendMessages();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
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
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _connectivityController.isConnected.value
                        ? 'Online'
                        : 'Offline',
                    style: TextStyle(
                        color: _connectivityController.isConnected.value
                            ? Colors.grey
                            : Colors.red,
                        fontSize: 12
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
      bottomSheet: !_connectivityController.isConnected.value
          ? Container(
        color: Colors.red,
        padding: const EdgeInsets.all(8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.signal_wifi_off, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'No Internet Connection',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      )
          : null,
    ));
  }
}