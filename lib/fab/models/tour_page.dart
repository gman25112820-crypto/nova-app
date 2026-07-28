import 'package:flutter/material.dart';

@immutable
class TourPage {
  final String id;
  final String title;
  final String body;
  final IconData icon;
  final String? eddiePrompt;

  const TourPage({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    this.eddiePrompt,
  });
}
