import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '/screens/auth/login.dart';
import '/services/auth/android_system_accounts_service.dart';
import '/services/auth/google_auth.dart';

class SystemAddAccountScreen extends StatefulWidget {
  const SystemAddAccountScreen({super.key});

  @override
  State<SystemAddAccountScreen> createState() => _SystemAddAccountScreenState();
}

class _SystemAddAccountScreenState extends State<SystemAddAccountScreen> {
  bool _isBusy = false;
  String? _errorMessage;

  Future<void> _closeFlow({required bool completed}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    await AndroidSystemAccountsService.closeSystemAddAccountFlow(
      completed: completed,
      accountName: currentUser?.email,
      accountType: 'com.aadishsamir.shopsync.account',
      message: completed ? null : 'User cancelled ShopSync account addition',
    );
  }

  static String _localizedAuthError(
    BuildContext context,
    FirebaseAuthException error,
  ) {
    return LoginScreen.getLocalizedAuthErrorMessage(context, error);
  }

  Future<void> _addGoogleAccount() async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final credential =
          await GoogleAuthService.signInWithGoogleCredentialManager();
      if (credential == null) {
        await _closeFlow(completed: false);
        return;
      }

      if (!mounted) return;
      await _closeFlow(completed: true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
        hint: Hint.withMap({'action': 'system_add_google_account'}),
      );
      setState(() {
        _errorMessage = _localizedAuthError(context, e);
      });
    } catch (error, stackTrace) {
      if (!mounted) return;
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({'action': 'system_add_google_account_generic'}),
      );
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.googleSignInGeneric;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _addNormalAccount() async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(returnSuccessResult: true),
        ),
      );

      if (success == true && mounted) {
        await _closeFlow(completed: true);
      } else if (mounted) {
        await _closeFlow(completed: false);
      }
    } catch (e) {
      if (!mounted) return;
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
        hint: Hint.withMap({'action': 'system_add_normal_account'}),
      );
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.loginGenericError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.accountManager),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _closeFlow(completed: false);
          },
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _closeFlow(completed: false);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.accountManagerSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.manageAccountsDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  ButtonM3E(
                    onPressed: _isBusy ? null : _addGoogleAccount,
                    label: Text(l10n.addGoogleAccount),
                    style: ButtonM3EStyle.filled,
                    size: ButtonM3ESize.md,
                  ),
                  const SizedBox(height: 12),
                  ButtonM3E(
                    onPressed: _isBusy ? null : _addNormalAccount,
                    label: Text(l10n.addEmailPasswordAccount),
                    style: ButtonM3EStyle.outlined,
                    size: ButtonM3ESize.md,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
