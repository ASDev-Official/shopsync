import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '/utils/sentry_auth_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:credential_manager/credential_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shopsync/services/platform/connectivity_service.dart';
import 'package:m3e_collection/m3e_collection.dart';
import '/services/auth/google_auth.dart';
import '/widgets/auth/animated_google_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<String> _getVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return 'Version ${packageInfo.version} (${packageInfo.buildNumber})';
  }

  // ignore: unused_field
  String _errorMessage = '';
  bool _isGoogleLoading = false;
  bool _hasTriedCredentialManager = false;

  // Widget _getGoogleButtonImage(bool isDarkMode) {
  //   if (Theme.of(context).platform == TargetPlatform.android) {
  //     return Image.asset(
  //       isDarkMode
  //           ? 'assets/badges/google/android/png@4x/dark/android_dark_rd_na@4x.png'
  //           : 'assets/badges/google/android/png@4x/light/android_light_rd_na@4x.png',
  //       height: 48,
  //       fit: BoxFit.contain,
  //     );
  //   } else {
  //     return Image.asset(
  //       isDarkMode
  //           ? 'assets/badges/google/web/png@4x/dark/web_dark_rd_na@4x.png'
  //           : 'assets/badges/google/web/png@4x/light/web_light_rd_na@4x.png',
  //       height: 48,
  //       fit: BoxFit.contain,
  //     );
  //   }
  // }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = '';
    });

    try {
      UserCredential? userCredential;

      // On Android, use Credential Manager
      if (!kIsWeb && Platform.isAndroid) {
        userCredential =
            await GoogleAuthService.signInWithGoogleCredentialManager();
      } else {
        // On web, use standard Google Sign-In
        userCredential = await GoogleAuthService.signInWithGoogle();
      }

      if (userCredential == null) {
        // User canceled the sign-in
        setState(() {
          _isGoogleLoading = false;
        });
        return;
      }

      if (!mounted) return;
    } on FirebaseAuthException catch (e, stackTrace) {
      String errorMessage =
          e.message ?? 'An error occurred with Google Sign-In';

      // Special handling for account-exists-with-different-credential
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage =
            'An account with this email already exists. Please sign in with email/password first, then link your Google account from the Profile screen.';
      }

      setState(() {
        _errorMessage = errorMessage;
      });
      await SentryUtils.reportError(e, stackTrace);
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage =
            'An error occurred with Google Sign-In. Please try again.';
      });
      await SentryUtils.reportError(e, stackTrace);
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
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
        // Successfully signed in with Credential Manager
        if (!mounted) return;
        return;
      }

      // User canceled or no credentials available - continue to show normal login
    } catch (e) {
      // Credential Manager not available or error occurred - continue to show normal login
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // On Android, try Credential Manager automatically
    if (!kIsWeb && Platform.isAndroid) {
      _tryCredentialManagerSignIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final connectivityService = ConnectivityService();

    // final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: isDarkMode
                ? [
                    Colors.black,
                    Color(0xFF1A1A1A),
                  ]
                : [
                    const Color(0xFF4CAF50),
                    const Color(0xFF2E7D32),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Logo and App Name Section
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: isDarkMode ? Colors.green[300] : Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // App Title with Animation
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDarkMode
                        ? [Colors.green[300]!, Colors.green[400]!]
                        : [Colors.white, Colors.white70],
                  ).createShader(bounds),
                  child: Text(
                    'ShopSync',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.green[300] : Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tagline
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Align(
                    child: Text(
                      'Share shopping lists with family and friends.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.green[100] : Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Continue with Google Button with morphing animation
                AnimatedGoogleButton(
                  onPressed: _signInWithGoogle,
                  isLoading: _isGoogleLoading,
                  isDarkMode: isDarkMode,
                ),

                const SizedBox(height: 20),

                // Login Button
                ButtonM3E(
                  onPressed: () async {
                    if (await connectivityService
                        .checkConnectivityAndShowDialog(context,
                            feature: 'ShopSync Authentication')) {
                      Navigator.pushNamed(context, '/login');
                    }
                  },
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  style: ButtonM3EStyle.filled,
                  size: ButtonM3ESize.lg,
                ),

                const SizedBox(height: 20),

                // Sign Up Button
                ButtonM3E(
                  onPressed: () async {
                    if (await connectivityService
                        .checkConnectivityAndShowDialog(context,
                            feature: 'ShopSync Authentication')) {
                      // Navigate to registration screen
                      Navigator.pushNamed(context, '/register');
                    }
                  },
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  style: ButtonM3EStyle.outlined,
                  size: ButtonM3ESize.lg,
                ),

                // const SizedBox(height: 20),

                // Google Sign In Button
                // InkWell(
                //   onTap: () async {
                //     try {
                //       final credential = await AuthService.signInWithGoogle();
                //       if (credential != null && mounted) {
                //         Navigator.pushReplacementNamed(context, '/home');
                //       }
                //     } catch (e) {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(
                //           content: Text('Failed to sign in with Google'),
                //           backgroundColor: Colors.red,
                //         ),
                //       );
                //     }
                //   },
                //   child: Container(
                //     height: 48, // Standard height for Google Sign In button
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(4),
                //     ),
                //     child: _getGoogleButtonImage(isDarkMode),
                //   ),
                // ),

                const Spacer(flex: 1),

                // Version info
                FutureBuilder<String>(
                  future: _getVersionInfo(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Loading version information...',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.green[100]?.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
