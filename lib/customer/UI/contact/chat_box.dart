import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/customer/UI/contact/call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String theirName;
  final String theirPhone;

  const ChatScreen({super.key, required this.theirName, required this.theirPhone});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [
    {'sender': 'customer', 'content': 'Chào shipper!', 'timestamp': DateTime.now()},
    {'sender': 'shipper', 'content': 'Chào bạn! Mình sắp đến.', 'timestamp': DateTime.now()},
    {'sender': 'customer', 'content': 'Cảm ơn nhé!', 'timestamp': DateTime.now()},
  ];

  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({
          'sender': 'customer', 
          'content': _messageController.text.trim(),
          'timestamp': DateTime.now(),
        });
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.theirName,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  widget.theirPhone,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    name: widget.theirName,
                    phoneNumber: widget.theirPhone, 
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Cuộn từ dưới lên
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - index - 1];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isCustomer = message['sender'] == 'customer';
    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCustomer ? Colors.red.shade100 : Colors.green.shade100,
          borderRadius: BorderRadius.circular(12).copyWith(
            topLeft: isCustomer ? const Radius.circular(12) : Radius.zero,
            topRight: isCustomer ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Text(
          message['content'],
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: () {
              // Đính kèm ảnh
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: mainColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
