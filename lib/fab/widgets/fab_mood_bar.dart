import 'package:flutter/material.dart';
import '../fab_theme.dart';
import 'chicken_lips_widget.dart';

class _MoodEntry {
  final String emoji;
  final String label;
  final ChickenLipsMood mood;
  final Color color;
  const _MoodEntry(this.emoji, this.label, this.mood, this.color);
}

const _moods = [
  _MoodEntry('😊', 'Happy',   ChickenLipsMood.happy,   FabColors.gold),
  _MoodEntry('😴', 'Sleepy',  ChickenLipsMood.sleepy,  FabColors.ice),
  _MoodEntry('😐', 'Meh',     ChickenLipsMood.neutral, FabColors.muted),
  _MoodEntry('😢', 'Sad',     ChickenLipsMood.sad,     FabColors.rose),
  _MoodEntry('🤩', 'Excited', ChickenLipsMood.excited, FabColors.pink),
  _MoodEntry('👑', 'Fab!',    ChickenLipsMood.crowned, FabColors.gold),
];

class MoodBar extends StatelessWidget {
  final ChickenLipsMood selected;
  final ValueChanged<ChickenLipsMood> onChanged;
  const MoodBar({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: FabColors.panel2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x2EFF8FAB), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _moods.map((m) {
          final isSel = selected == m.mood;
          return GestureDetector(
            onTap: () => onChanged(m.mood),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSel ? m.color.withValues(alpha: 0.18) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSel ? m.color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(m.emoji, style: TextStyle(fontSize: isSel ? 24 : 20)),
                  const SizedBox(height: 2),
                  Text(m.label, style: TextStyle(
                    fontSize: 9,
                    color: isSel ? m.color : FabColors.muted,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.normal,
                    letterSpacing: 0.3,
                  )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}