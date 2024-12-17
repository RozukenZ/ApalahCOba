import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demomodul1pemmob/app/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message, {required bool isSent}) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // Initialize the message with "isSent" set to false initially
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
      isSent: false, // Initially not sent
      isDelivered: false, // Initially not delivered
      isRead: false, // Initially not read
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Send the message to Firestore
    DocumentReference messageRef = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    await messageRef.update({'isSent': true});
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Display messages in chronological order
        .snapshots();
  }

  Future<void> updateMessageStatus({
    required String chatRoomId,
    required String messageId,
    bool? isSent,
    bool? isDelivered,
    bool? isRead,
  }) async {
    Map<String, dynamic> updates = {};

    if (isSent != null) updates['isSent'] = isSent;
    if (isDelivered != null) updates['isDelivered'] = isDelivered;
    if (isRead != null) updates['isRead'] = isRead;

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update(updates);
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> editMessage(String chatRoomId, String messageId, String newMessageContent) async {
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'message': newMessageContent,
      'timestamp': Timestamp.now(), // Update the timestamp if needed
    });
  }
}
