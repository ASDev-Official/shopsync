import 'package:flutter/material.dart';
import 'package:shopsync/services/data/gravatar_service.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mandatory screen shown to users to choose Gravatar preference
/// Cannot be skipped - user must make a choice
class GravatarPreferenceSetupScreen extends StatefulWidget {
  const GravatarPreferenceSetupScreen({super.key});

  @override
  State<GravatarPreferenceSetupScreen> createState() =>
      _GravatarPreferenceSetupScreenState();
}

class _GravatarPreferenceSetupScreenState
    extends State<GravatarPreferenceSetupScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool? _selectedPreference;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _savePreference() async {
    if (_selectedPreference == null) return;

    setState(() => _isLoading = true);

    try {
      await GravatarService.setGravatarPreference(_selectedPreference!);

      if (!mounted) return;

      // Navigate to home after setting preference
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorSavingPreference),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  void _showGravatarInfo() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Text(l10n.whatIsGravatar),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.gravatarExplanation,
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('https://www.gravatar.com');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.visitGravatar),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.outageClose),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[400]!,
                            Colors.blue[700]!,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      l10n.gravatarProfilePictures,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      l10n.gravatarSetupDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // What is Gravatar link
                    Center(
                      child: TextButton.icon(
                        onPressed: _showGravatarInfo,
                        icon: const Icon(Icons.help_outline, size: 18),
                        label: Text(l10n.whatIsGravatar),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Enable Gravatar Card
                    _PreferenceCard(
                      title: l10n.enableGravatarSetup,
                      description: l10n.enableGravatarSetupDescription,
                      icon: Icons.image,
                      iconColor: Colors.green,
                      isSelected: _selectedPreference == true,
                      onTap: () => setState(() => _selectedPreference = true),
                      isDark: isDark,
                      features: [
                        l10n.gravatarFeature1,
                        l10n.gravatarFeature2,
                        l10n.gravatarFeature3,
                        l10n.gravatarFeature4,
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Disable Gravatar Card
                    _PreferenceCard(
                      title: l10n.disableGravatarSetup,
                      description: l10n.disableGravatarSetupDescription,
                      icon: Icons.block,
                      iconColor: Colors.orange,
                      isSelected: _selectedPreference == false,
                      onTap: () => setState(() => _selectedPreference = false),
                      isDark: isDark,
                      features: [
                        l10n.gravatarDisabledFeature1,
                        l10n.gravatarDisabledFeature2,
                        l10n.gravatarDisabledFeature3,
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Continue Button
                    SizedBox(
                      height: 56,
                      child: ButtonM3E(
                        onPressed: _selectedPreference == null || _isLoading
                            ? null
                            : _savePreference,
                        enabled: _selectedPreference != null && !_isLoading,
                        label: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CustomLoadingSpinner(
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              )
                            : Text(
                                l10n.continueButton,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        size: ButtonM3ESize.lg,
                        style: ButtonM3EStyle.filled,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info text
                    Text(
                      l10n.gravatarPreferenceChangeNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final List<String> features;

  const _PreferenceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? iconColor
                : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: iconColor,
                      size: 28,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        size: 18,
                        color: iconColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
