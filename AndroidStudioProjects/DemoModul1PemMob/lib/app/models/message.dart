import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final Timestamp timestamp;
  final String message;
  final bool isSent;
  final bool isDelivered;
  final bool isRead;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.timestamp,
    required this.message,
    this.isSent = false,
    this.isDelivered = false,
    this.isRead = false,
  });

  // Convert Message object to a Map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'message': message,
      'isSent': isSent,
      'isDelivered': isDelivered,
      'isRead': isRead,
    };
  }

  // Convert Map to Message object
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      senderEmail: map['senderEmail'],
      receiverId: map['receiverId'],
      timestamp: map['timestamp'],
      message: map['message'],
      isSent: map['isSent'] ?? false,
      isDelivered: map['isDelivered'] ?? false,
      isRead: map['isRead'] ?? false,
    );
  }
}
