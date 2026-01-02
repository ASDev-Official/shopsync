import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import '/widgets/ui/loading_spinner.dart';
import '/utils/sentry_auth_utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool hideSignIn;

  const ForgotPasswordScreen({super.key, this.hideSignIn = false});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String _message = '';
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    setState(() {
      final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
      _isEmailValid = _emailController.text.trim().isNotEmpty &&
          emailRegex.hasMatch(_emailController.text.trim());
    });
  }

  String? _getErrorMessage(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'invalid-email':
        return l10n.resetPasswordInvalidEmail;
      case 'user-not-found':
        return l10n.resetPasswordUserNotFound;
      case 'too-many-requests':
        return l10n.resetPasswordTooManyRequests;
      case 'network-request-failed':
        return l10n.resetPasswordNetworkError;
      default:
        return e.message ?? l10n.resetPasswordGenericError;
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
      _isSuccess = false;
    });

    try {
      await _auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isSuccess = true;
        _message = l10n.resetPasswordSuccess;
      });
    } on FirebaseAuthException catch (e, stackTrace) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _message = _getErrorMessage(e, l10n) ?? l10n.resetPasswordGenericError;
        _isSuccess = false;
      });
      await SentryUtils.reportError(e, stackTrace);
    } catch (e, stackTrace) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _message = l10n.resetPasswordError;
        _isSuccess = false;
      });
      await SentryUtils.reportError(e, stackTrace);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Colors.black,
                    Color(0xFF1A1A1A),
                  ]
                : [
                    Colors.green.shade400,
                    Colors.green.shade800,
                    Colors.green.shade900,
                  ],
          ),
        ),
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: isDarkMode ? Colors.green[300] : Colors.white,
                        size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 40),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: isDarkMode
                          ? [Colors.green[300]!, Colors.green[400]!]
                          : [Colors.white, Colors.white.withValues(alpha: 0.9)],
                    ).createShader(bounds),
                    child: Text(
                      l10n.resetPasswordTitle,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.resetPasswordSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode
                          ? Colors.green[100]
                          : Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? Colors.green[300]
                                  : Colors.green.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.resetPasswordEmail,
                              errorText: _emailController.text.isNotEmpty &&
                                      !_isEmailValid
                                  ? l10n.resetPasswordInvalidEmail
                                  : null,
                              labelStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.green[300]
                                    : Colors.green[800],
                                fontSize: 15,
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: isDarkMode
                                    ? Colors.green[300]
                                    : Colors.green[800],
                                size: 22,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.green[300]!
                                      : Colors.green.shade800,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: isDarkMode
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex =
                                  RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              if (_isEmailValid) {
                                _resetPassword();
                              }
                            },
                          ),
                          if (_message.isNotEmpty)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isSuccess
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isSuccess
                                      ? Colors.green.shade200
                                      : Colors.red.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isSuccess
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color:
                                        _isSuccess ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _message,
                                      style: TextStyle(
                                        color: _isSuccess
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ButtonM3E(
                              onPressed: (_isLoading || !_isEmailValid)
                                  ? null
                                  : _resetPassword,
                              enabled: !_isLoading && _isEmailValid,
                              label: _isLoading
                                  ? const CustomLoadingSpinner(
                                      color: Colors.white,
                                      size: 24.0,
                                    )
                                  : Text(
                                      l10n.resetPasswordButton,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                              style: ButtonM3EStyle.filled,
                              size: ButtonM3ESize.lg,
                            ),
                          ),
                          if (!widget.hideSignIn) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Remember your password?',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.green[100]
                                            ?.withValues(alpha: 0.9)
                                        : Colors.green[900]
                                            ?.withValues(alpha: 0.9),
                                    fontSize: 15,
                                  ),
                                ),
                                ButtonM3E(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  },
                                  label: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  style: ButtonM3EStyle.text,
                                  size: ButtonM3ESize.sm,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    super.dispose();
  }
}
