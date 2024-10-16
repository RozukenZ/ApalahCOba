import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for JSON decoding

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _apiUrl = 'http://localhost:3000';
  List<dynamic> _messages = []; // List to store messages

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Fetch messages when the screen is initialized
  }

  Future<void> _fetchMessages() async {
    final response = await http.get(Uri.parse('$_apiUrl/messages'));

    if (response.statusCode == 200) {
      setState(() {
        _messages = json.decode(response.body); // Decode the JSON response
      });
    } else {
      print('Failed to load messages');
    }
  }

  Future<void> _sendMessage() async {
    final response = await http.post(
      Uri.parse('$_apiUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'sender': 'Alice',
        'receiver': 'Bob',
        'message': 'Halo, apa kabar?',
      }),
    );

    if (response.statusCode == 201) {
      print('Pesan terkirim!');
      _fetchMessages(); // Refresh the message list after sending a message
    } else {
      print('Gagal mengirim pesan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text('${message['sender']}: ${message['message']}'),
                  subtitle: Text(message['timestamp']),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _sendMessage,
            child: Text('Kirim Pesan'),
          ),
        ],
      ),
    );
  }
}
