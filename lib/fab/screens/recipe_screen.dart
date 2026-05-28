import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../services/storage_service.dart';

// ─────────────────────────────────────────────────────────────
// RecipeScreen  (Favourite Meals)
//
// Child adds their favourite meals — name + emoji.
// Validated by Daisy: knowing what a child likes to eat is
// helpful for parents, carers and school. Stored in the child's
// data box under key 'fav_meals'.
//
// Cards are swipe-to-delete or long-press for the delete button.
// ─────────────────────────────────────────────────────────────

class RecipeScreen extends StatefulWidget {
  final ChildProfile child;
  const RecipeScreen({super.key, required this.child});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  static const _bg     = Color(0xFF0D0820);
  static const _purple = Color(0xFF6C63FF);
  static const _pink   = Color(0xFFFF6B8A);
  static const _amber  = Color(0xFFFFB830);
  static const _card   = Color(0xFF120C28);

  List<Map<String, String>> _meals = [];

  // Common meal emojis to suggest in the picker
  static const _emojiOptions = [
    '🍕', '🍝', '🍜', '🍛', '🌮', '🌯', '🥙', '🍔', '🌭',
    '🥪', '🥗', '🍣', '🍱', '🥟', '🍚', '🥘', '🍲', '🫕',
    '🥞', '🧇', '🥓', '🍳', '🥚', '🧆', '🥙', '🫔', '🍟',
    '🍗', '🍖', '🥩', '🫛', '🥦', '🥕', '🫑', '🍅', '🥑',
    '🍎', '🍇', '🍓', '🍌', '🍰', '🎂', '🧁', '🍮', '🍩',
    '🍪', '🍫', '🍬', '🧃', '🥤', '🍼', '☕', '🫖', '🥛',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    try {
      final data = StorageService.readData(widget.child.id, 'fav_meals');
      if (data != null) {
        final raw = data['meals'] as List? ?? [];
        _meals = raw
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
      }
    } catch (_) {}
    setState(() {});
  }

  Future<void> _save() async {
    await StorageService.writeData(widget.child.id, 'fav_meals', {
      'type':      'fav_meals',
      'meals':     _meals,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _addMeal(String name, String emoji) {
    setState(() => _meals.add({'name': name, 'emoji': emoji}));
    _save();
  }

  void _removeMeal(int index) {
    setState(() => _meals.removeAt(index));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favourite Meals',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                  fontSize: 17),
            ),
            Text(
              widget.child.name,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add meal',
            onPressed: _showAddMeal,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildIntroCard(),
          Expanded(
            child: _meals.isEmpty
                ? _buildEmpty()
                : _buildMealList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMeal,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add meal',
          style: TextStyle(
              fontFamily: 'DM Sans', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _amber.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _amber.withValues(alpha: 0.20)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Add the foods you enjoy — so parents, school '
                'and carers always know what to make for you.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.60),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'No meals added yet.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45), fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "Add meal" to get started.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.30), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMealList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: _meals.length,
      itemBuilder: (_, i) => _buildMealCard(i),
    );
  }

  Widget _buildMealCard(int index) {
    final meal  = _meals[index];
    final name  = meal['name']  ?? '';
    final emoji = meal['emoji'] ?? '🍽️';

    return Dismissible(
      key: Key('meal_$index$name'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _pink.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _pink.withValues(alpha: 0.30)),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: _pink, size: 22),
      ),
      onDismissed: (_) => _removeMeal(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _purple.withValues(alpha: 0.20)),
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: Colors.white.withValues(alpha: 0.20),
                  size: 18),
              onPressed: () => _removeMeal(index),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMeal() {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '🍕';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF150D2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add a favourite meal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 16),

              // ── Meal name ─────────────────────────────────────
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'DM Sans'),
                decoration: const InputDecoration(
                  labelText: 'Meal name',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xFF2D2060))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _purple)),
                ),
              ),
              const SizedBox(height: 14),

              // ── Emoji picker ──────────────────────────────────
              Text(
                'Pick an emoji',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemCount: _emojiOptions.length,
                  itemBuilder: (_, i) {
                    final e = _emojiOptions[i];
                    final chosen = selectedEmoji == e;
                    return GestureDetector(
                      onTap: () => setS(() => selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                          color: chosen
                              ? _purple.withValues(alpha: 0.20)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: chosen
                                ? _purple.withValues(alpha: 0.60)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(e,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ── Preview ───────────────────────────────────────
              if (nameCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(selectedEmoji,
                          style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Text(
                        nameCtrl.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Add button ───────────────────────────────────
              GestureDetector(
                onTap: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(ctx);
                  _addMeal(name, selectedEmoji);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Add to my favourites',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
