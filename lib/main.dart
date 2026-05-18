import 'package:flutter/material.dart';
import 'package:nova_app/nova_hub_screen.dart';

void main() {
  runApp(const NovaApp());
}

class NovaApp extends StatelessWidget {
  const NovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nova',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090C18),
        fontFamily: 'Roboto',
      ),
      home: const NovaHubScreen(),
    );
  }
}
