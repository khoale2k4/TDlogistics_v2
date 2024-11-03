// ignore_for_file: library_prefixes

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/service/notification.dart';

import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/shipper/UI/screens/botton_navigator.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_bloc.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_event.dart';
import 'package:tdlogistic_v2/shipper/data/models/task.dart';

class SocketPage extends StatefulWidget {
  final User user;
  final String token;

  const SocketPage({required this.user, required this.token});

  @override
  _SocketPageState createState() => _SocketPageState();
}

class _SocketPageState extends State<SocketPage> {
  late String token;
  late ShipperNavigatePage childWidget;
  List<Task> tasks = [
    // Task(id:"123")
  ];
  late IO.Socket socket;

  @override
  void initState() {
    token = widget.token;
    // userId = "123";

    super.initState();
    childWidget = ShipperNavigatePage(
      user: widget.user,
      tasks: tasks,
      token: token
    );
    connectToSocket();
  }

  void connectToSocket() {
    Future<void> _showNotification(String title, String message) async {
      print("Đang hiển thị thông báo: $title - $title");
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
    String host = "https://api.tdlogistics.net.vn/";
    try {
      socket = IO.io(
        host,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Sử dụng transport websocket
            .setExtraHeaders({
          'authorization': 'Bearer $token', // Thêm headers tuỳ chỉnh
        }).build(),
      );

      // Lắng nghe sự kiện "connect"
      socket.on('connect', (_) {
        print('Connected to socket');
      });

      // Lắng nghe và xử lý sự kiện 'message'
      socket.on('message', (data) {
        print('Received message: $data');
        if (data['category'] == 'ORDER' && data['type'] == 'PENDING') {
          try {
            _showNotification("Đơn hàng mới", data['message']);
            // sửa task chỗ này
            print(data["detail"]["orderId"]);
            print(data["message"]);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<PendingOrderBloc>().add(GetPendingTask());
            });
          } catch (error) {
            print("Lỗi khi nhận đơn hàng từ socket: ${error.toString()}");
          }
        }
      });

      socket.on('error', (error) {
        print('Lỗi: $error');
      });

      // Lắng nghe sự kiện "disconnect"
      socket.on('disconnect', (_) => print('Disconnected from socket'));
      socket.connect();
    } catch (error) {
      print("Lỗi kết nối socket:  ${error.toString()}");
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
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
