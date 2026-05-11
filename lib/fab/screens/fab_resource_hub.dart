import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// FAB RESOURCE HUB
// Real help directory â€” no shame, no jargon
// Organised by what the family needs right now
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class FabResourceHub extends StatefulWidget {
  const FabResourceHub({super.key});

  @override
  State<FabResourceHub> createState() => _FabResourceHubState();
}

class _FabResourceHubState extends State<FabResourceHub> {
  String _filter = 'All';

  final List<String> _filters = [
    'All', 'Anxiety', 'Sleep', 'ADHD & Autism', 'Family', 'Crisis'
  ];

  final List<_Resource> _resources = [
    _Resource(
      name: 'YoungMinds Parent Helpline',
      desc: 'Free support for parents worried about their child\'s mental health. Available Monâ€“Fri 9amâ€“4pm.',
      contact: '0808 802 5544',
      url: 'youngminds.org.uk',
      tags: ['Anxiety', 'Family', 'ADHD & Autism'],
      urgent: false,
      free: true,
      emoji: 'ðŸ’›',
    ),
    _Resource(
      name: 'Kooth',
      desc: 'Free, anonymous online mental health support for young people. Text-based counselling available daily.',
      contact: 'kooth.com',
      url: 'kooth.com',
      tags: ['Anxiety', 'Sleep'],
      urgent: false,
      free: true,
      emoji: 'ðŸ’¬',
    ),
    _Resource(
      name: 'The Sleep Charity',
      desc: 'Specialist sleep support for children including those with SEND and anxiety-related sleep issues.',
      contact: 'thesleepcharity.org.uk',
      url: 'thesleepcharity.org.uk',
      tags: ['Sleep'],
      urgent: false,
      free: true,
      emoji: 'ðŸŒ™',
    ),
    _Resource(
      name: 'ADHD UK',
      desc: 'Run by people with ADHD for people with ADHD. Support, advice and community while waiting for assessment.',
      contact: 'adhduk.co.uk',
      url: 'adhduk.co.uk',
      tags: ['ADHD & Autism'],
      urgent: false,
      free: true,
      emoji: 'âš¡',
    ),
    _Resource(
      name: 'National Autistic Society',
      desc: 'Guidance for families awaiting or going through autism assessment. Helpline and online community.',
      contact: '0808 800 4104',
      url: 'autism.org.uk',
      tags: ['ADHD & Autism'],
      urgent: false,
      free: true,
      emoji: 'ðŸŒˆ',
    ),
    _Resource(
      name: 'Cafcass',
      desc: 'Represents children in family court. Resources for children going through parental separation including books for under 12s.',
      contact: 'cafcass.gov.uk',
      url: 'cafcass.gov.uk',
      tags: ['Family'],
      urgent: false,
      free: true,
      emoji: 'ðŸ›ï¸',
    ),
    _Resource(
      name: 'Gingerbread',
      desc: 'Support and advice for single parents going through separation. Free community and helpline.',
      contact: '0808 802 0925',
      url: 'gingerbread.org.uk',
      tags: ['Family'],
      urgent: false,
      free: true,
      emoji: 'ðŸª',
    ),
    _Resource(
      name: 'Place2Be',
      desc: 'Mental health support in schools. Ask your school if they\'re connected â€” no waiting list if they are.',
      contact: 'place2be.org.uk',
      url: 'place2be.org.uk',
      tags: ['Anxiety', 'Family'],
      urgent: false,
      free: true,
      emoji: 'ðŸ«',
    ),
    _Resource(
      name: 'Relate',
      desc: 'Family and relationship counselling. Sliding scale fees based on income. Helps families through separation.',
      contact: 'relate.org.uk',
      url: 'relate.org.uk',
      tags: ['Family'],
      urgent: false,
      free: false,
      emoji: 'â¤ï¸',
    ),
    _Resource(
      name: 'Childline',
      desc: 'Free, confidential helpline for children and young people. Available 24/7 by phone or online chat.',
      contact: '0800 1111',
      url: 'childline.org.uk',
      tags: ['Crisis', 'Anxiety'],
      urgent: true,
      free: true,
      emoji: 'ðŸ“ž',
    ),
    _Resource(
      name: 'Samaritans',
      desc: 'Free confidential support 24 hours a day, 365 days a year. For anyone in distress.',
      contact: '116 123',
      url: 'samaritans.org',
      tags: ['Crisis'],
      urgent: true,
      free: true,
      emoji: 'ðŸ†˜',
    ),
    _Resource(
      name: 'Right to Choose',
      desc: 'If your GP has referred you for ADHD/autism assessment, you may have the legal right to choose your provider â€” cutting waiting times significantly.',
      contact: 'Ask your GP',
      url: 'nhs.uk',
      tags: ['ADHD & Autism'],
      urgent: false,
      free: true,
      emoji: 'âœ…',
    ),
  ];

  List<_Resource> get _filtered {
    if (_filter == 'All') return _resources;
    return _resources.where((r) => r.tags.contains(_filter)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0820),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildIntro(),
            _buildFilters(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                physics: const BouncingScrollPhysics(),
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _buildCard(_filtered[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        const Text('Get Help',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2D1B5E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFFF6FB7).withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          const Text('ðŸ’›', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Real help, no waiting lists where possible. All free unless marked otherwise.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 12,
                  height: 1.4),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final selected = _filter == _filters[i];
          return GestureDetector(
            onTap: () => setState(() => _filter = _filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFF6FB0)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFF6FB0)
                      : Colors.white.withValues(alpha: 0.10),
                ),
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white.withValues(alpha: 0.60),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(_Resource r) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: r.urgent
            ? const Color(0xFF3D0A0A)
            : const Color(0xFF1A1035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: r.urgent
              ? const Color(0xFFFF5252).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(r.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(r.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
            ),
            if (r.urgent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.4)),
                ),
                child: const Text('24/7',
                    style: TextStyle(
                        color: Color(0xFFFF5252),
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            if (!r.free)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('Paid',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
          ]),
          const SizedBox(height: 8),
          Text(r.desc,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.60),
                  fontSize: 12,
                  height: 1.4)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: r.contact));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${r.contact} copied'),
                  backgroundColor: const Color(0xFF2D1B5E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  r.contact.contains('.') ? Icons.language : Icons.phone,
                  color: const Color(0xFFFF6FB7),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(r.contact,
                    style: const TextStyle(
                        color: Color(0xFFFF6FB7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Icon(Icons.copy, color: Colors.white.withValues(alpha: 0.3), size: 12),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Resource {
  final String name;
  final String desc;
  final String contact;
  final String url;
  final List<String> tags;
  final bool urgent;
  final bool free;
  final String emoji;

  const _Resource({
    required this.name,
    required this.desc,
    required this.contact,
    required this.url,
    required this.tags,
    required this.urgent,
    required this.free,
    required this.emoji,
  });
}

