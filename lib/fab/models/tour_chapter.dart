import 'package:flutter/material.dart';

enum TourCollection { showMeMyWorld, showMeHow }

enum TourReadiness { ready, comingSoon, needsGrownUpHelp }

@immutable
class TourChapter {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final TourCollection collection;
  final TourReadiness readiness;
  final String? actionId;

  const TourChapter({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.collection,
    required this.readiness,
    this.actionId,
  });
}
