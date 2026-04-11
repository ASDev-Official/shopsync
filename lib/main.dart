// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shopsync/services/platform/connectivity_service.dart';
import 'package:shopsync/services/locale_service.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import 'config/firebase_options.dart';
import 'screens/auth/welcome.dart';
import 'screens/auth/login.dart';
import 'screens/auth/system_add_account_screen.dart';
import 'screens/auth/register.dart';
import 'screens/home.dart';
import 'screens/settings/ai_preference_setup.dart';
import 'services/data/ai_preference_service.dart';
import 'screens/settings/gravatar_preference_setup.dart';
import 'services/data/gravatar_service.dart';
import 'screens/settings/profile.dart';
import 'screens/auth/forgot_password.dart';
import 'screens/maintenance/maintenance_screen.dart';
import 'screens/onboarding/onboarding.dart';
import 'screens/status/outage_dialog.dart';
import 'screens/settings/settings.dart';
import 'screens/migration/migration_screen.dart';
import 'screens/settings/feedback.dart';
import 'screens/lists/manage_categories.dart';
import 'services/platform/update_service.dart';
import 'services/platform/maintenance_service.dart';
import 'services/platform/statuspage_service.dart';
import 'services/storage/shared_prefs.dart';
import 'services/platform/home_widget_service.dart';
import 'services/auth/android_system_accounts_service.dart';
import 'services/auth/google_auth.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'widgets/status/outage_banner.dart';
import 'widgets/user/user_avatar.dart';
import 'core/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize connectivity service with error handling
  try {
    await ConnectivityService().initialize();
  } catch (e) {
    if (kDebugMode) {
      // Log the error in debug mode
      print('Failed to initialize ConnectivityService: $e');
    }
    // App will continue with fallback connectivity checks
  }

  // Initialize home widget service
  try {
    await HomeWidgetService.initialize();
    // Initial update with system theme detection
    final isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    await HomeWidgetService.updateWidget(isDarkMode: isDark);
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize HomeWidgetService: $e');
    }
  }

  unawaited(MobileAds.instance.initialize());

  // Start Statuspage polling early
  try {
    StatuspageService.startPolling();
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Statuspage polling initialization error: $e');
    }
    await Sentry.captureException(e,
        stackTrace: stackTrace,
        hint: Hint.withMap({'action': 'statuspage_start_polling'}));
  }

  // Register ShopSync application license
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('LICENSE');
    yield LicenseEntryWithLineBreaks(['shopsync'], license);
  });

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: ThemeData.estimateBrightnessForColor(
                WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                        Brightness.dark
                    ? Colors.grey[900]!
                    : Colors.white,
              ) ==
              Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      systemNavigationBarIconBrightness:
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark
              ? Brightness.light
              : Brightness.dark,
      statusBarIconBrightness:
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark
              ? Brightness.light
              : Brightness.dark,
    ),
  );

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://0e9830280e9e2bd8123cab218ce80a00@o4509262568816640.ingest.us.sentry.io/4509262583431168';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(SentryWidget(child: ShopSyncApp())),
  );
}

class ShopSyncApp extends StatefulWidget {
  const ShopSyncApp({super.key});

  @override
  State<ShopSyncApp> createState() => _ShopSyncAppState();

  /// Static method to change locale from anywhere in the app
  static void setLocale(BuildContext context, Locale? newLocale) {
    _ShopSyncAppState? state =
        context.findAncestorStateOfType<_ShopSyncAppState>();
    state?.setLocale(newLocale);
  }
}

class _ShopSyncAppState extends State<ShopSyncApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final savedLocale = await LocaleService.getSavedLocale();
    if (savedLocale != null && mounted) {
      setState(() {
        _locale = savedLocale;
      });
    }
  }

  void setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
    if (locale == null) {
      LocaleService.clearLocale();
    } else {
      LocaleService.saveLocale(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopSync',
      navigatorKey: AppNavigation.navigatorKey,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          brightness: Brightness.light,
        ).copyWith(
          primary: Colors.green[900],
          onPrimary: Colors.white,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android:
                const PredictiveBackPageTransitionsBuilder(),
            TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: const ZoomPageTransitionsBuilder(),
            TargetPlatform.linux: const ZoomPageTransitionsBuilder(),
            TargetPlatform.windows: const ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          brightness: Brightness.dark,
        ).copyWith(
          primary: Colors.green[800],
          onPrimary: Colors.white,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android:
                const PredictiveBackPageTransitionsBuilder(),
            TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: const ZoomPageTransitionsBuilder(),
            TargetPlatform.linux: const ZoomPageTransitionsBuilder(),
            TargetPlatform.windows: const ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      // themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: OutageBanner(),
            ),
          ],
        );
      },
      home: const AuthWrapper(),
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/migration': (context) => const MigrationScreen(),
        '/feedback': (context) => const FeedbackScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/manage-categories') {
          final listId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ManageCategoriesScreen(listId: listId),
          );
        }
        if (settings.name == '/forgot-password') {
          final hideSignIn = settings.arguments as bool? ?? false;
          return MaterialPageRoute(
            builder: (context) => ForgotPasswordScreen(hideSignIn: hideSignIn),
          );
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _cachedUserId;
  Future<bool>? _aiPreferenceFuture;
  Future<bool?>? _gravatarPreferenceFuture;
  late final Future<bool> _isFirstLaunchFuture;
  late final Future<bool> _isSystemAddAccountFlowFuture;

  bool _isInitialLoad = true;
  bool _isCheckingDeviceAccountAvailability = false;
  String? _lastCheckedDeviceAccountUid;
  List<Map<String, String>> _recoveryAccountOptions = const [];
  bool _shouldShowRecoverySelector = false;

  void _updateUserFutures(String uid) {
    if (_cachedUserId != uid) {
      _cachedUserId = uid;
      _aiPreferenceFuture = AIPreferenceService.hasAIPreference();
      _gravatarPreferenceFuture = GravatarService.hasGravatarPreference();
      _isInitialLoad = true;
    }
  }

  void _startDeviceAccountAvailabilityCheck(User user) {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    if (_isCheckingDeviceAccountAvailability ||
        _lastCheckedDeviceAccountUid == user.uid) {
      return;
    }

    _lastCheckedDeviceAccountUid = user.uid;
    _isCheckingDeviceAccountAvailability = true;
    unawaited(_validateCurrentSignedInAccount(user));
  }

  Future<void> _validateCurrentSignedInAccount(User user) async {
    try {
      final accounts =
          await AndroidSystemAccountsService.listSystemAccountsDetailed();
      final currentEmail = user.email?.trim().toLowerCase();

      if (currentEmail == null || currentEmail.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isCheckingDeviceAccountAvailability = false;
          _shouldShowRecoverySelector = false;
          _recoveryAccountOptions = const [];
        });
        return;
      }

      final currentExists = accounts.any(
        (account) =>
            (account['name'] ?? '').trim().toLowerCase() == currentEmail,
      );

      if (currentExists) {
        if (!mounted) return;
        setState(() {
          _isCheckingDeviceAccountAvailability = false;
          _shouldShowRecoverySelector = false;
          _recoveryAccountOptions = const [];
        });
        return;
      }

      final alternatives = accounts
          .where(
            (account) =>
                (account['name'] ?? '').trim().toLowerCase() != currentEmail,
          )
          .toList(growable: false);

      await GoogleAuthService.signOut();

      if (!mounted) return;
      setState(() {
        _isCheckingDeviceAccountAvailability = false;
        _shouldShowRecoverySelector = alternatives.isNotEmpty;
        _recoveryAccountOptions = alternatives;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCheckingDeviceAccountAvailability = false;
        _shouldShowRecoverySelector = false;
        _recoveryAccountOptions = const [];
      });
    }
  }

  void _clearRecoverySelector() {
    if (!mounted) return;
    setState(() {
      _shouldShowRecoverySelector = false;
      _recoveryAccountOptions = const [];
    });
  }

  @override
  void initState() {
    super.initState();
    _isFirstLaunchFuture = SharedPrefs.isFirstLaunch();
    _isSystemAddAccountFlowFuture = !kIsWeb && Platform.isAndroid
        ? AndroidSystemAccountsService.consumePendingAddAccountRequest()
        : Future.value(false);

    // Check for updates after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UpdateService.checkForUpdate(context);
      final hasActiveMaintenance = await _checkMaintenance();
      if (!hasActiveMaintenance) {
        await _checkOutage();
      }
    });
  }

  Future<bool> _checkMaintenance() async {
    final maintenance = await MaintenanceService.checkMaintenance();
    // Uncomment the following lines for testing purposes
    // final updateInfo = await InAppUpdate.checkForUpdate();
    //
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => UpdateAppScreen(onUpdateComplete: (bool completed) {}, updateInfo: updateInfo))
    // );

    if (maintenance != null && mounted) {
      if (maintenance['isUnderMaintenance']) {
        StatuspageService.currentOutage.value = null;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MaintenanceScreen(
              message: maintenance['message'],
              startTime: maintenance['startTime'],
              endTime: maintenance['endTime'],
              isPredictive: false,
            ),
          ),
        );
        return true;
      } else if (maintenance['isPredictive']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => MaintenanceScreen(
            message: maintenance['message'],
            startTime: maintenance['startTime'],
            endTime: maintenance['endTime'],
            isPredictive: true,
          ),
        );
        return false;
      }
    }
    return false;
  }

  Future<void> _checkOutage() async {
    if (MaintenanceService.isMaintenanceActive.value) {
      return;
    }

    try {
      final outage = await StatuspageService.fetchCurrentOutage();
      // Show fullscreen closable dialog once per app run when outage is active
      if (outage.active &&
          mounted &&
          !MaintenanceService.isMaintenanceActive.value) {
        if (!StatuspageService.dialogDismissedThisSession) {
          await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => OutageDialog(outage: outage),
          ).then((_) {
            // Track dismissal regardless of how dialog was closed (button or barrier tap)
            StatuspageService.markDialogDismissed();
          });
        }
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap(
              {'action': 'check_outage', 'context': 'showing_outage_dialog'}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isSystemAddAccountFlowFuture,
      builder: (context, addAccountSnapshot) {
        if (addAccountSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF212121)
                : Colors.white,
            body: Center(
              child: Image.asset(
                'assets/logos/shopsync.png',
                fit: BoxFit.cover,
              ),
            ),
          );
        }

        if (addAccountSnapshot.data == true) {
          return const SystemAddAccountScreen();
        }

        return FutureBuilder<bool>(
          future: _isFirstLaunchFuture,
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF212121)
                    : Colors.white,
                body: Center(
                  child: Image.asset(
                    'assets/logos/shopsync.png',
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }

            if (onboardingSnapshot.data == true) {
              return const OnboardingScreen();
            }

            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // Only show loading on initial connection, not on active/done states
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _isInitialLoad) {
                  return Scaffold(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF212121)
                            : Colors.white,
                    body: Center(
                      child: Image.asset(
                        'assets/logos/shopsync.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }

                // Check if user is logged in
                if (snapshot.hasData && snapshot.data != null) {
                  _startDeviceAccountAvailabilityCheck(snapshot.data!);

                  if (_isCheckingDeviceAccountAvailability) {
                    return Scaffold(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF212121)
                              : Colors.white,
                      body: Center(
                        child: CustomLoadingSpinner(),
                      ),
                    );
                  }

                  // Cache futures keyed to the current user to prevent re-creation on rebuild
                  _updateUserFutures(snapshot.data!.uid);

                  // User is signed in, check if AI preference is set
                  return FutureBuilder<bool>(
                    future: _aiPreferenceFuture,
                    builder: (context, aiSnapshot) {
                      if (aiSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          _isInitialLoad) {
                        return Scaffold(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF212121)
                                  : Colors.white,
                          body: Center(
                            child: CustomLoadingSpinner(),
                          ),
                        );
                      }

                      // If AI preference not set, show mandatory setup screen
                      if (!aiSnapshot.hasData || !aiSnapshot.data!) {
                        _isInitialLoad = false;
                        return const AIPreferenceSetupScreen();
                      }

                      // AI preference is set, now check Gravatar preference
                      return FutureBuilder<bool?>(
                        future: _gravatarPreferenceFuture,
                        builder: (context, gravatarSnapshot) {
                          if (gravatarSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              _isInitialLoad) {
                            return Scaffold(
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF212121)
                                  : Colors.white,
                              body: Center(
                                child: CustomLoadingSpinner(),
                              ),
                            );
                          }

                          // Handle Firestore errors - allow normal startup instead of forcing setup
                          if (gravatarSnapshot.hasError ||
                              gravatarSnapshot.data == null) {
                            _isInitialLoad = false;
                            return const HomeScreen();
                          }

                          // If Gravatar preference not set (false), show mandatory setup screen
                          if (gravatarSnapshot.data == false) {
                            _isInitialLoad = false;
                            return const GravatarPreferenceSetupScreen();
                          }

                          // Both preferences are set, direct to home screen
                          _isInitialLoad = false;
                          return const HomeScreen();
                        },
                      );
                    },
                  );
                }

                // User is not signed in - reset state
                _cachedUserId = null;
                _aiPreferenceFuture = null;
                _gravatarPreferenceFuture = null;
                _isInitialLoad = true;
                _lastCheckedDeviceAccountUid = null;

                if (_shouldShowRecoverySelector &&
                    _recoveryAccountOptions.isNotEmpty) {
                  return _RecoveryAccountSelectorDialog(
                    accounts: _recoveryAccountOptions,
                    onAccountSwitched: _clearRecoverySelector,
                  );
                }

                // User is not signed in, direct to welcome screen
                return WelcomeScreen();
              },
            );
          },
        );
      },
    );
  }
}

class _RecoveryAccountSelectorDialog extends StatefulWidget {
  const _RecoveryAccountSelectorDialog({
    required this.accounts,
    required this.onAccountSwitched,
  });

  final List<Map<String, String>> accounts;
  final VoidCallback onAccountSwitched;

  @override
  State<_RecoveryAccountSelectorDialog> createState() =>
      _RecoveryAccountSelectorDialogState();
}

class _RecoveryAccountSelectorDialogState
    extends State<_RecoveryAccountSelectorDialog> {
  bool _isSwitching = false;
  String? _errorMessage;

  String _providerOf(Map<String, String> account) {
    final hasPassword =
        (account['hasPassword'] ?? 'false').toLowerCase() == 'true';
    if (hasPassword) {
      return 'password';
    }

    final provider =
        AndroidSystemAccountsService.normalizeProvider(account['provider']);
    if (provider == 'google') {
      return 'google';
    }

    return 'password';
  }

  Future<void> _switchToAccount(Map<String, String> account) async {
    if (_isSwitching) return;

    setState(() {
      _isSwitching = true;
      _errorMessage = null;
    });

    try {
      final email = account['name'] ?? '';
      final provider = _providerOf(account);

      if (provider == 'google') {
        final userCredential =
            await GoogleAuthService.signInWithGoogleCredentialManager();
        if (userCredential == null) {
          throw StateError('Google sign-in was cancelled');
        }
      } else {
        final password =
            await AndroidSystemAccountsService.getStoredPasswordForAccount(
          email,
        );

        if (password == null || password.isEmpty) {
          throw StateError('Saved password not found for this account');
        }

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        await AndroidSystemAccountsService.addCurrentUserToSystemAccounts(
          password: password,
          provider: 'password',
        );
      }

      widget.onAccountSwitched();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSwitching = false;
        });
      }
    }
  }

  Widget _providerPill(String provider, AppLocalizations l10n) {
    final isGoogle = provider == 'google';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isGoogle
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.blueGrey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isGoogle ? l10n.google : l10n.email,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isGoogle ? Colors.green[800] : Colors.blueGrey[800],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AlertDialog(
              title: Text(l10n.switchAccount),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.manageAccountsDescription),
                  const SizedBox(height: 14),
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      children: widget.accounts.map((account) {
                        final email = account['name'] ?? '';
                        final displayName = account['displayName'] ?? '';
                        final provider = _providerOf(account);

                        return ListTile(
                          enabled: !_isSwitching,
                          leading: UserAvatar.fromUserId(
                            userId: account['uid'] ?? '',
                            radius: 20,
                          ),
                          title: Text(
                            displayName.isNotEmpty ? displayName : email,
                          ),
                          subtitle: Text(email),
                          trailing: _providerPill(provider, l10n),
                          onTap: () => _switchToAccount(account),
                        );
                      }).toList(growable: false),
                    ),
                  ),
                  if (_isSwitching) ...[
                    const SizedBox(height: 8),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
