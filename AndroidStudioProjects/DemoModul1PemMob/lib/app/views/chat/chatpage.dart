import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final String sender;

  const ChatPage({super.key, required this.sender});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _nexmoApiKey = 'faca1c7f';
  final _nexmoApiSecret = 'g3KHe1M71SDSYQSK';
  final _nexmoFromNumber = '+62 896 1666 906';

  Future<void> _sendMessage() async {
    final response =
        await http.post(Uri.parse('https://rest.nexmo.com/sms/json'), headers: {
      'Authorization':
          'Basic ${base64Encode(utf8.encode('$_nexmoApiKey:$_nexmoApiSecret'))}',
    }, body: {
      'from': _nexmoFromNumber,
      'to': 'YOUR_RECIPIENT_NUMBER',
      'text': _messageController.text,
    });

    if (response.statusCode == 200) {
      print('Message sent successfully!');
      _messageController.clear();
    } else {
      print('Failed to send message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat dengan ${widget.sender}'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Type a message...',
            ),
          ),
          ElevatedButton(
            onPressed: _sendMessage,
            child: Text('Send'),
          ),
        ],
      ),
    );
  }
}
