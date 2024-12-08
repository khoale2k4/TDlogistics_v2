import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_bloc.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_event.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_state.dart';

class ChatScreen extends StatefulWidget {
  final String theirName;
  final String theirPhone;
  final String receiverId;
  final Function(String, String) sendMessage;

  const ChatScreen(
      {super.key,
      required this.theirName,
      required this.theirPhone,
      required this.receiverId,
      required this.sendMessage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  int page = 1;
  bool _isLoadingMore = false;
  @override
  void initState() {
    super.initState();
    // Gọi API lần đầu tiên để tải tin nhắn
    context.read<GetChatShipBloc>().add(GetChatWithCus(
          receiverId: widget.receiverId,
          page: page,
        ));

    // Lắng nghe sự kiện cuộn
    _scrollController.addListener(() {
      // Kiểm tra nếu cuộn đến đầu danh sách thì tải thêm tin nhắn
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 50) {
        _loadMoreMessages();
      }
    });
  }

  void _loadMoreMessages() {
    // Kiểm tra nếu đã tải hết dữ liệu (không có thêm tin nhắn)
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true; // Đánh dấu trạng thái đang tải
    });

    // Gọi API tải thêm tin nhắn
    context.read<GetChatShipBloc>().add(GetChatWithCus(
          receiverId: widget.receiverId,
          page: page,
        ));
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
      ),
      body: BlocListener<GetChatShipBloc, TaskState>(
        listener: (context, state) {
          if (state is GetChatWithCusSuccess) {
            if (state.messages.isNotEmpty) {
              print(page);
              setState(() {
                messages = [
                  ...state.messages.map((msg) => msg.toJson()),
                  ...messages
                ];
                if (state.messages.isNotEmpty) {
                  page++; // Chỉ tăng page khi có tin nhắn mới
                }
              });
            }
            setState(() {
              _isLoadingMore = false; // Hoàn thành việc tải
            });
          } else if (state is ReceiveMessage) {
            setState(() {
              messages.add(state.message);
            });
          } else if (state is GetChatWithCusFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.error}')),
            );
            setState(() {
              _isLoadingMore = false; // Xử lý xong lỗi
            });
          }
        },
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                context.read<GetChatShipBloc>().add(GetChatWithCus(
                      receiverId: widget.receiverId,
                      page: page,
                    ));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context)
                        .size
                        .height, // Ensure full height
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (messages.isEmpty)
                        const Center(child: CircularProgressIndicator())
                      else
                        ListView.builder(
                          controller: _scrollController,
                          reverse: true, // Cuộn từ dưới lên
                          shrinkWrap: true, // Cho phép danh sách co giãn
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                messages[messages.length - index - 1];
                            return _buildMessageBubble(message);
                          },
                        ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: _buildMessageInput(),
              ),
            ),
          ],
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
            onPressed: () {
              // Gửi tin nhắn
              widget.sendMessage(widget.receiverId, _messageController.text);
              setState(() {
                messages.add({
                  'receiverId': widget.receiverId,
                  'content': _messageController.text
                });
                _messageController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isCustomer = message['receiverId'] == widget.receiverId;
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

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
