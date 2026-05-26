import 'package:hive_flutter/hive_flutter.dart';
import '../models/profile_model.dart';

class ProfileService {
  static ProfileModel? _profile;

  static ProfileModel? get profile => _profile;

  static Future<void> init() async {
    final box = Hive.box<Map>('profiles');
    final raw = box.get('current');
    if (raw != null) {
      _profile = ProfileModel.fromJson(Map<String, dynamic>.from(raw));
    }
  }

  static Future<void> save(ProfileModel profile) async {
    _profile = profile;
    await Hive.box<Map>('profiles').put('current', profile.toJson());
  }
}
