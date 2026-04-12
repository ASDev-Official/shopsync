import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AndroidSystemAccountsService {
  static const MethodChannel _channel =
      MethodChannel('shopsync/system_accounts');

  static Future<void> _captureChannelException(
    Object error,
    StackTrace stackTrace,
    String method, {
    String? email,
    String? provider,
  }) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'action': method,
        if (email != null) 'email': email,
        if (provider != null) 'provider': provider,
      }),
    );
  }

  static String normalizeProvider(String? provider) {
    final value = provider?.toLowerCase().trim() ?? '';
    if (value.contains('google')) {
      return 'google';
    }
    if (value.contains('password')) {
      return 'password';
    }
    return value;
  }

  static Future<void> addCurrentUserToSystemAccounts({
    String? password,
    String? provider,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (email == null || email.isEmpty) return;

    final inferredProvider = normalizeProvider(provider ??
        (user?.providerData.isNotEmpty == true
            ? user!.providerData.first.providerId
            : 'password'));

    try {
      await _channel.invokeMethod('addOrUpdateAccount', {
        'email': email,
        'uid': user?.uid,
        'displayName': user?.displayName,
        'password': password,
        'provider': inferredProvider,
      });
    } on PlatformException catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'addCurrentUserToSystemAccounts',
        email: email,
        provider: inferredProvider,
      );
    } catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'addCurrentUserToSystemAccounts',
        email: email,
        provider: inferredProvider,
      );
    }
  }

  static Future<bool> removeCurrentUserFromSystemAccounts() async {
    if (kIsWeb || !Platform.isAndroid) return true;

    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) return true;

    try {
      await _channel.invokeMethod('removeAccount', {
        'email': email,
      });
      return true;
    } on PlatformException catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'removeCurrentUserFromSystemAccounts',
        email: email,
      );
      return false;
    } catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'removeCurrentUserFromSystemAccounts',
        email: email,
      );
      return false;
    }
  }

  static Future<void> removeSystemAccountByEmail(String email) async {
    if (kIsWeb || !Platform.isAndroid) return;

    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) return;

    try {
      await _channel.invokeMethod('removeAccount', {
        'email': normalizedEmail,
      });
    } on PlatformException catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'removeSystemAccountByEmail',
        email: normalizedEmail,
      );
    } catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'removeSystemAccountByEmail',
        email: normalizedEmail,
      );
    }
  }

  static Future<List<String>> listSystemAccounts() async {
    if (kIsWeb || !Platform.isAndroid) return const [];

    try {
      final dynamic result = await _channel.invokeMethod('listAccounts');
      if (result is! List) return const [];

      return result
          .whereType<Map>()
          .map((dynamic item) => item['name']?.toString() ?? '')
          .where((String name) => name.isNotEmpty)
          .toList(growable: false);
    } on PlatformException catch (e, stackTrace) {
      await _captureChannelException(e, stackTrace, 'listSystemAccounts');
      return const [];
    } catch (e, stackTrace) {
      await _captureChannelException(e, stackTrace, 'listSystemAccounts');
      return const [];
    }
  }

  static Future<List<Map<String, String>>> listSystemAccountsDetailed() async {
    if (kIsWeb || !Platform.isAndroid) return const [];

    try {
      final dynamic result = await _channel.invokeMethod('listAccounts');
      if (result is! List) return const [];

      return result.whereType<Map>().map((dynamic item) {
        return <String, String>{
          'name': item['name']?.toString() ?? '',
          'uid': item['uid']?.toString() ?? '',
          'displayName': item['displayName']?.toString() ?? '',
          'provider': normalizeProvider(item['provider']?.toString()),
          'hasPassword': item['hasPassword']?.toString() ?? 'false',
        };
      }).toList(growable: false);
    } on PlatformException catch (e, stackTrace) {
      await _captureChannelException(
          e, stackTrace, 'listSystemAccountsDetailed');
      return const [];
    } catch (e, stackTrace) {
      await _captureChannelException(
          e, stackTrace, 'listSystemAccountsDetailed');
      return const [];
    }
  }

  static Future<String?> getStoredPasswordForAccount(String email) async {
    if (kIsWeb || !Platform.isAndroid) return null;

    try {
      final dynamic value = await _channel.invokeMethod('getStoredPassword', {
        'email': email,
      });

      final password = value?.toString();
      if (password == null || password.isEmpty) return null;
      return password;
    } on PlatformException catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'getStoredPasswordForAccount',
        email: email,
      );
      return null;
    } catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'getStoredPasswordForAccount',
        email: email,
      );
      return null;
    }
  }

  static Future<void> openSystemAddAccountFlow() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openSystemAddAccountFlow');
    } on PlatformException catch (e, stackTrace) {
      await _captureChannelException(e, stackTrace, 'openSystemAddAccountFlow');
    } catch (e, stackTrace) {
      await _captureChannelException(e, stackTrace, 'openSystemAddAccountFlow');
    }
  }

  static Future<bool> consumePendingAddAccountRequest() async {
    if (kIsWeb || !Platform.isAndroid) return false;

    try {
      final dynamic value =
          await _channel.invokeMethod('consumePendingAddAccountRequest');
      return value == true;
    } on PlatformException catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'consumePendingAddAccountRequest',
      );
      return false;
    } catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'consumePendingAddAccountRequest',
      );
      return false;
    }
  }

  static Future<void> closeSystemAddAccountFlow({
    required bool completed,
    String? accountName,
    String? accountType,
    String? message,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('closeSystemAddAccountFlow', {
        'completed': completed,
        'accountName': accountName,
        'accountType': accountType,
        'message': message,
      });
    } on PlatformException catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'closeSystemAddAccountFlow',
        email: accountName,
        provider: accountType,
      );
    } catch (e, stackTrace) {
      await _captureChannelException(
        e,
        stackTrace,
        'closeSystemAddAccountFlow',
        email: accountName,
        provider: accountType,
      );
    }
  }
}
