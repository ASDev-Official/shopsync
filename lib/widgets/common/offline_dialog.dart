import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:m3e_collection/m3e_collection.dart';

class OfflineDialog extends StatefulWidget {
  final String featureName;

  const OfflineDialog({
    super.key,
    required this.featureName,
  });

  @override
  State<OfflineDialog> createState() => _OfflineDialogState();

  // Move the static show method to the StatefulWidget class
  static Future<void> show(BuildContext context, String featureName) {
    return showDialog<void>(
      context: context,
      builder: (context) => OfflineDialog(featureName: featureName),
    );
  }
}

class _OfflineDialogState extends State<OfflineDialog>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Start the animation and repeat
    _lottieController.forward();
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lottieController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
      icon: SizedBox(
        width: 200,
        height: 200,
        child: Lottie.asset(
          'assets/animations/no_internet.json',
          controller: _lottieController,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
      title: Text(
        'No Internet Connection',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'You\'re currently offline and can\'t access ${widget.featureName}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? const Color(0xFFE0E0E0) : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF757575),
            ),
          ),
        ],
      ),
      actions: [
        ButtonM3E(
          onPressed: () => Navigator.of(context).pop(),
          label: const Text('OK'),
          style: ButtonM3EStyle.text,
          size: ButtonM3ESize.md,
        ),
      ],
    );
  }
}
