import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/app/app.dart';
import 'package:tdlogistic_v2/core/service/notification.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tdlogistic_v2/core/service/send_location.dart';
import 'firebase_options.dart';

Future<void> main() async {
  final secureStorageService = SecureStorageService();
  final locationTrackerService = LocationTrackerService();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await startNotice();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', ''),
        Locale('vi', ''),
      ],
      path: 'lib/assets/translations',
      fallbackLocale: const Locale('vi', ''),
      child: MyApp(
        secureStorageService: secureStorageService,
        locationTrackerService: locationTrackerService,
      ),
    ),
  );
}
