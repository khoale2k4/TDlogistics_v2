import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/customer/UI/contact/chat_box.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Nguyễn Văn A',
      'phone' : "0123123123",
      'lastMessage': 'Xin chào, hàng của tôi đã đến chưa?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'name': 'Lê Thị B',
      'phone' : "0321231123",
      'lastMessage': 'Cảm ơn shipper nhé!',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
  ];

  void _addNewChat(String name, String phoneNumber) {
    setState(() {
      chats.add({
        'name': name,
        'phone' : phoneNumber,
        'lastMessage': '...',
        'timestamp': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          "Danh sách trò chuyện",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: chats.isEmpty
          ? _buildEmptyChatList()
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatCard(chat);
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "chat_list_fab",
        onPressed: () => _showAddChatDialog(),
        backgroundColor: mainColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyChatList() {
    return const Center(
      child: Text(
        'Không có cuộc trò chuyện nào',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Text(chat['name'][0],
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(
          chat['name'] + " (${chat['phone']})",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          chat['lastMessage'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          _formatTimestamp(chat['timestamp']),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                theirName: chat['name'],
                theirPhone: chat['phone'],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddChatDialog() {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController phoneController = TextEditingController();
        final TextEditingController nameController = TextEditingController();

        return AlertDialog(
          title: const Text("Thêm cuộc trò chuyện mới"),
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // Đảm bảo hộp thoại chỉ chiếm không gian cần thiết
            children: [
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "Nhập số điện thoại",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16), // Thêm khoảng cách giữa các trường
              TextField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "Nhập tên gợi nhớ",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              onPressed: () {
                if (phoneController.text.isNotEmpty) {
                  _addNewChat(nameController.text, phoneController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Thêm", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}
