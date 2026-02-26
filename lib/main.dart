import 'package:flutter/material.dart';
import 'package:hayd_kalender/presentation/app_theme.dart';
import 'presentation/home_screen.dart';

void main() {
  runApp(const HaydApp());
}

class HaydApp extends StatelessWidget {
  const HaydApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hayd Kalender',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.rose,
          primary: AppTheme.plum,
          secondary: AppTheme.rose,
          surface: AppTheme.ivory,
        ),
        fontFamily: AppTheme.bodyFont,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.plum,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
