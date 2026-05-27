import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nova_app/nova_hub_screen.dart';

// Notification init — native only (web is a no-op via stub).
import 'package:nova_app/fab/services/notification_service_native.dart'
    if (dart.library.html) 'package:nova_app/fab/services/notification_service_stub.dart'
    as _native;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Map>('checkins');

  // Load saved text scale before first frame.
  final prefs = await SharedPreferences.getInstance();
  final savedScale = prefs.getDouble('nova_text_scale') ?? 1.0;
  NovaApp.textScaleNotifier.value = savedScale;

  // Initialise local notifications on native platforms.
  if (!kIsWeb) {
    await _native.initNative();
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
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
            ),
            child: child!,
          ),
          home: const NovaHubScreen(),
        );
      },
    );
  }
}
