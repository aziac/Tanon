import 'package:flutter/material.dart';
import 'theme/win95_theme.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker 95',
      debugShowCheckedModeBanner: false,
      theme: Win95Theme.themeData,
      home: const MainScreen(),
    );
  }
}
