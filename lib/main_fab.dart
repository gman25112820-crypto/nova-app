import 'package:flutter/material.dart';
import 'fab/fab_theme.dart';
import 'fab/screens/fab_home_screen.dart';

void main() { runApp(const FabulouslyMeApp()); }

class FabulouslyMeApp extends StatelessWidget {
  const FabulouslyMeApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fabulously Me',
    debugShowCheckedModeBanner: false,
    theme: FabTheme.theme,
    home: const FabHomeScreen(),
  );
}