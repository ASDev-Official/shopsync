// import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

// class GoogleAuth {
//   static final FirebaseAuth _auth = FirebaseAuth.instance;
//   static final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email'],
//   );

//   static Future<UserCredential?> signInWithGoogle() async {
//     try {
//       // Trigger the authentication flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       if (googleUser == null) return null;

//       // Obtain the auth details from the request
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       // Create a new credential
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Sign in to Firebase with the credential
//       return await _auth.signInWithCredential(credential);
//     } catch (e, stackTrace) {
//       if (kDebugMode) {
//         print('Error signing in with Google: $e');
//         print('Stack trace: $stackTrace');
//       }

//       // Use withScope to add context data instead
//       await Sentry.captureException(
//         e,
//         stackTrace: stackTrace,
//         withScope: (scope) {
//           scope.setContexts('auth_info', {
//             'provider': 'google',
//             'method': 'signInWithGoogle',
//           });
//           scope.setTag('error_type', 'authentication_error');
//         },
//       );

//       return null;
//     }
//   }
// }
