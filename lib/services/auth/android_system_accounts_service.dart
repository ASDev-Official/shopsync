import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class AndroidSystemAccountsService {
  static const MethodChannel _channel =
      MethodChannel('shopsync/system_accounts');

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

    await _channel.invokeMethod('addOrUpdateAccount', {
      'email': email,
      'uid': user?.uid,
      'displayName': user?.displayName,
      'password': password,
      'provider': inferredProvider,
    });
  }

  static Future<void> removeCurrentUserFromSystemAccounts() async {
    if (kIsWeb || !Platform.isAndroid) return;

    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) return;

    await _channel.invokeMethod('removeAccount', {
      'email': email,
    });
  }

  static Future<List<String>> listSystemAccounts() async {
    if (kIsWeb || !Platform.isAndroid) return const [];

    final dynamic result = await _channel.invokeMethod('listAccounts');
    if (result is! List) return const [];

    return result
        .whereType<Map>()
        .map((dynamic item) => item['name']?.toString() ?? '')
        .where((String name) => name.isNotEmpty)
        .toList(growable: false);
  }

  static Future<List<Map<String, String>>> listSystemAccountsDetailed() async {
    if (kIsWeb || !Platform.isAndroid) return const [];

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
  }

  static Future<String?> getStoredPasswordForAccount(String email) async {
    if (kIsWeb || !Platform.isAndroid) return null;

    final dynamic value = await _channel.invokeMethod('getStoredPassword', {
      'email': email,
    });

    final password = value?.toString();
    if (password == null || password.isEmpty) return null;
    return password;
  }

  static Future<void> openSystemAddAccountFlow() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await _channel.invokeMethod('openSystemAddAccountFlow');
  }

  static Future<bool> consumePendingAddAccountRequest() async {
    if (kIsWeb || !Platform.isAndroid) return false;

    final dynamic value =
        await _channel.invokeMethod('consumePendingAddAccountRequest');
    return value == true;
  }

  static Future<void> closeSystemAddAccountFlow() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await _channel.invokeMethod('closeSystemAddAccountFlow');
  }
}
