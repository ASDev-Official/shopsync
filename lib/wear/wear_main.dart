import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_options.dart';
import '../services/locale_service.dart';
import '../l10n/app_localizations.dart';
import 'screens/wear_list_groups_screen.dart';
import 'screens/wear_welcome_screen.dart';
import 'screens/wear_maintenance_screen.dart';
import 'screens/wear_outage_screen.dart';
import '../services/platform/maintenance_service.dart';
import '../services/platform/statuspage_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  try {
    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://0e9830280e9e2bd8123cab218ce80a00@o4509262568816640.ingest.us.sentry.io/4509262583431168';
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
      },
      appRunner: () => runApp(SentryWidget(child: ShopSyncWearApp())),
    );
  } catch (e) {
    debugPrint('Sentry initialization error: $e');
    // If Sentry fails, still run the app
    runApp(const ShopSyncWearApp());
  }

  // Start Statuspage polling on wear as well
  try {
    StatuspageService.startPolling();
  } catch (e, stackTrace) {
    debugPrint('Statuspage polling initialization error: $e');
    await Sentry.captureException(e,
        stackTrace: stackTrace,
        hint: Hint.withMap({'action': 'statuspage_start_polling'}));
  }
}

class ShopSyncWearApp extends StatefulWidget {
  const ShopSyncWearApp({super.key});

  @override
  State<ShopSyncWearApp> createState() => _ShopSyncWearAppState();

  /// Static method to change locale from anywhere in the app
  static void setLocale(BuildContext context, Locale newLocale) {
    _ShopSyncWearAppState? state =
        context.findAncestorStateOfType<_ShopSyncWearAppState>();
    state?.setLocale(newLocale);
  }
}

class _ShopSyncWearAppState extends State<ShopSyncWearApp> {
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

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    LocaleService.saveLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopSync',
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          brightness: Brightness.dark,
        ).copyWith(
          primary: Colors.green[800],
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          },
        ),
      ),
      home: const WearAuthWrapper(),
    );
  }
}

class WearAuthWrapper extends StatefulWidget {
  const WearAuthWrapper({super.key});

  @override
  State<WearAuthWrapper> createState() => _WearAuthWrapperState();
}

class _WearAuthWrapperState extends State<WearAuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkMaintenance();
      await _checkOutage();
    });
  }

  Future<void> _checkMaintenance() async {
    final maintenance = await MaintenanceService.checkMaintenance();

    if (maintenance != null && mounted) {
      if (maintenance['isUnderMaintenance']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WearMaintenanceScreen(
              message: maintenance['message'],
              startTime: maintenance['startTime'],
              endTime: maintenance['endTime'],
              isPredictive: false,
            ),
          ),
        );
      } else if (maintenance['isPredictive']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WearMaintenanceScreen(
            message: maintenance['message'],
            startTime: maintenance['startTime'],
            endTime: maintenance['endTime'],
            isPredictive: true,
          ),
        );
      }
    }
  }

  Future<void> _checkOutage() async {
    try {
      final outage = await StatuspageService.fetchCurrentOutage();
      if (outage.active && mounted) {
        if (!StatuspageService.dialogDismissedThisSession) {
          await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => WearOutageScreen(outage: outage),
          ).then((_) {
            // Ensure markDialogDismissed is called when dialog closes
            StatuspageService.markDialogDismissed();
          });
        }
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({
            'action': 'wear_check_outage',
            'context': 'showing_outage_dialog'
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          if (kDebugMode) {
            print('Auth stream error: ${snapshot.error}');
          }
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const WearListGroupsScreen();
        }

        return const WearWelcomeScreen();
      },
    );
  }
}
