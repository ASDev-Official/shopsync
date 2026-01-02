import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shopsync/screens/auth/sign_out.dart';
import 'package:shopsync/screens/settings/custom_licenses.dart';
import 'package:shopsync/services/platform/connectivity_service.dart';
import 'package:shopsync/services/locale_service.dart';
import 'package:shopsync/main.dart';
import 'package:shopsync/l10n/app_localizations.dart';
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
  Locale? _currentLocale;

  // Add GitHub and Weblate URLs
  final String _githubUrl = 'https://github.com/aadishsamir123/asdev-shopsync';
  final String _weblateUrl =
      'https://hosted.weblate.org/engage/asdev-shopsync/';

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
    final savedLocale = await LocaleService.getSavedLocale();
    setState(() {
      _currentLocale = savedLocale;
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

  Future<void> _changeLanguage(Locale locale) async {
    setState(() {
      _currentLocale = locale;
    });
    await LocaleService.saveLocale(locale);
    if (mounted) {
      ShopSyncApp.setLocale(context, locale);
    }
  }

  String _getCurrentLanguageName() {
    if (_currentLocale == null) {
      return 'System Default';
    }
    return LocaleService.getLocaleName(_currentLocale!);
  }

  Future<void> _launchUrl(String url) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotLaunchUrl(url))),
      );
    }
  }

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldSignOut = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.signOut),
            content: Text(l10n.areYouSureYouWantToSignOut),
            actions: [
              ButtonM3E(
                onPressed: () => Navigator.pop(context, false),
                label: Text(l10n.cancel),
                style: ButtonM3EStyle.text,
                size: ButtonM3ESize.md,
              ),
              ButtonM3E(
                onPressed: () => Navigator.pop(context, true),
                label: Text(l10n.signOut),
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSigningOutEtostring(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(
          l10n.settings,
          style: const TextStyle(
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
          SectionHeader(title: l10n.aboutApp, color: iconColor),
          buildSettingsTile(
            icon: Icons.info,
            title: l10n.appVersion,
            subtitle: _appVersion,
            iconColorOverride: iconColor,
          ),
          buildSettingsTile(
            icon: Icons.code,
            title: l10n.githubRepository,
            subtitle: l10n.viewSourceCode,
            // iconColorOverride: Colors.black,
            onTap: () => _launchUrl(_githubUrl),
          ),
          buildSettingsTile(
            icon: Icons.language,
            title: l10n.helpTranslate,
            subtitle: l10n.contributeOnWeblate,
            iconColorOverride: Colors.blue[700],
            onTap: () => _launchUrl(_weblateUrl),
          ),
          buildSettingsTile(
            icon: Icons.article,
            title: l10n.licenses,
            subtitle: l10n.openSourceLicenses,
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
          SectionHeader(title: l10n.settings, color: iconColor),
          buildSettingsTile(
            icon: Icons.logout,
            title: l10n.signOut,
            iconColorOverride: Colors.red,
            textColorOverride: Colors.red,
            isDestructive: true,
            onTap: _signOut,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: dividerColor, thickness: 1.2),
          ),
          SectionHeader(title: l10n.language, color: iconColor),
          buildSettingsTile(
            icon: Icons.language,
            title: l10n.appLanguage,
            subtitle: _getCurrentLanguageName(),
            onTap: () async {
              final selectedLocale = await showDialog<Locale?>(
                context: context,
                builder: (BuildContext dialogContext) {
                  return SimpleDialog(
                    backgroundColor: cardColor,
                    title: const Text('Select Language'),
                    children: <Widget>[
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, null);
                        },
                        child: Text('System Default',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale == null
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      const Divider(),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, const Locale('en'));
                        },
                        child: Text('English',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale?.languageCode == 'en'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, const Locale('de'));
                        },
                        child: Text('Deutsch',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale?.languageCode == 'de'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, const Locale('es'));
                        },
                        child: Text('Español',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale?.languageCode == 'es'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, const Locale('fr'));
                        },
                        child: Text('Français',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale?.languageCode == 'fr'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, const Locale('hi'));
                        },
                        child: Text('हिन्दी',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale?.languageCode == 'hi'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, const Locale('it'));
                        },
                        child: Text('Italiano',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale?.languageCode == 'it'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, const Locale('ja'));
                        },
                        child: Text('日本語',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale?.languageCode == 'ja'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, const Locale('ko'));
                        },
                        child: Text('한국어',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale?.languageCode == 'ko'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, const Locale('ru'));
                        },
                        child: Text('Русский',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale?.languageCode == 'ru'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(dialogContext, const Locale('zh'));
                        },
                        child: Text('简体中文',
                            style: TextStyle(
                                color: textColor,
                                fontWeight:
                                    _currentLocale?.languageCode == 'zh' &&
                                            _currentLocale?.scriptCode == null
                                        ? FontWeight.bold
                                        : FontWeight.normal)),
                      ),
                      SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(
                              dialogContext,
                              const Locale.fromSubtags(
                                  languageCode: 'zh', scriptCode: 'Hant'));
                        },
                        child: Text('繁體中文',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: _currentLocale?.scriptCode == 'Hant'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                    ],
                  );
                },
              );
              if (selectedLocale != null) {
                await _changeLanguage(selectedLocale);
              } else if (selectedLocale == null &&
                  await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Use System Default'),
                          content: const Text(
                              'Do you want to use your device\'s language setting?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      ) ==
                      true) {
                await LocaleService.clearLocale();
                setState(() {
                  _currentLocale = null;
                });
                if (mounted) {
                  // Reload the app to apply system default
                  ShopSyncApp.setLocale(
                      context,
                      View.of(context)
                          .platformDispatcher
                          .locale); // Use device locale
                }
              }
            },
          ),

          // Advertisement at the bottom
          const SizedBox(height: 16),
          if (_isBannerAdLoaded && _bannerAd != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: BannerAdvertWidget(
                    bannerAd: _bannerAd,
                    backgroundColor: isDark ? Colors.grey[800]! : Colors.white,
                  ),
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
