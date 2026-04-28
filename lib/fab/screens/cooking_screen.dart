import 'package:flutter/material.dart';
import '../fab_theme.dart';

class CookingScreen extends StatefulWidget {
  const CookingScreen({super.key});
  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  String _filter = 'All';
  String? _activeRecipe;

  static const _categories = ['All', 'Quick', 'Breakfast', 'Lunch', 'Dinner', 'Snack', 'Comfort'];

  static const _recipes = [
    {
      'name': 'Cheesy scrambled eggs',
      'cat': 'Breakfast',
      'time': '5 min',
      'cal': 320,
      'easy': true,
      'icon': '🍳',
      'desc': 'Protein-packed, easy, no mess.',
      'ingredients': ['2 eggs', 'Splash of milk', 'Handful of grated cheese', 'Salt & pepper', 'Butter'],
      'steps': [
        'Crack eggs into a bowl, add milk and whisk.',
        'Melt a knob of butter in a pan on low heat.',
        'Pour in eggs and stir slowly with a spatula.',
        'When nearly set, take off heat and stir in cheese.',
        'Season and serve on toast.',
      ],
    },
    {
      'name': 'Tomato soup & toast',
      'cat': 'Lunch',
      'time': '10 min',
      'cal': 280,
      'easy': true,
      'icon': '🍲',
      'desc': 'Warming and simple. Great on bad days.',
      'ingredients': ['1 tin tomato soup', '2 slices bread', 'Butter', 'Optional: grated cheese'],
      'steps': [
        'Open the tin and pour soup into a saucepan.',
        'Heat gently on medium, stirring occasionally.',
        'Toast the bread and butter it.',
        'Pour soup into a bowl. Add cheese if you like.',
        'Dip the toast in.',
      ],
    },
    {
      'name': 'Pasta arrabiata',
      'cat': 'Dinner',
      'time': '20 min',
      'cal': 480,
      'easy': true,
      'icon': '🍝',
      'desc': 'One pan. Very filling. Keeps well.',
      'ingredients': ['200g pasta', '1 tin chopped tomatoes', '2 garlic cloves', 'Pinch chilli flakes', 'Olive oil', 'Salt'],
      'steps': [
        'Boil salted water and cook pasta until tender.',
        'While pasta cooks, fry garlic in olive oil for 1 min.',
        'Add tin of tomatoes and chilli flakes.',
        'Simmer sauce for 8 minutes until thickened.',
        'Drain pasta and stir into the sauce.',
        'Serve with parmesan if you have it.',
      ],
    },
    {
      'name': 'Baked beans on toast',
      'cat': 'Quick',
      'time': '5 min',
      'cal': 340,
      'easy': true,
      'icon': '🫘',
      'desc': 'Classic. Cheap. Surprisingly good protein.',
      'ingredients': ['1 tin baked beans', '2 slices bread', 'Butter'],
      'steps': [
        'Open tin and heat beans in a saucepan or microwave.',
        'Toast the bread.',
        'Butter the toast and pour beans over.',
        'Optional: add grated cheese on top.',
      ],
    },
    {
      'name': 'Overnight oats',
      'cat': 'Breakfast',
      'time': '5 min prep',
      'cal': 350,
      'easy': true,
      'icon': '🥣',
      'desc': 'Make tonight, eat tomorrow. Zero effort morning.',
      'ingredients': ['80g oats', '200ml milk or oat milk', '1 tbsp honey or syrup', 'Fruit of your choice'],
      'steps': [
        'Put oats in a jar or bowl.',
        'Pour milk over and stir.',
        'Add honey and stir again.',
        'Cover and put in the fridge overnight.',
        'In the morning, top with fruit and eat cold.',
      ],
    },
    {
      'name': 'Chicken & rice',
      'cat': 'Dinner',
      'time': '25 min',
      'cal': 520,
      'easy': false,
      'icon': '🍗',
      'desc': 'Filling, healthy, batch-cookable.',
      'ingredients': ['2 chicken thighs or breast', '150g rice', 'Garlic', 'Soy sauce', 'Oil', 'Frozen peas'],
      'steps': [
        'Cook rice according to packet instructions.',
        'Season chicken with salt, pepper, garlic.',
        'Fry chicken in oil on medium heat, 6 min each side.',
        'Add soy sauce and a splash of water, simmer 3 min.',
        'Stir frozen peas into rice when almost done.',
        'Serve chicken over rice.',
      ],
    },
    {
      'name': 'Banana & peanut butter on toast',
      'cat': 'Snack',
      'time': '2 min',
      'cal': 260,
      'easy': true,
      'icon': '🍌',
      'desc': 'Energy, protein, tastes like dessert.',
      'ingredients': ['1 slice bread', '1 tbsp peanut butter', '1 banana'],
      'steps': [
        'Toast the bread.',
        'Spread peanut butter on it.',
        'Slice banana and lay on top.',
      ],
    },
    {
      'name': 'Egg fried rice',
      'cat': 'Comfort',
      'time': '15 min',
      'cal': 440,
      'easy': true,
      'icon': '🍳',
      'desc': 'Perfect for leftover rice. Very satisfying.',
      'ingredients': ['Bowl of cooked rice (day-old is best)', '2 eggs', 'Frozen peas and sweetcorn', 'Soy sauce', 'Oil', 'Optional: ham or chicken'],
      'steps': [
        'Heat oil in a wok or large pan on high.',
        'Add rice and stir-fry for 2 minutes.',
        'Push rice to the side, crack in eggs, scramble.',
        'Mix eggs through the rice.',
        'Add peas, corn, soy sauce and stir everything together.',
        'Cook 3 more minutes and serve.',
      ],
    },
    {
      'name': 'Jacket potato',
      'cat': 'Comfort',
      'time': '60 min (oven) / 10 min (microwave)',
      'cal': 380,
      'easy': true,
      'icon': '🥔',
      'desc': 'Virtually zero effort. Loads of fillings possible.',
      'ingredients': ['1 large potato', 'Butter', 'Filling: beans, cheese, tuna — your choice'],
      'steps': [
        'Prick potato all over with a fork.',
        'Microwave on high for 8-10 min (or oven at 200°C for 60 min).',
        'Check it\'s soft all the way through with a knife.',
        'Cut open, add butter and your filling.',
      ],
    },
    {
      'name': 'Greek yoghurt bowl',
      'cat': 'Snack',
      'time': '2 min',
      'cal': 180,
      'easy': true,
      'icon': '🥛',
      'desc': 'Great protein snack. Very settling on the stomach.',
      'ingredients': ['200g Greek yoghurt', 'Drizzle of honey', 'Handful of berries or chopped banana', 'Optional: granola'],
      'steps': [
        'Spoon yoghurt into a bowl.',
        'Add fruit on top.',
        'Drizzle honey.',
        'Add granola if you have it.',
      ],
    },
  ];

  List<Map> get _filtered => _filter == 'All'
    ? _recipes.cast<Map>()
    : _recipes.where((r) => r['cat'] == _filter || (_filter == 'Quick' && r['easy'] == true)).cast<Map>().toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FabColors.bg,
      appBar: AppBar(
        backgroundColor: FabColors.mid,
        title: const Text('Cooking & Recipes', style: TextStyle(color: FabColors.pink, fontSize: 16)),
        elevation: 0,
      ),
      body: Column(children: [
        // Category filter
        SizedBox(
          height: 48,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            children: _categories.map((c) => GestureDetector(
              onTap: () => setState(() { _filter = c; _activeRecipe = null; }),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: _filter == c ? FabColors.pink.withValues(alpha: 0.2) : FabColors.panel,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _filter == c ? FabColors.pink : const Color(0x1EFF8FAB),
                    width: _filter == c ? 1 : 0.5,
                  ),
                ),
                child: Text(c, style: TextStyle(
                  fontSize: 12,
                  color: _filter == c ? FabColors.pink : FabColors.muted,
                )),
              ),
            )).toList(),
          ),
        ),

        // Recipe list
        Expanded(
          child: _activeRecipe != null
            ? _buildRecipeDetail(_activeRecipe!)
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) => _buildRecipeCard(_filtered[i]),
              ),
        ),
      ]),
    );
  }

  Widget _buildRecipeCard(Map r) => GestureDetector(
    onTap: () => setState(() => _activeRecipe = r['name'] as String),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FabColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5),
      ),
      child: Row(children: [
        Text(r['icon'] as String, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(r['name'] as String,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: FabColors.text)),
            if (r['easy'] == true) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: FabColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Easy', style: TextStyle(fontSize: 9, color: FabColors.teal)),
              ),
            ],
          ]),
          const SizedBox(height: 3),
          Text(r['desc'] as String,
            style: const TextStyle(fontSize: 11, color: FabColors.muted)),
          const SizedBox(height: 6),
          Row(children: [
            _tag('⏱ ${r['time']}', FabColors.muted),
            const SizedBox(width: 8),
            _tag('🔥 ${r['cal']} kcal', FabColors.gold),
          ]),
        ])),
        const Icon(Icons.chevron_right, color: FabColors.muted, size: 18),
      ]),
    ),
  );

  Widget _buildRecipeDetail(String name) {
    final r = _recipes.firstWhere((r) => r['name'] == name);
    final ingredients = r['ingredients'] as List;
    final steps = r['steps'] as List;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Back
        GestureDetector(
          onTap: () => setState(() => _activeRecipe = null),
          child: Row(children: [
            const Icon(Icons.arrow_back_ios, size: 14, color: FabColors.pink),
            const Text('All recipes', style: TextStyle(fontSize: 13, color: FabColors.pink)),
          ]),
        ),
        const SizedBox(height: 16),

        // Header
        Row(children: [
          Text(r['icon'] as String, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r['name'] as String,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: FabColors.text)),
            const SizedBox(height: 4),
            Row(children: [
              _tag('⏱ ${r['time']}', FabColors.muted),
              const SizedBox(width: 8),
              _tag('🔥 ${r['cal']} kcal', FabColors.gold),
            ]),
          ])),
        ]),

        const SizedBox(height: 16),

        // Ingredients
        const Text('YOU\'LL NEED', style: TextStyle(fontSize: 10, color: FabColors.pink, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FabColors.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ingredients.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: FabColors.pink, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(i as String, style: const TextStyle(fontSize: 13, color: FabColors.text)),
              ]),
            )).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Steps
        const Text('HOW TO MAKE IT', style: TextStyle(fontSize: 10, color: FabColors.pink, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        ...steps.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FabColors.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x1EFF8FAB), width: 0.5),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: FabColors.pink.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text('${e.key + 1}',
                style: const TextStyle(fontSize: 12, color: FabColors.pink, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(e.value as String,
              style: const TextStyle(fontSize: 13, color: FabColors.text, height: 1.4))),
          ]),
        )),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => setState(() => _activeRecipe = null),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: FabColors.panel2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('Back to recipes',
              style: TextStyle(fontSize: 14, color: FabColors.text))),
          ),
        ),
      ]),
    );
  }

  Widget _tag(String label, Color col) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: col.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label, style: TextStyle(fontSize: 10, color: col)),
  );
}
