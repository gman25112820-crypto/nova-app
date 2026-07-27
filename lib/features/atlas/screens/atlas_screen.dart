import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/models/check_in_entry.dart';
import '../../../core/repositories/check_in_seed_data.dart';
import '../widgets/body_diagram_painter.dart';

/// Interactive body atlas screen.
/// Allows the user to select pain locations by tapping the canvas diagram
/// or toggling FilterChip labels beneath it. Both inputs share the same
/// [Set] of location strings as state and keep each other in sync.
///
/// Does not modify routing or lib/fab/ files.
class AtlasScreen extends StatefulWidget {
  const AtlasScreen({super.key});

  @override
  State<AtlasScreen> createState() => _AtlasScreenState();
}

class _AtlasScreenState extends State<AtlasScreen> {
  final Set<String> _selectedLocations = {};

  @override
  void initState() {
    super.initState();
    // Seed 14 days of test data in debug builds only.
    // Never runs in production — kDebugMode is false in release builds.
    if (kDebugMode) {
      seedDebugCheckInData();
    }
  }

  // All selectable location labels — back-specific first, then general.
  static const List<String> _allLocations = [
    ...CheckInEntry.backLocations,
    ...CheckInEntry.generalLocations,
  ];

  static const Color _bg = Color(0xFF0D1020);
  static const Color _panel = Color(0xFF171A2E);
  static const Color _text = Color(0xFFF7F4FF);
  static const Color _muted = Color(0xFFB9AECF);
  static const Color _accent = Color(0xFF8D6CFF);
  static const Color _coral = Color(0xFFFF6B6B);

  void _toggleLocation(String location) {
    setState(() {
      if (_selectedLocations.contains(location)) {
        _selectedLocations.remove(location);
      } else {
        _selectedLocations.add(location);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final int count = _selectedLocations.length;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nova Body Atlas',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Text(
              count == 0
                  ? 'No regions selected'
                  : '$count region${count == 1 ? '' : 's'} selected',
              style: TextStyle(
                fontSize: 11.5,
                color: count == 0 ? _muted : _coral,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        toolbarHeight: 60,
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _selectedLocations.toList()),
            child: Text(
              'Done',
              style: TextStyle(
                color: _selectedLocations.isNotEmpty ? _coral : _muted,
                fontWeight: _selectedLocations.isNotEmpty
                    ? FontWeight.w700
                    : FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Canvas ──────────────────────────────────────────────────────
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final Size canvasSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );

                  return GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      final String? region =
                          BodyDiagramPainter.getRegionFromOffset(
                        details.localPosition,
                        canvasSize,
                      );
                      if (region != null) {
                        _toggleLocation(region);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomPaint(
                          size: canvasSize,
                          painter: BodyDiagramPainter(
                            selectedLocations:
                                _selectedLocations.toList(),
                            isDarkMode: isDark,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Chip selector ────────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Text(
                    'TAP THE DIAGRAM OR SELECT BELOW',
                    style: TextStyle(
                      color: _muted.withValues(alpha: 0.7),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _allLocations.map((String label) {
                        final bool selected =
                            _selectedLocations.contains(label);
                        return FilterChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: selected ? _coral : _muted,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) => _toggleLocation(label),
                          backgroundColor: _panel,
                          selectedColor: _coral.withValues(alpha: 0.15),
                          checkmarkColor: _coral,
                          side: BorderSide(
                            color: selected
                                ? _coral.withValues(alpha: 0.7)
                                : _accent.withValues(alpha: 0.22),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Clear button ─────────────────────────────────────────────────
          if (_selectedLocations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => setState(() => _selectedLocations.clear()),
                  style: TextButton.styleFrom(
                    foregroundColor: _muted,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _muted.withValues(alpha: 0.20),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Clear all selections',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
