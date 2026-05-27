import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fab_theme.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});
  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final List<Map<String, dynamic>> _meals = [];
  int _waterGlasses = 0;
  bool _breakfast = false;
  bool _lunch = false;
  bool _dinner = false;
  String? _hungerNow;
  String? _energyNow;

  static String get _todayKey {
    final n = DateTime.now();
    return 'nutrition_${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_todayKey);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _waterGlasses = data['water'] as int? ?? 0;
        _breakfast    = data['breakfast'] as bool? ?? false;
        _lunch        = data['lunch'] as bool? ?? false;
        _dinner       = data['dinner'] as bool? ?? false;
        _hungerNow    = data['hunger'] as String?;
        _energyNow    = data['energy'] as String?;
        final savedMeals = data['meals'] as List?;
        if (savedMeals != null) {
          _meals.clear();
          for (final m in savedMeals) {
            _meals.add(Map<String, dynamic>.from(m as Map));
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({
      'water':     _waterGlasses,
      'breakfast': _breakfast,
      'lunch':     _lunch,
      'dinner':    _dinner,
      'hunger':    _hungerNow,
      'energy':    _energyNow,
      'meals': _meals.map((m) => {
        'name': m['name'],
        'cal':  m['cal'],
        'icon': m['icon'],
      }).toList(),
    });
    await prefs.setString(_todayKey, data);
  }

  static const _quickMeals = [
    {'name': 'Porridge', 'cal': 280, 'icon': '🥣', 'type': 'breakfast'},
    {'name': 'Toast & egg', 'cal': 320, 'icon': '🍳', 'type': 'breakfast'},
    {'name': 'Soup', 'cal': 180, 'icon': '🍲', 'type': 'lunch'},
    {'name': 'Sandwich', 'cal': 380, 'icon': '🥪', 'type': 'lunch'},
    {'name': 'Pasta', 'cal': 450, 'icon': '🍝', 'type': 'dinner'},
    {'name': 'Rice & veg', 'cal': 380, 'icon': '🍚', 'type': 'dinner'},
    {'name': 'Chicken & veg', 'cal': 420, 'icon': '🍗', 'type': 'dinner'},
    {'name': 'Omelette', 'cal': 280, 'icon': '🥚', 'type': 'dinner'},
    {'name': 'Banana', 'cal': 90, 'icon': '🍌', 'type': 'snack'},
    {'name': 'Apple', 'cal': 80, 'icon': '🍎', 'type': 'snack'},
    {'name': 'Nuts', 'cal': 160, 'icon': '🥜', 'type': 'snack'},
    {'name': 'Yoghurt', 'cal': 120, 'icon': '🥛', 'type': 'snack'},
  ];

  static const _hungerLevels = ['Empty', 'Hungry', 'Peckish', 'Satisfied', 'Full', 'Stuffed'];
  static const _energyLevels = ['Exhausted', 'Low', 'Okay', 'Good', 'Energised'];

  int get _totalCalories => _meals.fold(0, (sum, m) => sum + (m['cal'] as int));

  Color _calorieColor() {
    if (_totalCalories < 1000) return FabColors.rose;
    if (_totalCalories < 1500) return FabColors.gold;
    if (_totalCalories < 2200) return FabColors.teal;
    return FabColors.pink;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: AppBar(
        backgroundColor: FabColors.mid,
        title: const Text('Food & Nutrition', style: TextStyle(color: FabColors.pink, fontSize: 16)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Daily summary bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FabColors.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x2EFF8FAB), width: 0.5),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TODAY\'S CALORIES', style: TextStyle(fontSize: 10, color: FabColors.muted, letterSpacing: 1)),
                Text('$_totalCalories',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: _calorieColor())),
                Text('Goal: ~2000 kcal',
                  style: const TextStyle(fontSize: 11, color: FabColors.muted)),
              ])),
              const SizedBox(width: 12),
              Column(children: [
                _miniStat('💧', '$_waterGlasses/8', FabColors.teal),
                const SizedBox(height: 8),
                _miniStat('🍽', '${_meals.length} meals', FabColors.gold),
              ]),
            ]),
          ),

          // Calorie progress bar
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_totalCalories / 2000).clamp(0.0, 1.0),
              backgroundColor: FabColors.panel2,
              valueColor: AlwaysStoppedAnimation(_calorieColor()),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 16),

          // Water tracker
          _section(
            title: 'Water intake',
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ...List.generate(8, (i) => GestureDetector(
                  onTap: () => setState(() => _waterGlasses = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      '💧',
                      style: TextStyle(
                        fontSize: 22,
                        color: i < _waterGlasses ? null : const Color(0xFF444444),
                      ),
                    ),
                  ),
                )),
              ]),
              const SizedBox(height: 4),
              Text('$_waterGlasses of 8 glasses',
                style: const TextStyle(fontSize: 11, color: FabColors.muted)),
            ]),
          ),

          const SizedBox(height: 12),

          // Meal checkboxes
          _section(
            title: 'Meals today',
            child: Column(children: [
              _mealToggle('Breakfast', _breakfast, () => setState(() => _breakfast = !_breakfast)),
              const SizedBox(height: 8),
              _mealToggle('Lunch', _lunch, () => setState(() => _lunch = !_lunch)),
              const SizedBox(height: 8),
              _mealToggle('Dinner', _dinner, () => setState(() => _dinner = !_dinner)),
            ]),
          ),

          const SizedBox(height: 12),

          // Quick add meals
          _section(
            title: 'Quick add',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _quickMeals.map((m) => GestureDetector(
                onTap: () => setState(() => _meals.add({
                  'name': m['name'],
                  'cal': m['cal'],
                  'icon': m['icon'],
                  'time': DateTime.now(),
                })),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: FabColors.panel2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x1AFF8FAB), width: 0.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(m['icon'] as String, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text('${m['name']}', style: const TextStyle(fontSize: 11, color: FabColors.text)),
                    const SizedBox(width: 4),
                    Text('${m['cal']}', style: const TextStyle(fontSize: 10, color: FabColors.muted)),
                  ]),
                ),
              )).toList(),
            ),
          ),

          // Logged meals
          if (_meals.isNotEmpty) ...[
            const SizedBox(height: 12),
            _section(
              title: 'Logged today',
              child: Column(
                children: _meals.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Text(m['icon'] as String, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(m['name'] as String,
                      style: const TextStyle(fontSize: 13, color: FabColors.text))),
                    Text('${m['cal']} kcal',
                      style: const TextStyle(fontSize: 12, color: FabColors.gold)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _meals.remove(m)),
                      child: const Icon(Icons.close, size: 16, color: FabColors.muted),
                    ),
                  ]),
                )).toList(),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Hunger & energy check
          _section(
            title: 'Right now',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Hunger', style: TextStyle(fontSize: 11, color: FabColors.muted)),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: _hungerLevels.map((h) => GestureDetector(
                  onTap: () => setState(() => _hungerNow = h),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _hungerNow == h ? FabColors.rose.withValues(alpha: 0.2) : FabColors.panel2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _hungerNow == h ? FabColors.rose : const Color(0x1AFF8FAB)),
                    ),
                    child: Text(h, style: TextStyle(fontSize: 11,
                      color: _hungerNow == h ? FabColors.rose : FabColors.muted)),
                  ),
                )).toList()),
              ),
              const SizedBox(height: 10),
              const Text('Energy', style: TextStyle(fontSize: 11, color: FabColors.muted)),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: _energyLevels.map((e) => GestureDetector(
                  onTap: () => setState(() => _energyNow = e),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _energyNow == e ? FabColors.teal.withValues(alpha: 0.2) : FabColors.panel2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _energyNow == e ? FabColors.teal : const Color(0x1AFF8FAB)),
                    ),
                    child: Text(e, style: TextStyle(fontSize: 11,
                      color: _energyNow == e ? FabColors.teal : FabColors.muted)),
                  ),
                )).toList()),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () async {
              await _saveToPrefs();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Nutrition log saved ✓'),
                backgroundColor: FabColors.teal.withValues(alpha: 0.9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: FabColors.teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Save nutrition log',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _miniStat(String icon, String label, Color color) => Column(children: [
    Text(icon, style: const TextStyle(fontSize: 18)),
    Text(label, style: TextStyle(fontSize: 10, color: color)),
  ]);

  Widget _mealToggle(String label, bool value, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Row(children: [
      Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: value ? FabColors.teal.withValues(alpha: 0.2) : FabColors.panel2,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: value ? FabColors.teal : const Color(0x1AFF8FAB),
            width: value ? 1.5 : 0.5),
        ),
        child: value ? const Icon(Icons.check, size: 14, color: FabColors.teal) : null,
      ),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 13, color: FabColors.text)),
    ]),
  );

  Widget _section({required String title, required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: FabColors.panel,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(),
        style: const TextStyle(fontSize: 10, color: FabColors.pink, letterSpacing: 1.2)),
      const SizedBox(height: 10),
      child,
    ]),
  );
}
