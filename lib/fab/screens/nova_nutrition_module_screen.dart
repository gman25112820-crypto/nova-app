import 'package:flutter/material.dart';

class NovaNutritionModuleScreen extends StatefulWidget {
  const NovaNutritionModuleScreen({super.key});

  @override
  State<NovaNutritionModuleScreen> createState() => _NovaNutritionModuleScreenState();
}

class _NovaNutritionModuleScreenState extends State<NovaNutritionModuleScreen> {
  String _mealType = 'Breakfast';
  String _prepEffort = 'Low';
  String _repeatMeal = 'Maybe';
  int _energyBefore = 5;
  int _energyAfter = 5;
  int _digestionImpact = 0;
  int _painImpact = 0;

  final Set<String> _tags = {};
  final Set<String> _concerns = {};
  final TextEditingController _mealCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  static const Color _bg = Color(0xFF0D1020);
  static const Color _panel = Color(0xFF171A2E);
  static const Color _panel2 = Color(0xFF211C3A);
  static const Color _text = Color(0xFFF7F4FF);
  static const Color _muted = Color(0xFFB9AECF);
  static const Color _green = Color(0xFF61D394);
  static const Color _teal = Color(0xFF46D6C8);
  static const Color _amber = Color(0xFFFFC857);
  static const Color _rose = Color(0xFFFF6FAE);
  static const Color _purple = Color(0xFF8D6CFF);

  static const List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Meal prep',
    'Bad-day meal',
  ];

  static const List<String> _tagOptions = [
    'High protein',
    'Low effort',
    'Batch cooked',
    'Air fryer',
    'Slow cooker',
    'Family meal',
    'Cold fridge meal',
    'Quick win',
    'Comfort food',
    'Hydration focus',
  ];

  static const List<String> _concernOptions = [
    'Possible trigger',
    'Allergy concern',
    'Intolerance concern',
    'Bloating',
    'Reflux',
    'Low energy after',
    'Pain flare after',
    'Too much effort',
    'Safe repeat meal',
  ];

  static const List<String> _effortOptions = [
    'Very low',
    'Low',
    'Medium',
    'High',
  ];

  static const List<String> _repeatOptions = [
    'Yes',
    'Maybe',
    'No',
  ];

  @override
  void dispose() {
    _mealCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _summary {
    return '''
Nova Nutrition Summary

Meal type: $_mealType
Meal / ingredients:
${_mealCtrl.text.trim().isEmpty ? 'No meal entered yet.' : _mealCtrl.text.trim()}

Prep effort: $_prepEffort
Repeat meal: $_repeatMeal

Energy before: $_energyBefore / 10
Energy after: $_energyAfter / 10
Digestion impact: $_digestionImpact / 10
Pain or flare impact: $_painImpact / 10

Meal tags:
${_tags.isEmpty ? 'No tags selected yet.' : _tags.join(', ')}

Concerns:
${_concerns.isEmpty ? 'No concerns selected yet.' : _concerns.join(', ')}

Notes:
${_notesCtrl.text.trim().isEmpty ? 'No notes added yet.' : _notesCtrl.text.trim()}

Safety note:
This is a personal food and pattern log only. It does not prescribe diets, supplements, allergy treatment, or medical nutrition advice.
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 16),
            _section(
              title: 'MEAL TYPE',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _mealTypes.map((type) {
                  return _chip(
                    type,
                    _mealType == type,
                    _green,
                    () => setState(() => _mealType = type),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'MEAL / INGREDIENTS',
              child: TextField(
                controller: _mealCtrl,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: _text),
                decoration: InputDecoration(
                  hintText: 'What did you eat? Add ingredients if useful.',
                  hintStyle: const TextStyle(color: _muted),
                  filled: true,
                  fillColor: _panel2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'ENERGY / BODY RESPONSE',
              child: Column(
                children: [
                  _sliderRow(
                    label: 'Energy before',
                    value: _energyBefore,
                    activeColor: _teal,
                    onChanged: (v) => setState(() => _energyBefore = v.round()),
                  ),
                  _sliderRow(
                    label: 'Energy after',
                    value: _energyAfter,
                    activeColor: _green,
                    onChanged: (v) => setState(() => _energyAfter = v.round()),
                  ),
                  _sliderRow(
                    label: 'Digestion impact',
                    value: _digestionImpact,
                    activeColor: _amber,
                    onChanged: (v) => setState(() => _digestionImpact = v.round()),
                  ),
                  _sliderRow(
                    label: 'Pain / flare impact',
                    value: _painImpact,
                    activeColor: _rose,
                    onChanged: (v) => setState(() => _painImpact = v.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'MEAL TAGS',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tagOptions.map((tag) {
                  final selected = _tags.contains(tag);
                  return _chip(
                    tag,
                    selected,
                    _teal,
                    () {
                      setState(() {
                        selected ? _tags.remove(tag) : _tags.add(tag);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'CONCERNS / PATTERNS',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _concernOptions.map((concern) {
                  final selected = _concerns.contains(concern);
                  return _chip(
                    concern,
                    selected,
                    _rose,
                    () {
                      setState(() {
                        selected ? _concerns.remove(concern) : _concerns.add(concern);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'EFFORT / REPEAT',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prep effort', style: TextStyle(color: _text, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _effortOptions.map((effort) {
                      return _chip(
                        effort,
                        _prepEffort == effort,
                        _amber,
                        () => setState(() => _prepEffort = effort),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text('Repeat this meal?', style: TextStyle(color: _text, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _repeatOptions.map((repeat) {
                      return _chip(
                        repeat,
                        _repeatMeal == repeat,
                        _purple,
                        () => setState(() => _repeatMeal = repeat),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'NUTRITION NOTES',
              child: TextField(
                controller: _notesCtrl,
                maxLines: 5,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: _text),
                decoration: InputDecoration(
                  hintText: 'Did this help energy, digestion, mood, pain, or routine?',
                  hintStyle: const TextStyle(color: _muted),
                  filled: true,
                  fillColor: _panel2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _section(
              title: 'SUMMARY PREVIEW',
              child: SelectableText(
                _summary,
                style: const TextStyle(color: _text, height: 1.35),
              ),
            ),
            const SizedBox(height: 12),
            _safetyCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF165A3A), Color(0xFF171A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _green.withValues(alpha: 0.35)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova Nutrition',
            style: TextStyle(color: _text, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Simple food logging, meal prep, triggers, energy, digestion, and repeatable safe meals.',
            style: TextStyle(color: _muted, fontSize: 14, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _green,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required int value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: _text, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '$value / 10',
              style: TextStyle(color: activeColor, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: activeColor,
          inactiveColor: activeColor.withValues(alpha: 0.18),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, Color color, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : _panel2,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? color : color.withValues(alpha: 0.22)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : _muted,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _safetyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF332A14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _amber.withValues(alpha: 0.35)),
      ),
      child: const Text(
        'Nova Nutrition is a personal food and pattern log. It does not prescribe diets, supplements, allergy treatment, or medical nutrition advice. If food reactions, allergies, weight loss, severe symptoms, or worrying changes occur, seek appropriate professional support.',
        style: TextStyle(color: _text, height: 1.35, fontWeight: FontWeight.w600),
      ),
    );
  }
}