
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tdlogistic_v2/customer/UI/screens/history.dart';

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

Future<void> selectNotification(NotificationResponse notificationResponse) async {
  String? payload = notificationResponse.payload;
  if (payload != null) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => const History(),
      ),
    );
    debugPrint('notification payload: $payload');
  }
}

void startNotice() async{
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: selectNotification);
}