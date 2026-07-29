import 'package:flutter/material.dart';

import '../fab_theme.dart';

class FabSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const section = 28.0;
}

class FabRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const card = 16.0;
  static const callout = 18.0;
  static const sheet = 20.0;
  static const pill = 999.0;
}

class FabDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 180);
  static const gentle = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 400);
}

class FabTextStyles {
  static const screenTitle = TextStyle(
    color: FabColors.text,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: 'DM Sans',
  );

  static const sectionTitle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontFamily: 'DM Sans',
  );

  static const body = TextStyle(
    color: FabColors.muted,
    fontSize: 13,
    height: 1.45,
    fontFamily: 'DM Sans',
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontFamily: 'DM Sans',
  );

  static const tinyLabel = TextStyle(fontSize: 11, fontFamily: 'DM Sans');
}

class FabShadows {
  static BoxShadow soft(Color color) => BoxShadow(
    color: color.withValues(alpha: 0.22),
    blurRadius: 18,
    offset: const Offset(0, 8),
  );
}

class FabChildCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const FabChildCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.all(FabSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? FabColors.panelDark,
        borderRadius: BorderRadius.circular(FabRadii.card),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: child,
    );
  }
}

class FabSectionTitle extends StatelessWidget {
  final String text;

  const FabSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: FabTextStyles.sectionTitle);
  }
}

class FabSecondaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color color;

  const FabSecondaryActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color = FabColors.pinkAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FabRadii.pill),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: FabSpacing.md,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(FabRadii.pill),
            border: Border.all(color: color.withValues(alpha: 0.42)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 15),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FabEddieCallout extends StatelessWidget {
  final String title;
  final String text;
  final double avatarSize;
  final TextStyle? titleStyle;
  final TextStyle? textStyle;

  const FabEddieCallout({
    super.key,
    required this.title,
    required this.text,
    this.avatarSize = 68,
    this.titleStyle,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FabSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [FabColors.panelAlt, FabColors.panelDark],
        ),
        borderRadius: BorderRadius.circular(FabRadii.callout),
        border: Border.all(color: FabColors.purple.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: FabColors.pinkAction.withValues(alpha: 0.35),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/characters/jack_russell.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle ?? FabTextStyles.screenTitle),
                const SizedBox(height: 6),
                Text(text, style: textStyle ?? FabTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
