import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/child_profile.dart';
import '../services/selected_child_service.dart';
import 'mood_calendar_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MOOD SCREEN
// Child-friendly mood logger: 5-level emoji selector, feeling chips,
// notes, SharedPreferences persistence, 7-day emoji strip.
// ─────────────────────────────────────────────────────────────────────────────

// ─── Model ───────────────────────────────────────────────────────────────────

class MoodEntry {
  final String id;
  final String date;
  final int mood; // 1–5  (1 = Rough … 5 = Great)
  final List<String> feelings;
  final String notes;

  MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.feelings,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'mood': mood,
        'feelings': feelings,
        'notes': notes,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> j) => MoodEntry(
        id: j['id'] as String,
        date: j['date'] as String,
        mood: j['mood'] as int,
        feelings: List<String>.from(j['feelings'] as List),
        notes: j['notes'] as String,
      );
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  // Same order/colours as the hub palette so history is consistent.
  static const _moodEmojis  = ['😣', '😟', '😐', '🙂', '😄'];
  static const _moodLabels  = ['Rough', 'Low', 'Okay', 'Good', 'Great'];
  static const _moodColors  = [
    Color(0xFFFF6B8A),
    Color(0xFFFF8C42),
    Color(0xFFFFB830),
    Color(0xFF6C63FF),
    Color(0xFF00C9A7),
  ];

  static const _feelingOptions = [
    'Happy', 'Excited', 'Calm', 'Proud',
    'Nervous', 'Worried', 'Sad', 'Angry',
    'Frustrated', 'Lonely', 'Bored', 'Tired',
    'Confused', "Don't know",
  ];

  ChildProfile?  _child;
  int?           _selectedMood; // 1–5, null = not yet chosen
  final List<String> _feelings = [];
  final _notesCtrl = TextEditingController();
  List<MoodEntry> _entries = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _child = SelectedChildService.current ?? SelectedChildService.selectDefault();
    _loadEntries();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Persistence ──────────────────────────────────────────────

  Future<void> _loadEntries() async {
    if (_child == null) return;
    final box    = Hive.box<Map>('moods');
    final prefix = '${_child!.id}_';
    final entries = box.keys
        .where((k) => (k as String).startsWith(prefix))
        .map((k) => MoodEntry.fromJson(
              Map<String, dynamic>.from(box.get(k)!),
            ))
        .toList();
    if (!mounted) return;
    setState(() => _entries = entries);
  }

  Future<void> _save() async {
    if (_selectedMood == null || _child == null) return;
    setState(() => _saving = true);

    final entry = MoodEntry(
      id:       DateTime.now().millisecondsSinceEpoch.toString(),
      date:     _todayKey(),
      mood:     _selectedMood!,
      feelings: List.from(_feelings),
      notes:    _notesCtrl.text.trim(),
    );

    // Key pattern: '<childId>_<date>' — put() overwrites, so one entry per day naturally.
    await Hive.box<Map>('moods').put('${_child!.id}_${_todayKey()}', entry.toJson());

    _entries.removeWhere((e) => e.date == _todayKey());
    _entries.add(entry);

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mood saved!'),
        backgroundColor: _moodColors[_selectedMood! - 1],
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}'
        '-${n.day.toString().padLeft(2, '0')}';
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1040),
        foregroundColor: Colors.white,
        title: const Text(
          "How's your mood?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoodSelector(),
              const SizedBox(height: 28),
              _buildFeelingChips(),
              const SizedBox(height: 24),
              _buildNotesField(),
              const SizedBox(height: 28),
              _buildSaveButton(),
              const SizedBox(height: 36),
              _buildWeekStrip(),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MoodCalendarScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1040),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          color: Color(0xFF6C63FF), size: 16),
                      SizedBox(width: 8),
                      Text(
                        'View full mood calendar',
                        style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF6C63FF), size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mood selector ────────────────────────────────────────────

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you feeling today?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final lvl      = i + 1;
            final selected = _selectedMood == lvl;
            final color    = _moodColors[i];
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = lvl),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58,
                height: 74,
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: 0.22)
                      : const Color(0xFF1A1040),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? color : Colors.white12,
                    width: selected ? 2.5 : 1.0,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 14,
                        )]
                      : const [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_moodEmojis[i],
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(
                      _moodLabels[i],
                      style: TextStyle(
                        color:      selected ? color : Colors.white38,
                        fontSize:   10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (_selectedMood != null) ...[
          const SizedBox(height: 14),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                '${_moodEmojis[_selectedMood! - 1]}  '
                '${_moodLabels[_selectedMood! - 1]}',
                key: ValueKey(_selectedMood),
                style: TextStyle(
                  color:      _moodColors[_selectedMood! - 1],
                  fontSize:   22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Feeling chips ────────────────────────────────────────────

  Widget _buildFeelingChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Any feelings with that?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing:    8,
          runSpacing: 8,
          children: _feelingOptions.map((f) {
            final isDontKnow = f == "Don't know";
            final selected   = _feelings.contains(f);
            return GestureDetector(
              onTap: () => setState(() {
                if (isDontKnow) {
                  _feelings.clear();
                  if (!selected) _feelings.add(f);
                } else {
                  _feelings.remove("Don't know");
                  if (selected) {
                    _feelings.remove(f);
                  } else {
                    _feelings.add(f);
                  }
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF6C63FF).withValues(alpha: 0.28)
                      : const Color(0xFF1A1040),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF6C63FF)
                        : Colors.white24,
                    width: selected ? 1.8 : 1.0,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF9B97FF)
                        : Colors.white60,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Notes ────────────────────────────────────────────────────

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Anything else on your mind?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notesCtrl,
          maxLines:   3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText:  'Write anything you want...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled:    true,
            fillColor: const Color(0xFF1A1040),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: Color(0xFF6C63FF), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Save button ──────────────────────────────────────────────

  Widget _buildSaveButton() {
    final color = _selectedMood != null
        ? _moodColors[_selectedMood! - 1]
        : const Color(0xFF6C63FF);
    return SizedBox(
      width:  double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _selectedMood == null || _saving || _child == null ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor:         color,
          foregroundColor:         Colors.white,
          disabledBackgroundColor: Colors.white12,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        child: _saving
            ? const SizedBox(
                width:  22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                _child == null
                    ? 'No child profile found'
                    : _selectedMood != null
                        ? 'Save ${_moodEmojis[_selectedMood! - 1]} Mood'
                        : 'Pick a mood first',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // ── 7-day strip ──────────────────────────────────────────────

  Widget _buildWeekStrip() {
    final now  = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final byDate = {for (final e in _entries) e.date: e};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last 7 days',
          style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((d) {
            final key = '${d.year}-'
                '${d.month.toString().padLeft(2, '0')}-'
                '${d.day.toString().padLeft(2, '0')}';
            final entry   = byDate[key];
            final isToday = key == _todayKey();
            const dayNames = ['Mo','Tu','We','Th','Fr','Sa','Su'];
            final dayLabel =
                isToday ? 'Today' : dayNames[d.weekday - 1];
            return Column(
              children: [
                Text(
                  dayLabel,
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.white38,
                    fontSize:   10,
                    fontWeight: isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width:  36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: entry != null
                        ? _moodColors[entry.mood - 1].withValues(alpha: 0.22)
                        : const Color(0xFF1A1040),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: entry != null
                          ? _moodColors[entry.mood - 1]
                          : Colors.white12,
                      width: isToday ? 2.0 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      entry != null
                          ? _moodEmojis[entry.mood - 1]
                          : '·',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
