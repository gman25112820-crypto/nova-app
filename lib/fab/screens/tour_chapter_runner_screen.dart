import 'package:flutter/material.dart';

import '../models/tour_page.dart';
import '../services/read_aloud_service.dart';
import '../widgets/fab_design_system.dart';
import '../widgets/read_aloud_button.dart';

class TourChapterRunnerScreen extends StatefulWidget {
  final String title;
  final List<TourPage> pages;

  const TourChapterRunnerScreen({
    super.key,
    required this.title,
    required this.pages,
  });

  @override
  State<TourChapterRunnerScreen> createState() =>
      _TourChapterRunnerScreenState();
}

class _TourChapterRunnerScreenState extends State<TourChapterRunnerScreen> {
  int _index = 0;

  static const _bg = Color(0xFF0D0820);
  static const _panel = Color(0xFF1A1040);
  static const _text = Color(0xFFF2EFFF);
  static const _muted = Color(0xFFB9AED6);
  static const _soft = Color(0xFF8A8EAB);
  static const _purple = Color(0xFF6C63FF);
  static const _pink = Color(0xFFFF6B8A);
  static const _teal = Color(0xFF00C9A7);
  static const _amber = Color(0xFFFFB830);

  bool get _isFirst => _index == 0;
  bool get _isLast => _index == widget.pages.length - 1;

  void _goBack() {
    if (_isFirst) return;
    FabReadAloudService.instance.stop();
    setState(() => _index--);
  }

  void _goNext() {
    FabReadAloudService.instance.stop();
    if (_isLast) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _index++);
  }

  void _exploreOnMyOwn() {
    FabReadAloudService.instance.stop();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    FabReadAloudService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.pages[_index];
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          return SafeArea(
            top: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                wide ? 28 : 16,
                12,
                wide ? 28 : 16,
                28,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _EddieHeader(prompt: page.eddiePrompt),
                        if (_isFirst) ...[
                          const SizedBox(height: 12),
                          const FabExploringTogetherCallout(),
                        ],
                        const SizedBox(height: 18),
                        _PageCard(page: page),
                        FabReadAloudButton(
                          id: 'tour-${widget.title}-$_index',
                          text: '${page.title}. ${page.body}',
                          margin: const EdgeInsets.only(top: 12),
                          color: _teal,
                        ),
                        const SizedBox(height: 18),
                        _PageDots(
                          count: widget.pages.length,
                          currentIndex: _index,
                        ),
                        const SizedBox(height: 22),
                        _Controls(
                          isFirst: _isFirst,
                          isLast: _isLast,
                          onBack: _goBack,
                          onNext: _goNext,
                          onExplore: _exploreOnMyOwn,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EddieHeader extends StatelessWidget {
  final String? prompt;

  const _EddieHeader({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return FabEddieCallout(
      title: 'Eddie says',
      text: prompt ?? 'Take your time. You can stop whenever you want.',
      titleStyle: const TextStyle(
        color: _TourChapterRunnerScreenState._text,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        fontFamily: 'DM Sans',
      ),
      textStyle: const TextStyle(
        color: _TourChapterRunnerScreenState._muted,
        fontSize: 13,
        height: 1.45,
        fontFamily: 'DM Sans',
      ),
    );
  }
}

class _PageCard extends StatelessWidget {
  final TourPage page;

  const _PageCard({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _TourChapterRunnerScreenState._panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _TourChapterRunnerScreenState._teal.withValues(alpha: 0.26),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _TourChapterRunnerScreenState._teal.withValues(
                alpha: 0.16,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              color: _TourChapterRunnerScreenState._teal,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.title,
            style: const TextStyle(
              color: _TourChapterRunnerScreenState._text,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            page.body,
            style: const TextStyle(
              color: _TourChapterRunnerScreenState._muted,
              fontSize: 16,
              height: 1.5,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageDots({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${currentIndex + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final selected = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: selected ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: selected
                  ? _TourChapterRunnerScreenState._amber
                  : _TourChapterRunnerScreenState._soft.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onExplore;

  const _Controls({
    required this.isFirst,
    required this.isLast,
    required this.onBack,
    required this.onNext,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        TextButton(
          onPressed: onExplore,
          style: TextButton.styleFrom(
            foregroundColor: _TourChapterRunnerScreenState._text.withValues(
              alpha: 0.80,
            ),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          ),
          child: const Text(
            'Explore on my own',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
        if (!isFirst)
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 17),
            label: const Text('Back'),
            style: TextButton.styleFrom(
              foregroundColor: _TourChapterRunnerScreenState._text.withValues(
                alpha: 0.84,
              ),
              backgroundColor: _TourChapterRunnerScreenState._purple.withValues(
                alpha: 0.12,
              ),
              side: BorderSide(
                color: _TourChapterRunnerScreenState._purple.withValues(
                  alpha: 0.30,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        FilledButton.icon(
          onPressed: onNext,
          icon: Icon(
            isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
            size: 17,
          ),
          label: Text(isLast ? 'Done' : 'Next'),
          style: FilledButton.styleFrom(
            foregroundColor: const Color(0xFF220815),
            backgroundColor: _TourChapterRunnerScreenState._pink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
      ],
    );
  }
}
