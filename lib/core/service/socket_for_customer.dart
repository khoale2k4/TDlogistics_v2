import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tdlogistic_v2/core/service/notification.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';

import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/customer/UI/screens/botton_navigator.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';

class SocketCustomerPage extends StatefulWidget {
  final User user;
  final String token;

  const SocketCustomerPage({required this.user, required this.token});

  @override
  _SocketCustomerPageState createState() => _SocketCustomerPageState();
}

class _SocketCustomerPageState extends State<SocketCustomerPage> {
  late String token;
  late NavigatePage childWidget;
  late IO.Socket socket;

  @override
  void initState() {
    token = widget.token;
    // userId = "123";
    print(widget.user.id);

    super.initState();
    childWidget = NavigatePage(
      user: widget.user,
      sendMessage: sendMessage,
    );
    connectSocket(widget.user.id!);
  }

  void sendMessage(String receiverId, String content) {
    socket.emit("message", {
      "receiverId": receiverId,
      "content": content,
    });
    print({
      "receiverId": receiverId,
      "content": content,
    });
  }

  void connectSocket(String userId) async {
    Future<void> showNotification(String title, String message) async {
      print("Đang hiển thị thông báo: $title - $message");
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        '123',
        'tdlogistic',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails();
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        message,
        platformChannelSpecifics,
        payload: 'new item',
      );
    }

    print('Bearer $token');
    String host = "http://localhost:3000/";
    socket = IO.io(
      host,
      IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
        'authorization': 'Bearer $token',
      }).build(),
    );
    try {
      socket.on('connect', (_) {
        print('Kết nối tới host $host thành công');
        //  _showNotification("Kết nối thành công");
      });

      socket.on('message', (data) async {
        if (data['category'] == 'ORDER' && data['type'] == 'PENDING') {
          showNotification("Đơn hàng mới", data['message']);
        } else if (data['category'] == 'ORDER' && data['type'] == "ACCEPTED") {
          showNotification("Đơn hàng được chấp nhận", data['message']);
        } else if(data['senderId'] != null) {
          showNotification("Tin nhắn mới!", "Bạn có một tin nhắn từ ...");
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
