import 'package:flutter/material.dart';

import '../fab_theme.dart';
import '../services/read_aloud_service.dart';

class FabReadAloudButton extends StatelessWidget {
  final String id;
  final String text;
  final EdgeInsetsGeometry margin;
  final Color color;

  const FabReadAloudButton({
    super.key,
    required this.id,
    required this.text,
    this.margin = EdgeInsets.zero,
    this.color = FabColors.pinkAction,
  });

  @override
  Widget build(BuildContext context) {
    final service = FabReadAloudService.instance;

    return ValueListenableBuilder<FabReadAloudSnapshot>(
      valueListenable: service.state,
      builder: (context, snapshot, _) {
        final active = snapshot.isActive(id);
        final canRead = snapshot.available && text.trim().isNotEmpty;
        final label = canRead
            ? active
                ? 'Stop reading'
                : 'Read this to me'
            : "Reading isn't available on this device right now.";

        return Padding(
          padding: margin,
          child: Semantics(
            button: true,
            enabled: canRead,
            label: label,
            child: Tooltip(
              message: label,
              child: OutlinedButton.icon(
                onPressed: canRead
                    ? () => service.toggle(id: id, text: text)
                    : null,
                icon: Icon(
                  active
                      ? Icons.stop_circle_outlined
                      : Icons.volume_up_outlined,
                  size: 18,
                ),
                label: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  disabledForegroundColor:
                      FabColors.muted.withValues(alpha: 0.65),
                  side: BorderSide(
                    color: canRead
                        ? color.withValues(alpha: 0.55)
                        : FabColors.muted.withValues(alpha: 0.25),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
