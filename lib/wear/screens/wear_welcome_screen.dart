import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'package:shopsync/services/google_auth.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'wear_login_screen.dart';
import '../widgets/wear_animated_google_button.dart';

class WearWelcomeScreen extends StatefulWidget {
  const WearWelcomeScreen({super.key});

  @override
  State<WearWelcomeScreen> createState() => _WearWelcomeScreenState();
}

class _WearWelcomeScreenState extends State<WearWelcomeScreen> {
  final _scrollController = ScrollController();
  bool _isGoogleLoading = false;
  String? _errorMessage;
  bool _hasTriedCredentialManager = false;

  @override
  void initState() {
    super.initState();
    // Automatically try Credential Manager on launch
    _tryCredentialManagerSignIn();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _tryCredentialManagerSignIn() async {
    if (_hasTriedCredentialManager) return;

    setState(() {
      _hasTriedCredentialManager = true;
      _isGoogleLoading = true;
    });

    try {
      final userCredential =
          await GoogleAuthService.signInWithGoogleCredentialManager();

      if (userCredential != null) {
        // Successfully signed in - auth state change will handle navigation
        return;
      }

      // User canceled or no credentials available
    } catch (e, stackTrace) {
      // Credential Manager error - show error message
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({
            'screen': 'WearWelcomeScreen',
            'action': 'auto_credential_manager'
          }));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential =
          await GoogleAuthService.signInWithGoogleCredentialManager();

      if (userCredential == null) {
        // User canceled
        setState(() {
          _isGoogleLoading = false;
        });
        return;
      }

      // Success - auth state will handle navigation
    } on FirebaseAuthException catch (e, stackTrace) {
      String message = e.message ?? 'Google Sign-In failed';

      if (e.code == 'account-exists-with-different-credential') {
        message = 'Account exists with different sign-in method';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Check your connection';
      }

      setState(() {
        _errorMessage = message;
      });

      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({
            'screen': 'WearWelcomeScreen',
            'action': 'manual_google_signin'
          }));
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again';
      });

      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({
            'screen': 'WearWelcomeScreen',
            'action': 'manual_google_signin'
          }));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _navigateToEmailLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WearLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            final isActive = mode == WearMode.active;
            final isRound = shape == WearShape.round;

            return Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: RotaryScrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: isRound ? 24.0 : 16.0,
                      vertical: isRound ? 24.0 : 16.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),

                        // App logo
                        Semantics(
                          label: 'ShopSync logo',
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.green.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 40,
                              color: isActive
                                  ? Colors.green[400]
                                  : Colors.green[700],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // App name
                        Text(
                          'ShopSync',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.green[400]
                                : Colors.green[700],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tagline
                        Text(
                          'Shared shopping lists',
                          style: TextStyle(
                            fontSize: 11,
                            color: isActive ? Colors.white70 : Colors.white54,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Error message
                        if (_errorMessage != null)
                          Semantics(
                            liveRegion: true,
                            label: 'Error: $_errorMessage',
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error,
                                      color: Colors.red[300], size: 14),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red[200],
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Continue with Google button
                        WearAnimatedGoogleButton(
                          onPressed: _signInWithGoogle,
                          isLoading: _isGoogleLoading,
                          height: 48.0,
                        ),

                        const SizedBox(height: 12),

                        // Divider with text
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color:
                                    isActive ? Colors.white24 : Colors.white12,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isActive
                                      ? Colors.white54
                                      : Colors.white38,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color:
                                    isActive ? Colors.white24 : Colors.white12,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Email login button
                        Semantics(
                          button: true,
                          enabled: !_isGoogleLoading,
                          label: 'Sign in with email',
                          child: SizedBox(
                            width: double.infinity,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight:
                                    48, // WearOS accessibility requirement
                                minWidth: 48,
                              ),
                              child: OutlinedButton.icon(
                                onPressed: _isGoogleLoading
                                    ? null
                                    : _navigateToEmailLogin,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isActive
                                      ? Colors.green[300]
                                      : Colors.green[700],
                                  side: BorderSide(
                                    color: isActive
                                        ? Colors.green[300]!
                                        : Colors.green[700]!,
                                    width: 2,
                                  ),
                                  minimumSize: const Size(48, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.email,
                                  size: 16,
                                  color: isActive
                                      ? Colors.green[300]
                                      : Colors.green[700],
                                ),
                                label: Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.green[300]
                                        : Colors.green[700],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Registration note
                        Semantics(
                          label:
                              'Use your phone to register if you do not have an account',
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Use your phone to register\nif you don\'t have an account',
                              style: TextStyle(
                                fontSize: 9,
                                color:
                                    isActive ? Colors.white38 : Colors.white24,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
