import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nova_app/fab/screens/fab_home_screen.dart';
import 'package:nova_app/fab/screens/onboarding_screen.dart';
import 'package:nova_app/fab/services/profile_service.dart';
import 'package:nova_app/fab/services/notification_service.dart';
import 'package:nova_app/fab/models/child_profile.dart';
import 'package:nova_app/fab/models/family_account.dart';
import 'package:nova_app/fab/services/storage_service.dart';
import 'package:nova_app/fab/services/audit_log_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Map>('checkins');
  await Hive.openBox<Map>('worries');
  await Hive.openBox<String>('parent_notes');
  await Hive.openBox<Map>('profiles');
  await Hive.openBox<Map>('family_account');
  await Hive.openBox<Map>('moods');
  await AuditLogService.openBox();
  await ProfileService.init();
  await FamilyAccount.init();

  // One-time migration: bridge an existing ProfileService profile into FamilyAccount
  // if no ChildProfile has been created yet. Runs once — children.isNotEmpty guards it.
  final migrProfile = ProfileService.profile;
  if (migrProfile != null &&
      (FamilyAccount.current == null || FamilyAccount.current!.children.isEmpty)) {
    final dob     = DateTime(DateTime.now().year - migrProfile.age, 1, 1);
    final child   = ChildProfile(
      id:         migrProfile.id,
      name:       migrProfile.name,
      dob:        dob,
      conditions: migrProfile.conditions,
    );
    final account = FamilyAccount.current ?? FamilyAccount.create();
    account.addChild(child);
    await account.save();
  }

  await StorageService.init();
  await NotificationService.init();
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
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final isWide = size.width > size.height;
        if (isWide) {
          // Wide/desktop: no constraint — home screen handles 1200px centering.
          return ColoredBox(color: const Color(0xFF0F0520), child: child!);
        }
        // Portrait/mobile: cap at 430px and centre.
        return Container(
          color: const Color(0xFF1A0A2E),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child!,
            ),
          ),
        );
      },
    );
  }
}
