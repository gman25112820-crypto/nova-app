import 'package:flutter/material.dart';

class NovaCookingModuleScreen extends StatelessWidget {
  const NovaCookingModuleScreen({super.key});

  static const String routeName = '/nova-cooking';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F4EE),
        elevation: 0,
        foregroundColor: const Color(0xFF2F2A24),
        title: const Text('Nova Cooking'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            _HeroCard(),
            SizedBox(height: 16),
            _SectionTitle('What this module helps with'),
            SizedBox(height: 10),
            _InfoCard(
              title: 'Simple meal planning',
              body:
                  'Plan realistic meals around energy, budget, family routines, symptoms, preferences, and what is already in the house.',
              icon: Icons.restaurant_menu_rounded,
            ),
            _InfoCard(
              title: 'Low-energy cooking',
              body:
                  'Create quick, gentle cooking plans for days when pain, fatigue, stress, or time are making normal cooking harder.',
              icon: Icons.bolt_rounded,
            ),
            _InfoCard(
              title: 'Family food support',
              body:
                  'Track meals that work for different people in the household, including dislikes, safe foods, packed lunches, and easy wins.',
              icon: Icons.family_restroom_rounded,
            ),
            _InfoCard(
              title: 'Shopping list builder',
              body:
                  'Turn planned meals into a simple shopping list later, with budget-aware swaps and cupboard checks.',
              icon: Icons.shopping_basket_rounded,
            ),
            SizedBox(height: 18),
            _SectionTitle('Privacy-first design'),
            SizedBox(height: 10),
            _SafetyCard(),
            SizedBox(height: 18),
            _SectionTitle('Future tools'),
            SizedBox(height: 10),
            _FutureToolsCard(),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6D8C6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6B8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.soup_kitchen_rounded,
              color: Color(0xFF6A4318),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'A calm cooking helper for real life.',
            style: TextStyle(
              fontSize: 26,
              height: 1.08,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2F2A24),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nova Cooking is for planning meals, shopping, batch cooking, low-energy food days, family preferences, and gentle routine support.',
            style: TextStyle(
              fontSize: 15.5,
              height: 1.45,
              color: Color(0xFF62584C),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF2F2A24),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DED1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8A5A22), size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2F2A24),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF6A6258),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFCFE6D4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova Cooking does not diagnose, prescribe diets, or replace clinical advice.',
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w800,
              color: Color(0xFF214B2A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'It should help the user organise food routines, prepare notes, and make practical plans they choose to keep or share.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF3E6A47),
            ),
          ),
        ],
      ),
    );
  }
}

class _FutureToolsCard extends StatelessWidget {
  const _FutureToolsCard();

  @override
  Widget build(BuildContext context) {
    final tools = [
      'Meal planner',
      'Cupboard check',
      'Shopping list',
      'Low-energy meal ideas',
      'Batch cooking planner',
      'Family preference tracker',
      'Symptom-friendly notes',
      'Exportable cooking routine summary',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F2A24),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tools
            .map(
              (tool) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tool,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F2A24),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}