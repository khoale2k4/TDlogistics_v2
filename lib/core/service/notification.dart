import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tdlogistic_v2/app/app.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  // Handle the received notification
  // This is called when a notification is received while the app is in the foreground
  showDialog(
    context: navigatorKey.currentState!.overlay!.context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title ?? 'Notification'),
      content: Text(body ?? 'No details'),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    ),
  );
}

Future<void> selectNotification(
    NotificationResponse notificationResponse) async {
  String? payload = notificationResponse.payload;
  if (payload == 'new order') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => MyApp(start: 1),
      ),
    );
  } else if (payload == 'new message') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => MyApp(start: 2),
      ),
    );
  }
  debugPrint('notification payload: $payload');
}

Future<void> startNotice() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: selectNotification);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    '123', // ID kênh trùng với ID bạn dùng ở trên trong AndroidNotificationDetails
    'tdlogistic', // Tên kênh hiển thị cho người dùng
    importance: Importance.max,
    description: 'Kênh thông báo cho ứng dụng', // Mô tả kênh
  );

// Tạo kênh thông báo trên Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> showNotification(
    String title, String message, String payload) async {
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
    payload: payload,
  );
}
