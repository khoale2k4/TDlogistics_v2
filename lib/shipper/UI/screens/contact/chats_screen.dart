import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/shipper/UI/screens/contact/chat_box.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_bloc.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_event.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_state.dart';

class ChatListScreen extends StatefulWidget {
  final Function(String, String) sendMessage;
  const ChatListScreen({super.key, required this.sendMessage});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GetChatsShipBloc>().add(const GetChats());
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
      body: BlocBuilder<GetChatsShipBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskFeeCalculating) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetChatsSuccess) {
            if (state.chats.isEmpty) {
              return _buildEmptyChatList();
            }
            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                return _buildChatCard(chat.toJson());
              },
            );
          } else if (state is GetChatsFailure) {
            return Center(
              child: Text(
                'Lỗi khi tải danh sách trò chuyện: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const Center(child: Text('Đang tải...'));
        },
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
          child: Text(chat['receiverId']??"", style: const TextStyle(color: Colors.white)),
        ),
        title: Text(
          '${chat['fullname']} (${chat['phone']})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        // subtitle: Text(
        //   chat['lastMessage'],
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        //   style: const TextStyle(color: Colors.grey),
        // ),
        // trailing: Text(
        //   _formatTimestamp(chat['timestamp']),
        //   style: const TextStyle(color: Colors.grey, fontSize: 12),
        // ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                theirName: chat['name']??"No Name",
                theirPhone: chat['phone']??"No Phone",
                receiverId: chat['receiverId'],
                sendMessage: widget.sendMessage,
              ),
            ),
          );
        },
      ),
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
