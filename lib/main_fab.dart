import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nova_app/fab/screens/fab_home_screen.dart';
import 'package:nova_app/fab/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Map>('checkins');
  await Hive.openBox<Map>('worries');
  await Hive.openBox<String>('parent_notes');
  final prefs = await SharedPreferences.getInstance();
  final done  = prefs.getBool('onboarding_complete') ?? false;
  runApp(FabApp(showOnboarding: !done));
}

class FabApp extends StatelessWidget {
  final bool showOnboarding;
  const FabApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fabulously Me',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0820),
        fontFamily: 'Roboto',
      ),
      home: showOnboarding ? const OnboardingScreen() : const FabHomeScreen(),
    );
  }
}
