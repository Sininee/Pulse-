import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'audio_handler.dart';
import 'login_screen.dart';

late final AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  audioHandler = await AudioService.init(
    builder: () => PulseAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.pulse.app.audio',
      androidNotificationChannelName: 'Pulse Playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pulse',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accent,
          surface: Color(0xFF0C0C0C),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}