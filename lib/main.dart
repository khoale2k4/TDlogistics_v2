import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/app/app.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/service/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await updateEnv();

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
      child: MyApp(start: 0),
    ),
  );
}
