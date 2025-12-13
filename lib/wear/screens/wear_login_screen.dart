import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'package:shopsync/services/auth/google_auth.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../widgets/wear_animated_google_button.dart';

class WearLoginScreen extends StatefulWidget {
  const WearLoginScreen({super.key});

  @override
  State<WearLoginScreen> createState() => _WearLoginScreenState();
}

class _WearLoginScreenState extends State<WearLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  bool _canSignIn = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final isValidEmail = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(email);
    final canSignIn = isValidEmail && password.isNotEmpty;
    if (canSignIn != _canSignIn) {
      setState(() {
        _canSignIn = canSignIn;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled.';
          break;
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
          hint: Hint.withMap(
              {'screen': 'WearLoginScreen', 'action': 'google_signin'}));
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again';
      });

      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap(
              {'screen': 'WearLoginScreen', 'action': 'google_signin'}));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return Scaffold(
              backgroundColor:
                  mode == WearMode.active ? Colors.black : Colors.black,
              body: SafeArea(
                child: RotaryScrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: shape == WearShape.round ? 24.0 : 16.0,
                      vertical: shape == WearShape.round ? 20.0 : 16.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'ShopSync',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: mode == WearMode.active
                                ? Colors.green[400]
                                : Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue',
                          style: TextStyle(
                            fontSize: 12,
                            color: mode == WearMode.active
                                ? Colors.white70
                                : Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email field
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(fontSize: 11),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            enabled: !_isLoading,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                        ),
                        const SizedBox(height: 12),

                        // Password field
                        TextField(
                          controller: _passwordController,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(fontSize: 11),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            enabled: !_isLoading,
                          ),
                          obscureText: true,
                          autocorrect: false,
                        ),
                        const SizedBox(height: 16),

                        // Error message
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Login button
                        Semantics(
                          button: true,
                          enabled: !_isLoading && _canSignIn,
                          label:
                              _isLoading ? 'Signing in' : 'Sign in with email',
                          child: SizedBox(
                            width: double.infinity,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minHeight: 48, minWidth: 48),
                              child: ElevatedButton(
                                onPressed: (_isLoading || !_canSignIn)
                                    ? null
                                    : _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _canSignIn && !_isLoading
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(48, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Divider with "or"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: mode == WearMode.active
                                    ? Colors.white24
                                    : Colors.white12,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: mode == WearMode.active
                                      ? Colors.white54
                                      : Colors.white38,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: mode == WearMode.active
                                    ? Colors.white24
                                    : Colors.white12,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Google Sign-In button
                        WearAnimatedGoogleButton(
                          onPressed: _signInWithGoogle,
                          isLoading: _isGoogleLoading,
                          height: 48.0,
                        ),
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Use your phone to register\nif you don\'t have an account',
                            style: TextStyle(
                              fontSize: 10,
                              color: mode == WearMode.active
                                  ? Colors.white54
                                  : Colors.white38,
                            ),
                            textAlign: TextAlign.center,
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
