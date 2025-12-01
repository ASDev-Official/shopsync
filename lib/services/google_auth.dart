import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:credential_manager/credential_manager.dart';

/// Service for handling Google Sign-In with Firebase Authentication
/// Supports web, Android (phone and WearOS) platforms
/// Uses Credential Manager on Android/WearOS for seamless sign-in
class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static final CredentialManager _credentialManager = CredentialManager();

  static bool _isInitialized = false;
  static const String _webClientId =
      '160863676221-levmvhj0j8ae1b7peiodun6hb8s1jspc.apps.googleusercontent.com';

  /// Initialize Google Sign-In with platform-specific configuration
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        // For web, use the client ID from Firebase console
        await _googleSignIn.initialize(
          clientId: _webClientId,
        );
      } else {
        // For Android (phone and WearOS), client ID comes from google-services.json
        await _googleSignIn.initialize();
      }

      _isInitialized = true;
      if (kDebugMode) {
        print('Google Sign-In initialized successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error initializing Google Sign-In: $e');
      }
      await _logError(e, stackTrace, 'initialize');
      rethrow;
    }
  }

  /// Initialize Credential Manager for Android/WearOS
  static Future<void> _initCredentialManager() async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      if (!_credentialManager.isSupportedPlatform) {
        if (kDebugMode) {
          print('Credential Manager not supported on this platform');
        }
        return;
      }

      await _credentialManager.init(
        preferImmediatelyAvailableCredentials: true,
        googleClientId: _webClientId,
      );

      if (kDebugMode) {
        print(
            'Credential Manager initialized. GMS available: ${_credentialManager.isGmsAvailable}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Credential Manager: $e');
      }
    }
  }

  /// Sign in with Google using Credential Manager for Android/WearOS
  /// Shows Android Credential Manager picker with saved Google accounts
  /// Returns UserCredential on success, null if user cancels or no credentials
  static Future<UserCredential?> signInWithGoogleCredentialManager() async {
    if (kIsWeb) {
      throw UnsupportedError('Use signInWithGoogle for web platform');
    }

    await initialize();
    await _initCredentialManager();

    // Check if Google Play Services is available
    if (!_credentialManager.isGmsAvailable) {
      throw Exception('Google Play Services is not available on this device');
    }

    try {
      // Use saveGoogleCredential to trigger the Credential Manager picker
      // useButtonFlow: false = One-tap sign-in with Credential Manager UI
      final googleIdTokenCredential =
          await _credentialManager.saveGoogleCredential(
        useButtonFlow: false,
      );

      if (googleIdTokenCredential == null) {
        // User canceled
        return null;
      }

      // Use the Google ID token to sign in to Firebase
      final googleCredential = GoogleAuthProvider.credential(
        idToken: googleIdTokenCredential.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(googleCredential);

      // Create user profile in Firestore if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserProfile(userCredential.user!);
      }

      return userCredential;
    } on CredentialException catch (e, stackTrace) {
      if (kDebugMode) {
        print('Credential Manager Error: ${e.message}');
      }
      // Handle specific error codes
      if (e.code == 207) {
        // No Google account on device - plugin automatically opens Add Account settings
        if (kDebugMode) {
          print('No Google account found, opening Add Account settings');
        }
        return null;
      } else if (e.code == 209) {
        // Google Play Services not available
        throw Exception('Google Play Services is not available');
      }
      await _logError(e, stackTrace, 'signInWithGoogleCredentialManager');
      // User likely canceled
      return null;
    } on FirebaseAuthException catch (e, stackTrace) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      await _logError(e, stackTrace, 'signInWithGoogleCredentialManager');
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      await _logError(e, stackTrace, 'signInWithGoogleCredentialManager');
      rethrow;
    }
  }

  /// Sign in with Google (for web platform)
  /// Returns UserCredential on success, null if user cancels
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // On web, use Firebase Auth's signInWithPopup directly
        // The google_sign_in package doesn't support authenticate() on web
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        try {
          final userCredential = await _auth.signInWithPopup(googleProvider);

          // Create user profile in Firestore if this is a new user
          if (userCredential.additionalUserInfo?.isNewUser ?? false) {
            await _createUserProfile(userCredential.user!);
          }

          if (kDebugMode) {
            print(
                'Successfully signed in with Google: ${userCredential.user?.email}');
          }

          return userCredential;
        } catch (e) {
          // User likely canceled or closed the popup
          if (kDebugMode) {
            print('User canceled Google Sign-In popup: $e');
          }
          return null;
        }
      } else {
        // On non-web platforms, use google_sign_in package
        await initialize();

        final GoogleSignInAccount googleUser =
            await _googleSignIn.authenticate();

        // Obtain the auth details from the account
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        // Create a new credential (only idToken is needed in v7+)
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        final userCredential = await _auth.signInWithCredential(credential);

        // Create user profile in Firestore if this is a new user
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _createUserProfile(userCredential.user!);
        }

        if (kDebugMode) {
          print(
              'Successfully signed in with Google: ${userCredential.user?.email}');
        }

        return userCredential;
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }
      await _logError(e, stackTrace, 'signInWithGoogle');
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
        print('Stack trace: $stackTrace');
      }
      await _logError(e, stackTrace, 'signInWithGoogle');
      rethrow;
    }
  }

  /// Link Google account to existing Firebase user
  /// Allows users to sign in with both email/password and Google
  static Future<UserCredential?> linkGoogleAccount() async {
    // Ensure initialized
    await initialize();

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in',
      );
    }

    try {
      String? idToken;

      // Use Credential Manager on Android/WearOS
      if (!kIsWeb && Platform.isAndroid) {
        await _initCredentialManager();

        // Check if Credential Manager is available
        if (_credentialManager.isSupportedPlatform &&
            _credentialManager.isGmsAvailable) {
          try {
            if (kDebugMode) {
              print('Using Credential Manager for linking Google account');
            }

            // Use Credential Manager with button flow for account selection
            // This shows the Google account picker UI
            final googleIdTokenCredential = await _credentialManager
                .saveGoogleCredential(useButtonFlow: true);

            if (googleIdTokenCredential == null) {
              if (kDebugMode) {
                print('User canceled Credential Manager flow');
              }
              return null;
            }

            idToken = googleIdTokenCredential.idToken;

            if (kDebugMode) {
              print(
                  'Successfully retrieved Google ID token from Credential Manager');
            }
          } on CredentialException catch (e) {
            if (kDebugMode) {
              print('Credential Manager error (code: ${e.code}): ${e.message}');
            }

            // Fall back to standard Google Sign-In on credential manager errors
            if (kDebugMode) {
              print('Falling back to standard Google Sign-In for linking');
            }

            try {
              final GoogleSignInAccount googleUser =
                  await _googleSignIn.authenticate();
              final GoogleSignInAuthentication googleAuth =
                  googleUser.authentication;
              idToken = googleAuth.idToken;
            } catch (e) {
              // User canceled
              if (kDebugMode) {
                print('User canceled Google Sign-In: $e');
              }
              return null;
            }
          }
        } else {
          // Credential Manager not available, use standard Google Sign-In
          if (kDebugMode) {
            print(
                'Credential Manager not available, using standard Google Sign-In');
          }

          try {
            final GoogleSignInAccount googleUser =
                await _googleSignIn.authenticate();
            final GoogleSignInAuthentication googleAuth =
                googleUser.authentication;
            idToken = googleAuth.idToken;
          } catch (e) {
            // User canceled
            if (kDebugMode) {
              print('User canceled Google Sign-In: $e');
            }
            return null;
          }
        }
      } else {
        // Web: use Firebase Auth's linkWithPopup directly
        if (kIsWeb) {
          try {
            final GoogleAuthProvider googleProvider = GoogleAuthProvider();
            final userCredential =
                await currentUser.linkWithPopup(googleProvider);

            if (kDebugMode) {
              print('Successfully linked Google account');
            }

            return userCredential;
          } catch (e) {
            // User canceled the sign-in
            if (kDebugMode) {
              print('User canceled Google Sign-In popup: $e');
            }
            return null;
          }
        } else {
          // Non-Android, non-web platforms: use standard Google Sign-In
          try {
            final GoogleSignInAccount googleUser =
                await _googleSignIn.authenticate();
            final GoogleSignInAuthentication googleAuth =
                googleUser.authentication;
            idToken = googleAuth.idToken;
          } catch (e) {
            // User canceled the sign-in
            if (kDebugMode) {
              print('User canceled Google Sign-In: $e');
            }
            return null;
          }
        }
      }

      // Only proceed with credential linking if not on web (web already handled above)
      if (kIsWeb) {
        // This should never be reached, but added for safety
        return null;
      }

      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message: 'Failed to retrieve Google ID token',
        );
      }

      // Create a new credential (only idToken is needed in v7+)
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // Link credential to current user
      final userCredential = await currentUser.linkWithCredential(credential);

      if (kDebugMode) {
        print('Successfully linked Google account');
      }

      return userCredential;
    } on FirebaseAuthException catch (e, stackTrace) {
      if (e.code == 'provider-already-linked') {
        if (kDebugMode) {
          print('Google account is already linked to this user');
        }
      } else if (e.code == 'credential-already-in-use') {
        if (kDebugMode) {
          print('This Google account is already used by another user');
        }
      }
      await _logError(e, stackTrace, 'linkGoogleAccount');
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error linking Google account: $e');
      }
      await _logError(e, stackTrace, 'linkGoogleAccount');
      rethrow;
    }
  }

  /// Unlink Google account from current user
  /// User will no longer be able to sign in with Google (unless re-linked)
  static Future<firebase_auth.User?> unlinkGoogleAccount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in',
      );
    }

    try {
      // Check if Google is linked
      final isGoogleLinked = currentUser.providerData
          .any((provider) => provider.providerId == 'google.com');

      if (!isGoogleLinked) {
        if (kDebugMode) {
          print('Google account is not linked to this user');
        }
        return currentUser;
      }

      // Unlink the Google provider
      final user = await currentUser.unlink('google.com');

      if (kDebugMode) {
        print('Successfully unlinked Google account');
      }

      return user;
    } on FirebaseAuthException catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error unlinking Google account: ${e.code} - ${e.message}');
      }
      await _logError(e, stackTrace, 'unlinkGoogleAccount');
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error unlinking Google account: $e');
      }
      await _logError(e, stackTrace, 'unlinkGoogleAccount');
      rethrow;
    }
  }

  /// Sign out from both Google and Firebase
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      if (kDebugMode) {
        print('Successfully signed out from Google and Firebase');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      await _logError(e, stackTrace, 'signOut');
      rethrow;
    }
  }

  /// Create user profile in Firestore for new users
  static Future<void> _createUserProfile(firebase_auth.User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      // Only create if profile doesn't exist
      if (!docSnapshot.exists) {
        await userDoc.set({
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'signInMethod': 'google',
        });

        if (kDebugMode) {
          print('Created user profile for ${user.uid}');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error creating user profile: $e');
      }
      await _logError(e, stackTrace, '_createUserProfile');
      // Don't rethrow - profile creation failure shouldn't block sign-in
    }
  }

  /// Log error to Sentry
  static Future<void> _logError(
    Object error,
    StackTrace stackTrace,
    String method,
  ) async {
    try {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'method': 'GoogleAuthService.$method',
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging to Sentry: $e');
      }
    }
  }
}
