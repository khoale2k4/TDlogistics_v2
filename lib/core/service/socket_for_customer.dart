import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/service/notification.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';

import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/customer/UI/screens/botton_navigator.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';

class SocketCustomerPage extends StatefulWidget {
  final User user;
  final String token;
  final int start;

  const SocketCustomerPage({super.key, required this.user, required this.token, required this.start});

  @override
  _SocketCustomerPageState createState() => _SocketCustomerPageState();
}

class _SocketCustomerPageState extends State<SocketCustomerPage> {
  late String token;
  late NavigatePage childWidget;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    token = widget.token;
    childWidget = NavigatePage(
      user: widget.user,
      sendMessage: sendMessage,
      start: widget.start
    );
    // print(widget.user.toJson());
    connectSocket(widget.user.id??"");
  }

  void sendMessage(String receiverId, String content) {
    socket.emit("message", [{
      "receiverId": receiverId,
      "content": content,
    }]);
  }

  void connectSocket(String userId) async {
    print('Bearer $token');
    try {
      socket = IO.io(
        host,
        IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
          'authorization': 'Bearer $token',
        }).build(),
      );
      socket.on('connect', (_) {
        print('Kết nối tới host $host thành công');
        //  _showNotification("Kết nối thành công");
      });

      socket.on('message', (data) async {
        if (data['category'] == 'ORDER' && data['type'] == 'PENDING') {
          showNotification("Đơn hàng mới", data['message'], 'new order');
        } else if (data['category'] == 'ORDER' && data['type'] == "ACCEPTED") {
          showNotification("Đơn hàng được chấp nhận", data['message'], 'new order');
        } else if (data['senderId'] != null) {
          showNotification("Tin nhắn mới!", "Bạn có một tin nhắn từ ...", 'new message');
          context.read<GetChatBloc>().add(NewMessage(data['content'], " "));
        }
      });

      socket.on('error', (error) {
        print('Lỗi: $error');
      });

      socket.on('disconnect', (_) {
        print('Ngắt kết nối');
      });

      socket.connect();
    } catch (e) {
      print('Unable to connect: $e');
    }
  }

  void disconnect() {
    socket.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: childWidget), // Hiển thị widget tin nhắn
      ],
    );
  }
}
