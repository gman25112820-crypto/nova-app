import 'package:flutter/material.dart';
import '../services/fab_stars_service.dart';

// ─────────────────────────────────────────────────────────────
// KitchenMealPicker
//
// Interactive meal picker. Tap a meal to "choose" it.
// Award 2 stars for eating something new. Show a fun cooking
// message. Tracks what's been tried today.
// ─────────────────────────────────────────────────────────────

class KitchenMealPicker extends StatefulWidget {
  const KitchenMealPicker({super.key});

  @override
  State<KitchenMealPicker> createState() => _KitchenMealPickerState();
}

class _KitchenMealPickerState extends State<KitchenMealPicker> {
  final Set<String> _chosen = {};
  String? _message;

  static const _yellow = Color(0xFFFFD700);

  static const _meals = [
    _Meal('🍳', 'Scrambled Eggs',   'Extra fluffy, just the way you like.'),
    _Meal('🥣', 'Cereal',           'Crunchy or soft — you decide!'),
    _Meal('🍞', 'Toast',            'Golden and warm with butter.'),
    _Meal('🥞', 'Pancakes',         'Soft stack, maybe with honey? 🍯'),
    _Meal('🍝', 'Pasta',            'Twirly pasta — always a good idea.'),
    _Meal('🍲', 'Soup',             'Warm and cosy on a tired day.'),
    _Meal('🥗', 'Salad',            'Colourful and crunchy. Superhero food.'),
    _Meal('🧆', 'Falafel',          'Crispy little bites of goodness.'),
    _Meal('🍕', 'Pizza',            'Everyone loves pizza day.'),
    _Meal('🥕', 'Carrot Sticks',    'Crunchy and bright — dipping sauce?'),
    _Meal('🍌', 'Banana',           'Instant energy. Monkey approved.'),
    _Meal('🧀', 'Cheese & Crackers','Easy and tasty. 10/10.'),
  ];

  Future<void> _pick(_Meal meal) async {
    final isNew = !_chosen.contains(meal.emoji);
    setState(() {
      _chosen.add(meal.emoji);
      _message = isNew
          ? '${meal.emoji} ${meal.msg}\n+2 ⭐  stars for trying something!'
          : '${meal.emoji} ${meal.msg}';
    });
    if (isNew) {
      await FabStarsService.awardForGame(2, 'Tried ${meal.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0D06),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _yellow.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFFF0D6FF), size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '🍳  Kitchen',
                    style: TextStyle(
                      color: Color(0xFFF0D6FF),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'What sounds good?',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            // Message banner
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _message != null
                  ? Container(
                      key: ValueKey(_message),
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _yellow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _yellow.withValues(alpha: 0.30)),
                      ),
                      child: Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFF0D6FF),
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          height: 1.5,
                        ),
                      ),
                    )
                  : const SizedBox(key: ValueKey('empty'), height: 8),
            ),
            // Meal grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 110,
                ),
                itemCount: _meals.length,
                itemBuilder: (_, i) {
                  final meal   = _meals[i];
                  final picked = _chosen.contains(meal.emoji);
                  return GestureDetector(
                    onTap: () => _pick(meal),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: picked
                            ? _yellow.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: picked
                              ? _yellow.withValues(alpha: 0.55)
                              : Colors.white.withValues(alpha: 0.10),
                          width: picked ? 1.5 : 1,
                        ),
                        boxShadow: picked
                            ? [
                                BoxShadow(
                                  color: _yellow.withValues(alpha: 0.20),
                                  blurRadius: 12,
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(meal.emoji,
                              style: const TextStyle(fontSize: 38)),
                          const SizedBox(height: 6),
                          Text(
                            meal.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: picked
                                  ? _yellow
                                  : Colors.white
                                      .withValues(alpha: 0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                          if (picked)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text('✓',
                                  style: TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meal {
  final String emoji;
  final String name;
  final String msg;
  const _Meal(this.emoji, this.name, this.msg);
}
