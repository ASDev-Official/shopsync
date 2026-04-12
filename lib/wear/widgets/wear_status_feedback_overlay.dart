import 'package:flutter/material.dart';

class WearStatusFeedbackOverlay extends StatelessWidget {
  const WearStatusFeedbackOverlay({
    super.key,
    required this.visible,
    required this.isSuccess,
  });

  final bool visible;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final icon = isSuccess ? Icons.check_rounded : Icons.close;
    final bgColor = isSuccess
        ? Colors.green.withValues(alpha: 0.9)
        : Colors.red.withValues(alpha: 0.9);

    return IgnorePointer(
      ignoring: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: visible ? 1 : 0,
        child: Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
      ),
    );
  }
}
