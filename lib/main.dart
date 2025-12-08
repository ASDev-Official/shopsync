import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shopsync/services/connectivity_service.dart';
import 'firebase_options.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/forgot_password.dart';
import 'screens/maintenance_screen.dart';
import 'screens/onboarding.dart';
import 'screens/settings.dart';
import 'screens/migration_screen.dart';
import 'screens/feedback.dart';
import 'screens/manage_categories.dart';
import 'services/update_service.dart';
import 'services/maintenance_service.dart';
import 'services/shared_prefs.dart';
import 'services/home_widget_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'widgets/splash_screen.dart';

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

  // Register ShopSync application license
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('LICENSE');
    yield LicenseEntryWithLineBreaks(['ShopSync'], license);
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
    appRunner: () => runApp(SentryWidget(child: ShopSync())),
  );
}

class ShopSync extends StatelessWidget {
  const ShopSync({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopSync',
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
  @override
  void initState() {
    super.initState();
    // Check for updates after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await SharedPrefs.isFirstLaunch() && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
        return;
      }
      UpdateService.checkForUpdate(context);
      await _checkMaintenance();
    });
  }

  Future<void> _checkMaintenance() async {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If Firebase is still initializing, show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: SplashScreen(),
            ),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in, direct to home screen
          return const HomeScreen();
        }

        // User is not signed in, direct to welcome screen
        return WelcomeScreen();
      },
    );
  }
}
