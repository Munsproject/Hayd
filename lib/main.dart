import 'package:flutter/material.dart';
import 'home_screen.dart';

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
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
    );
  }
}
