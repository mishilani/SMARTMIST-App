import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:smartmist_app/pages/welcome_pg.dart';
import 'package:smartmist_app/theme/theme.dart';
import 'package:smartmist_app/services/notification_service.dart';
import 'package:smartmist_app/services/heat_warning_service.dart'; // ADD THIS IMPORT

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.init();

  HeatWarningService.start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMARTMIST',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: const WelcomeScreen(),
    );
  }
}
