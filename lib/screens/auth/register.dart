import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import '/utils/sentry_auth_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _validateName() {
    setState(() {
      _isNameValid = _nameController.text.trim().length >= 2;
    });
  }

  void _validateEmail() {
    setState(() {
      final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
      _isEmailValid = _emailController.text.trim().isNotEmpty &&
          emailRegex.hasMatch(_emailController.text.trim());
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 6;
    });
  }

  String? _getErrorMessage(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'email-already-in-use':
        return l10n.registerEmailExists;
      case 'invalid-email':
        return l10n.registerInvalidEmail;
      case 'operation-not-allowed':
        return l10n.loginOperationNotAllowed;
      case 'weak-password':
        return l10n.registerWeakPassword;
      case 'too-many-requests':
        return l10n.registerTooManyRequests;
      case 'network-request-failed':
        return l10n.registerNetworkError;
      default:
        return e.message ?? l10n.registerGenericError;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'displayName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e, stackTrace) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = _getErrorMessage(e, l10n) ?? l10n.registerGenericError;
      });
      await SentryUtils.reportError(e, stackTrace);
    } catch (e, stackTrace) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.registerGenericError;
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
                      l10n.registerCreateAccount,
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
                    l10n.registerSignUp,
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
                            controller: _nameController,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? Colors.green[300]
                                  : Colors.green.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.registerName,
                              errorText: _nameController.text.isNotEmpty &&
                                      !_isNameValid
                                  ? l10n.registerNameError
                                  : null,
                              labelStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.green[300]
                                    : Colors.green[800],
                                fontSize: 15,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
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
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.registerEnterName;
                              }
                              if (value.trim().length < 2) {
                                return l10n.registerNameTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
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
                              labelText: l10n.registerEmail,
                              errorText: _emailController.text.isNotEmpty &&
                                      !_isEmailValid
                                  ? l10n.loginInvalidEmail
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
                            textInputAction: TextInputAction.next,
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
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? Colors.green[300]
                                  : Colors.green.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.registerPassword,
                              errorText: _passwordController.text.isNotEmpty &&
                                      !_isPasswordValid
                                  ? 'Password must be at least 6 characters'
                                  : null,
                              helperText:
                                  'Password must be at least 6 characters',
                              helperStyle: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.green[100]
                                    : Colors.green[800]?.withValues(alpha: 0.6),
                              ),
                              labelStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.green[300]
                                    : Colors.green[800],
                                fontSize: 15,
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: isDarkMode
                                    ? Colors.green[300]
                                    : Colors.green[800],
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: isDarkMode
                                      ? Colors.green[300]
                                      : Colors.green[800],
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
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
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.registerEnterPassword;
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              if (_isNameValid &&
                                  _isEmailValid &&
                                  _isPasswordValid) {
                                _register();
                              }
                            },
                          ),
                          if (_errorMessage.isNotEmpty)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error,
                                      color: Colors.red.shade400, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
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
                              onPressed: (_isLoading ||
                                      !_isNameValid ||
                                      !_isEmailValid ||
                                      !_isPasswordValid)
                                  ? null
                                  : _register,
                              enabled: !_isLoading &&
                                  _isNameValid &&
                                  _isEmailValid &&
                                  _isPasswordValid,
                              label: _isLoading
                                  ? const CustomLoadingSpinner(
                                      color: Colors.white,
                                      size: 24.0,
                                    )
                                  : Text(
                                      l10n.registerButton,
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Divider with "OR" text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDarkMode
                              ? Colors.green[100]?.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.green[100]?.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDarkMode
                              ? Colors.green[100]?.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.green[100]?.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                        ),
                      ),
                      ButtonM3E(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        label: Text(
                          l10n.signIn,
                          style: const TextStyle(
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateName);
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
