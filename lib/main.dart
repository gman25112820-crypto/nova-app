import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nova_app/nova_hub_screen.dart';
import 'package:nova_app/fab/models/child_profile.dart';
import 'package:nova_app/fab/models/family_account.dart';
import 'package:nova_app/fab/services/profile_service.dart';
import 'package:nova_app/fab/services/storage_service.dart';

// Notification init — native only (web is a no-op via stub).
import 'package:nova_app/fab/services/notification_service_native.dart'
    if (dart.library.html) 'package:nova_app/fab/services/notification_service_stub.dart'
    as notif_native;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Open all Hive boxes used across the app.
  await Future.wait([
    Hive.openBox<Map>('checkins'),
    Hive.openBox<Map>('profiles'),
    Hive.openBox<Map>('worries'),
    Hive.openBox<String>('parent_notes'),
    Hive.openBox<Map>('settings'),
    Hive.openBox<Map>('family_account'),
    Hive.openBox<Map>('moods'),
    Hive.openBox<Map>('sleep_fatigue'),
  ]);

  // Initialise profile and child-account state before any FAB route runs.
  await ProfileService.init();
  await FamilyAccount.init();

  final migrProfile = ProfileService.profile;
  if (migrProfile != null &&
      (FamilyAccount.current == null ||
          FamilyAccount.current!.children.isEmpty)) {
    final dob = DateTime(DateTime.now().year - migrProfile.age, 1, 1);
    final child = ChildProfile(
      id: migrProfile.id,
      name: migrProfile.name,
      dob: dob,
      conditions: migrProfile.conditions,
    );
    final account = FamilyAccount.current ?? FamilyAccount.create();
    account.addChild(child);
    await account.save();
  }

  await StorageService.init();

  // Load saved text scale before first frame.
  final prefs = await SharedPreferences.getInstance();
  final savedScale = prefs.getDouble('nova_text_scale') ?? 1.0;
  NovaApp.textScaleNotifier.value = savedScale;

  // Initialise local notifications on native platforms.
  if (!kIsWeb) {
    await notif_native.initNative();
  }

  runApp(const NovaApp());
}

class NovaApp extends StatefulWidget {
  const NovaApp({super.key});

  /// Updated by SettingsScreen; triggers immediate app-wide text scale change.
  static final textScaleNotifier = ValueNotifier<double>(1.0);

  @override
  State<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends State<NovaApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: NovaApp.textScaleNotifier,
      builder: (context, scale, _) {
        return MaterialApp(
          title: 'Nova',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF090C18),
            fontFamily: 'Roboto',
          ),
          // Apply user-selected text scale across the whole app.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const NovaHubScreen(),
        );
      },
    );
  }
}
