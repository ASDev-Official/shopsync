import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';

class RestartingScreen extends StatefulWidget {
  const RestartingScreen({super.key});

  @override
  State<RestartingScreen> createState() => _RestartingScreenState();
}

class _RestartingScreenState extends State<RestartingScreen> {
  Timer? _restartTimer;
  bool _restartFailed = false;

  void _showManualRestartState() {
    if (!mounted) return;
    setState(() {
      _restartFailed = true;
    });
  }

  Future<void> _restartOrFallback() async {
    try {
      final restarted = await Restart.restartApp();
      if (restarted) {
        return;
      }
      _showManualRestartState();
    } on MissingPluginException {
      _showManualRestartState();
    } catch (_) {
      _showManualRestartState();
    }
  }

  @override
  void initState() {
    super.initState();
    _restartTimer = Timer(const Duration(seconds: 2), () async {
      await _restartOrFallback();
    });
  }

  @override
  void dispose() {
    _restartTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_restartFailed,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_restartFailed) ...[
                  const CustomLoadingSpinner(size: 64),
                  const SizedBox(height: 24),
                  Text(
                    l10n.restartingShopSync,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 72,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.restartRequiredTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.restartRequiredBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
