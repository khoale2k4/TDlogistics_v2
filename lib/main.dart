import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/app/app.dart';
import 'package:tdlogistic_v2/auth/data/repositories/auth_repository.dart.dart';
import 'package:tdlogistic_v2/core/service/notification.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/core/repositories/order_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tdlogistic_v2/shipper/data/repositories/task_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  final secureStorageService = SecureStorageService();
  WidgetsFlutterBinding.ensureInitialized();
  startNotice();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(
    secureStorageService: secureStorageService,
  ));
}