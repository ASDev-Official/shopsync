import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsync/screens/auth/sign_out.dart';
import 'package:shopsync/screens/settings/widget_settings.dart';
import 'package:shopsync/screens/settings/custom_licenses.dart';
import 'package:shopsync/services/platform/connectivity_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '/widgets/common/advert.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  // bool _isDarkMode = false;
  // bool _notificationsEnabled = false;
  String _selectedLanguage = 'English';
  final _prefs = SharedPreferences.getInstance();

  // Add GitHub and Crowdin URLs
  final String _githubUrl = 'https://github.com/aadishsamir123/asdev-shopsync';
  final String _crowdinUrl = 'https://crowdin.com/project/as-shopsync';

  // Offline mode
  final connectivityService = ConnectivityService();

  // Ad management
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Don't load ads on web platform
    if (kIsWeb) {
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6149170768233698/6011136275',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _bannerAd = null;
            _isBannerAdLoaded = false;
          });
        },
      ),
    );
    _bannerAd?.load();
  }

  Future<void> _loadSettings() async {
    final prefs = await _prefs;
    setState(() {
      // _isDarkMode = prefs.getBool('darkMode') ?? false;
      // _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (kIsWeb) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
      if (!kIsWeb) {
        setState(() {
          _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
        });
      }
    } catch (e) {
      setState(() {
        _appVersion = 'Error loading version';
      });
    }
  }

  // Future<void> _toggleDarkMode(bool value) async {
  //   final prefs = await _prefs;
  //   await prefs.setBool('darkMode', value);
  //   setState(() {
  //     _isDarkMode = value;
  //   });
  // }

  // Future<void> _toggleNotifications(bool value) async {
  //   final prefs = await _prefs;
  //   await prefs.setBool('notificationsEnabled', value);
  //   setState(() {
  //     _notificationsEnabled = value;
  //   });
  // }

  Future<void> _changeLanguage(String language) async {
    final prefs = await _prefs;
    await prefs.setString('language', language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              ButtonM3E(
                onPressed: () => Navigator.pop(context, false),
                label: const Text('Cancel'),
                style: ButtonM3EStyle.text,
                size: ButtonM3ESize.md,
              ),
              ButtonM3E(
                onPressed: () => Navigator.pop(context, true),
                label: const Text('Sign Out'),
                style: ButtonM3EStyle.text,
                size: ButtonM3ESize.md,
              ),
            ],
          ),
        ) ??
        false;

    if (shouldSignOut) {
      try {
        if (await connectivityService.checkConnectivityAndShowDialog(context,
            feature: 'the sign out option')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignOutScreen()),
          );
        }
      } catch (e) {
        // Send sign out errors to Sentry
        await Sentry.captureException(
          e,
          stackTrace: StackTrace.current,
          hint: Hint.withMap({'action': 'signing_out'}),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _bannerAd?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF23262B) : Colors.white;
    final iconColor = isDark ? Colors.green[200]! : Colors.green[700]!;
    final textColor = isDark ? Colors.white : Colors.grey[900]!;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final dividerColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    Widget buildSettingsTile({
      required IconData icon,
      required String title,
      String? subtitle,
      Color? iconColorOverride,
      Color? textColorOverride,
      VoidCallback? onTap,
      bool isDestructive = false,
    }) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(30)
                  : Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColorOverride ?? iconColor).withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColorOverride ?? iconColor,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color:
                  isDestructive ? Colors.red : (textColorOverride ?? textColor),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 13,
                  ),
                )
              : null,
          trailing: onTap != null
              ? Icon(Icons.chevron_right,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])
              : null,
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // About App Section
          SectionHeader(title: 'About App', color: iconColor),
          buildSettingsTile(
            icon: Icons.info,
            title: 'App Version',
            subtitle: _appVersion,
            iconColorOverride: iconColor,
          ),
          buildSettingsTile(
            icon: Icons.code,
            title: 'GitHub Repository',
            subtitle: 'View source code',
            // iconColorOverride: Colors.black,
            onTap: () => _launchUrl(_githubUrl),
          ),
          buildSettingsTile(
            icon: Icons.language,
            title: 'Help Translate',
            subtitle: 'Contribute on Crowdin',
            iconColorOverride: Colors.blue[700],
            onTap: () => _launchUrl(_crowdinUrl),
          ),
          buildSettingsTile(
            icon: Icons.article,
            title: 'Licenses',
            subtitle: 'Open source licenses',
            iconColorOverride: Colors.purple[700],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomLicensesPage(
                    applicationName: 'ShopSync',
                    applicationVersion: _appVersion,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: dividerColor, thickness: 1.2),
          ),
          // Settings Section
          SectionHeader(title: 'Settings', color: iconColor),
          // Only show Widget Settings in debug mode
          if (kDebugMode)
            buildSettingsTile(
              icon: Icons.smartphone,
              title: 'Widget Settings',
              subtitle: 'Configure home screen widget (Debug Only)',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WidgetSettingsScreen(),
                  ),
                );
              },
            ),
          buildSettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            iconColorOverride: Colors.red,
            textColorOverride: Colors.red,
            isDestructive: true,
            onTap: _signOut,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: dividerColor, thickness: 1.2),
          ),
          SectionHeader(title: 'Language', color: iconColor),
          buildSettingsTile(
            icon: Icons.language,
            title: 'App Language',
            subtitle: _selectedLanguage,
            onTap: () async {
              final selectedLanguage = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    backgroundColor: cardColor,
                    title: Text('Select Language',
                        style: TextStyle(color: textColor)),
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, 'English');
                        },
                        child:
                            Text('English', style: TextStyle(color: textColor)),
                      ),
                      // Add more languages here
                    ],
                  );
                },
              );
              if (selectedLanguage != null) {
                _changeLanguage(selectedLanguage);
              }
            },
          ),

          // Advertisement at the bottom
          const SizedBox(height: 16),
          if (_isBannerAdLoaded && _bannerAd != null)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18.0),
                child: BannerAdvertWidget(
                  bannerAd: _bannerAd,
                  backgroundColor: isDark ? Colors.grey[800]! : Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const SectionHeader({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
