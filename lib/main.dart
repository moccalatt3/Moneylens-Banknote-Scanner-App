import 'package:flutter/material.dart';
import 'presentation/screens/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),  // Awalnya tampilkan Welcome Screen
    );
  }
}
