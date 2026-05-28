import 'package:hive_flutter/hive_flutter.dart';

// ─────────────────────────────────────────────────────────────
// AuditLogService
//
// Every skeleton key access is written here. Box: 'audit_log'.
// Each entry records: timestamp, childId, reason, what was shown.
// Child sees a notification badge on next open.
// ─────────────────────────────────────────────────────────────

enum SkeletonReason {
  healthConcern,
  appointment,
  forgotPin,
  safeguarding,
}

extension SkeletonReasonLabel on SkeletonReason {
  String get label {
    switch (this) {
      case SkeletonReason.healthConcern: return 'Health concern';
      case SkeletonReason.appointment:   return 'Medical appointment';
      case SkeletonReason.forgotPin:     return 'Child forgot PIN';
      case SkeletonReason.safeguarding:  return 'Safeguarding';
    }
  }

  String get emoji {
    switch (this) {
      case SkeletonReason.healthConcern: return '🩺';
      case SkeletonReason.appointment:   return '📅';
      case SkeletonReason.forgotPin:     return '🔑';
      case SkeletonReason.safeguarding:  return '🛡️';
    }
  }
}

class AuditLogEntry {
  final String childId;
  final DateTime timestamp;
  final SkeletonReason reason;
  final List<String> sectionsViewed;

  AuditLogEntry({
    required this.childId,
    required this.timestamp,
    required this.reason,
    required this.sectionsViewed,
  });

  Map<String, dynamic> toJson() => {
    'childId':        childId,
    'timestamp':      timestamp.toIso8601String(),
    'reason':         reason.name,
    'sectionsViewed': sectionsViewed,
  };

  factory AuditLogEntry.fromJson(Map<String, dynamic> j) => AuditLogEntry(
    childId:        j['childId']   as String,
    timestamp:      DateTime.parse(j['timestamp'] as String),
    reason:         SkeletonReason.values.firstWhere(
                      (e) => e.name == j['reason'],
                      orElse: () => SkeletonReason.healthConcern,
                    ),
    sectionsViewed: (j['sectionsViewed'] as List? ?? []).cast<String>(),
  );
}

class AuditLogService {
  AuditLogService._();

  static const _boxName = 'audit_log';

  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Map>(_boxName);
    }
  }

  static Box<Map> get _box => Hive.box<Map>(_boxName);

  static Future<void> record(AuditLogEntry entry) async {
    final key = '${entry.childId}_${entry.timestamp.millisecondsSinceEpoch}';
    await _box.put(key, entry.toJson());
  }

  /// Returns all audit entries for a child, newest first.
  static List<AuditLogEntry> forChild(String childId) {
    return _box.values
        .map((e) => AuditLogEntry.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.childId == childId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Returns true if there are any unacknowledged entries for this child
  /// since the given timestamp (used to show the notification badge).
  static bool hasUnseenEntries(String childId, DateTime since) {
    return forChild(childId).any((e) => e.timestamp.isAfter(since));
  }
}
