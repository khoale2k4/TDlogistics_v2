import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tdlogistic_v2/core/service/notification.dart';

IO.Socket? socket;

void connectSocket(String userId) async {
  Future<void> _showNotification(String title, String message) async {
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

  print('Bearer $userId');
  String host = "https://api.tdlogistics.net.vn/";
  socket = IO.io(
    host,
    IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders({
      'authorization': 'Bearer $userId',
    }).build(),
  );
  try {
    socket!.on('connect', (_) {
      print('Kết nối tới host $host thành công');
      //  _showNotification("Kết nối thành công");
    });

    socket!.on('message', (data) async {
      if (data['category'] == 'ORDER' && data['type'] == 'PENDING') {
        _showNotification("Đơn hàng mới", data['message']);
      } else if (data['category'] == 'ORDER' && data['type'] == "ACCEPTED") {
        _showNotification("Đơn hàng được chấp nhận", data['message']);
      }
      
    });

    socket!.on('error', (error) {
      print('Lỗi: $error');
    });

    socket!.on('disconnect', (_) {
      print('Ngắt kết nối');
    });

    socket!.connect();
  } catch (e) {
    print('Unable to connect: $e');
  }
}

void disconnect(){ 
  socket!.disconnect();
}
