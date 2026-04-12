import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import 'package:shopsync/services/auth/android_system_accounts_service.dart';
import 'package:shopsync/services/auth/google_auth.dart';
import '/wear/widgets/wear_status_feedback_overlay.dart';
import 'wear_login_screen.dart';

class WearAccountManagerScreen extends StatefulWidget {
  const WearAccountManagerScreen({super.key});

  @override
  State<WearAccountManagerScreen> createState() =>
      _WearAccountManagerScreenState();
}

class _WearAccountManagerScreenState extends State<WearAccountManagerScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSwitching = false;
  bool _isAddingGoogle = false;
  bool _isAddingEmailPassword = false;
  bool _isRemoving = false;
  String? _errorMessage;
  bool _showFeedback = false;
  bool _feedbackSuccess = true;

  User? get _user => FirebaseAuth.instance.currentUser;

  String _mapExceptionToLocalizedMessage(Object error, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'account-exists-with-different-credential':
        case 'email-already-in-use':
          return l10n.loginAccountExists;
        case 'invalid-credential':
          return l10n.loginInvalidCredentials;
        case 'operation-not-allowed':
          return l10n.loginOperationNotAllowed;
        case 'user-disabled':
          return l10n.loginUserDisabled;
        case 'user-not-found':
          return l10n.loginUserNotFound;
        case 'wrong-password':
          return l10n.loginWrongPassword;
        case 'too-many-requests':
          return l10n.loginTooManyRequests;
        case 'network-request-failed':
          return l10n.loginNetworkError;
        default:
          return error.message ?? l10n.loginGenericError;
      }
    }

    if (error is PlatformException) {
      switch (error.code) {
        case 'network_error':
        case 'network-request-failed':
          return l10n.loginNetworkError;
        case 'sign_in_cancelled':
        case 'canceled':
        case 'cancelled':
          return l10n.googleSignInGeneric;
        default:
          return l10n.loginGenericError;
      }
    }

    return l10n.loginGenericError;
  }

  void _showStatusFeedback(bool isSuccess) {
    if (!mounted) return;

    setState(() {
      _feedbackSuccess = isSuccess;
      _showFeedback = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _showFeedback = false;
      });
    });
  }

  Future<void> _switchAccount() async {
    setState(() {
      _isSwitching = true;
      _errorMessage = null;
    });

    try {
      final userCredential =
          await GoogleAuthService.signInWithAndroidCredentialManager();

      if (userCredential != null && mounted) {
        _showStatusFeedback(true);
      }
    } catch (error, stackTrace) {
      _showStatusFeedback(false);
      if (!mounted) return;
      setState(() {
        _errorMessage = _mapExceptionToLocalizedMessage(error, context);
      });
      if (foundation.kDebugMode) {
        foundation.debugPrint('Wear account switch failed: $error');
        if (error is! FirebaseAuthException && error is! PlatformException) {
          foundation.debugPrintStack(stackTrace: stackTrace);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSwitching = false;
        });
      }
    }
  }

  Future<void> _addGoogleAccount() async {
    setState(() {
      _isAddingGoogle = true;
      _errorMessage = null;
    });

    try {
      final userCredential =
          await GoogleAuthService.signInWithGoogleCredentialManager();

      if (userCredential != null && mounted) {
        _showStatusFeedback(true);
      }
    } catch (error, stackTrace) {
      _showStatusFeedback(false);
      if (!mounted) return;
      setState(() {
        _errorMessage = _mapExceptionToLocalizedMessage(error, context);
      });
      if (foundation.kDebugMode) {
        foundation.debugPrint('Wear Google add-account failed: $error');
        if (error is! FirebaseAuthException && error is! PlatformException) {
          foundation.debugPrintStack(stackTrace: stackTrace);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingGoogle = false;
        });
      }
    }
  }

  Future<void> _addEmailPasswordAccount() async {
    setState(() {
      _isAddingEmailPassword = true;
      _errorMessage = null;
    });

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WearLoginScreen()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingEmailPassword = false;
        });
      }
    }
  }

  Future<void> _removeCurrentAccount() async {
    final shouldRemove = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.removeCurrentAccount),
            content: Text(AppLocalizations.of(context)!.removeAccountDetails),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.removeCurrentAccount),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldRemove) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isRemoving = true;
      _errorMessage = null;
    });

    try {
      final removed = await AndroidSystemAccountsService
          .removeCurrentUserFromSystemAccounts();
      if (!removed) {
        throw StateError('Unable to remove current account from device');
      }
      await GoogleAuthService.signOut();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _mapExceptionToLocalizedMessage(error, context);
      });
      if (foundation.kDebugMode) {
        foundation.debugPrint('Wear account removal/sign-out failed: $error');
        foundation.debugPrintStack(stackTrace: stackTrace);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRemoving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildActionCard({
    required WearMode mode,
    required VoidCallback? onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
  }) {
    return Card(
      color: mode == WearMode.active ? Colors.grey[900] : Colors.grey[850],
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: iconColor ?? Colors.green[400],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11,
                          color: mode == WearMode.active
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 9,
                          color: mode == WearMode.active
                              ? Colors.white54
                              : Colors.white38,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color:
                      mode == WearMode.active ? Colors.white38 : Colors.white24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            final l10n = AppLocalizations.of(context)!;

            return Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  SafeArea(
                    child: RotaryScrollbar(
                      controller: _scrollController,
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: shape == WearShape.round ? 32.0 : 16.0,
                                right: shape == WearShape.round ? 32.0 : 16.0,
                                top: shape == WearShape.round ? 24.0 : 16.0,
                                bottom: 12.0,
                              ),
                              child: Center(
                                child: Text(
                                  l10n.accountManager,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: mode == WearMode.active
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    shape == WearShape.round ? 28.0 : 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                l10n.manageAccountsDescription,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: mode == WearMode.active
                                      ? Colors.white54
                                      : Colors.white38,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          if (_errorMessage != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      shape == WearShape.round ? 28.0 : 16.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          SliverPadding(
                            padding: EdgeInsets.only(
                              left: shape == WearShape.round ? 32.0 : 12.0,
                              right: shape == WearShape.round ? 32.0 : 12.0,
                              bottom: 16.0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Card(
                                color: mode == WearMode.active
                                    ? Colors.grey[900]
                                    : Colors.grey[850],
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.account_circle,
                                            size: 16,
                                            color: mode == WearMode.active
                                                ? Colors.white54
                                                : Colors.white38,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _user?.displayName ??
                                                  l10n.noSavedAccounts,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: mode == WearMode.active
                                                    ? Colors.white
                                                    : Colors.white70,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_user?.email != null) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.email,
                                              size: 14,
                                              color: mode == WearMode.active
                                                  ? Colors.white38
                                                  : Colors.white24,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _user!.email!,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: mode == WearMode.active
                                                      ? Colors.white54
                                                      : Colors.white38,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(
                              left: shape == WearShape.round ? 32.0 : 12.0,
                              right: shape == WearShape.round ? 32.0 : 12.0,
                              bottom: 12.0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _buildActionCard(
                                mode: mode,
                                onTap: _isSwitching ? null : _switchAccount,
                                icon: Icons.switch_account,
                                title: l10n.switchAccount,
                                subtitle:
                                    l10n.useCredentialManagerToSwitchAccounts,
                                iconColor: Colors.green[400],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(
                              left: shape == WearShape.round ? 32.0 : 12.0,
                              right: shape == WearShape.round ? 32.0 : 12.0,
                              bottom: 12.0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _buildActionCard(
                                mode: mode,
                                onTap:
                                    _isAddingGoogle ? null : _addGoogleAccount,
                                icon: Icons.account_circle,
                                title: l10n.addGoogleAccount,
                                subtitle: l10n.signInWithGoogleAccount,
                                iconColor: Colors.blue[300],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(
                              left: shape == WearShape.round ? 32.0 : 12.0,
                              right: shape == WearShape.round ? 32.0 : 12.0,
                              bottom: 12.0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _buildActionCard(
                                mode: mode,
                                onTap: _isAddingEmailPassword
                                    ? null
                                    : _addEmailPasswordAccount,
                                icon: Icons.email,
                                title: l10n.addEmailPasswordAccount,
                                subtitle: l10n.signInWithEmailAndPassword,
                                iconColor: Colors.orange[300],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(
                              left: shape == WearShape.round ? 32.0 : 12.0,
                              right: shape == WearShape.round ? 32.0 : 12.0,
                              bottom: 36.0,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _buildActionCard(
                                mode: mode,
                                onTap:
                                    _isRemoving ? null : _removeCurrentAccount,
                                icon: Icons.delete_outline,
                                title: l10n.removeCurrentAccount,
                                subtitle: l10n.removeAccountDetails,
                                iconColor: Colors.red[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  WearStatusFeedbackOverlay(
                    visible: _showFeedback,
                    isSuccess: _feedbackSuccess,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
