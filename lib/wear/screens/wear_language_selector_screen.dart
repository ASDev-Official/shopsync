import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import '../../services/locale_service.dart';

class WearLanguageSelectorScreen extends StatefulWidget {
  final Locale? currentLocale;

  const WearLanguageSelectorScreen({
    super.key,
    this.currentLocale,
  });

  @override
  State<WearLanguageSelectorScreen> createState() =>
      _WearLanguageSelectorScreenState();
}

class _WearLanguageSelectorScreenState
    extends State<WearLanguageSelectorScreen> {
  late Locale? _selectedLocale;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _languages = [
    {'name': 'System', 'locale': null},
    {'name': 'English', 'locale': const Locale('en')},
    {'name': 'Deutsch', 'locale': const Locale('de')},
    {'name': 'Español', 'locale': const Locale('es')},
    {'name': 'Français', 'locale': const Locale('fr')},
    {'name': 'हिन्दी', 'locale': const Locale('hi')},
    {'name': 'Italiano', 'locale': const Locale('it')},
    {'name': '日本語', 'locale': const Locale('ja')},
    {'name': '한국어', 'locale': const Locale('ko')},
    {'name': 'Русский', 'locale': const Locale('ru')},
    {'name': '简体中文', 'locale': const Locale('zh')},
    {
      'name': '繁體中文',
      'locale': const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.currentLocale;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _applyLanguage() async {
    if (_selectedLocale == null) {
      await LocaleService.clearLocale();
    } else {
      await LocaleService.saveLocale(_selectedLocale!);
    }
    if (mounted) {
      Navigator.pop(context, _selectedLocale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return Scaffold(
              backgroundColor:
                  mode == WearMode.active ? Colors.black : Colors.black,
              body: _buildLanguageSelector(mode, shape),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageSelector(WearMode mode, WearShape shape) {
    return Expanded(
      child: RotaryScrollbar(
        controller: _scrollController,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            left: shape == WearShape.round ? 32.0 : 12.0,
            right: shape == WearShape.round ? 32.0 : 12.0,
            top: shape == WearShape.round ? 24.0 : 16.0,
            bottom: shape == WearShape.round ? 80.0 : 60.0,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 12.0,
              ),
              child: Center(
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color:
                        mode == WearMode.active ? Colors.white : Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ..._languages.map((lang) {
              final isSelected = lang['locale'] == _selectedLocale ||
                  (lang['locale'] == null && _selectedLocale == null);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  color: mode == WearMode.active
                      ? Colors.grey[900]
                      : Colors.grey[850],
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minHeight: 48, minWidth: 48),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          _selectedLocale = lang['locale'] as Locale?;
                        });

                        final confirmed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WearLanguageConfirmScreen(
                              languageName: lang['name'] as String,
                              isSystemLanguage: lang['locale'] == null,
                            ),
                          ),
                        );

                        if (!mounted || confirmed != true) return;
                        await _applyLanguage();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Colors.green[400],
                              )
                            else
                              Icon(
                                Icons.radio_button_unchecked,
                                size: 18,
                                color: mode == WearMode.active
                                    ? Colors.white38
                                    : Colors.white24,
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                lang['name'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.green[400]
                                      : (mode == WearMode.active
                                          ? Colors.white
                                          : Colors.white70),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class WearLanguageConfirmScreen extends StatefulWidget {
  final String languageName;
  final bool isSystemLanguage;

  const WearLanguageConfirmScreen({
    super.key,
    required this.languageName,
    required this.isSystemLanguage,
  });

  @override
  State<WearLanguageConfirmScreen> createState() =>
      _WearLanguageConfirmScreenState();
}

class _WearLanguageConfirmScreenState extends State<WearLanguageConfirmScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            final isActive = mode == WearMode.active;
            return Scaffold(
              backgroundColor: isActive ? Colors.black : Colors.black,
              body: Padding(
                padding: EdgeInsets.only(
                  left: shape == WearShape.round ? 28.0 : 16.0,
                  right: shape == WearShape.round ? 28.0 : 16.0,
                  top: shape == WearShape.round ? 26.0 : 18.0,
                  bottom: 18.0,
                ),
                child: RotaryScrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            'Confirm Language',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            widget.isSystemLanguage
                                ? 'System'
                                : widget.languageName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Card(
                          color: Colors.green[700],
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minHeight: 46, minWidth: 46),
                            child: InkWell(
                              onTap: () => Navigator.pop(context, true),
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Center(
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          color: isActive ? Colors.grey[800] : Colors.grey[850],
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minHeight: 46, minWidth: 46),
                            child: InkWell(
                              onTap: () => Navigator.pop(context, false),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
