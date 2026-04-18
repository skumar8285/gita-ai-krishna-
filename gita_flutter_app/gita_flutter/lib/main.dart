import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Dark status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF03030F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const GitaApp());
}

class GitaApp extends StatelessWidget {
  const GitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'श्री कृष्ण गीता संवाद',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFFD700),
          secondary: const Color(0xFFFF8C00),
          surface: const Color(0xFF070720),
          background: const Color(0xFF03030F),
        ),
        scaffoldBackgroundColor: const Color(0xFF03030F),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
