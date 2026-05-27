import 'package:flutter/material.dart';

import '../fab_theme.dart';
import '../models/fab_state.dart';

class FabulouslyMeWidget extends StatelessWidget {
  const FabulouslyMeWidget({super.key, required this.state});

  final FabState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/graphics/fab_${state.mood}.png',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: FabColors.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FabColors.pink.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 48)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Intensity: ${state.intensity}',
          style: const TextStyle(
            color: FabColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'DM Sans',
          ),
        ),
      ],
    );
  }
}
