import 'package:flutter/material.dart';
import 'package:shopsync/services/data/ai_preference_service.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import 'package:m3e_collection/m3e_collection.dart';

/// Mandatory screen shown to users to choose AI feature preference
/// Cannot be skipped - user must make a choice
class AIPreferenceSetupScreen extends StatefulWidget {
  const AIPreferenceSetupScreen({super.key});

  @override
  State<AIPreferenceSetupScreen> createState() =>
      _AIPreferenceSetupScreenState();
}

class _AIPreferenceSetupScreenState extends State<AIPreferenceSetupScreen>
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
      await AIPreferenceService.setAIPreference(_selectedPreference!);

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
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
                            Colors.purple[400]!,
                            Colors.purple[700]!,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      l10n.aiFeatures,
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
                      l10n.aiSetupDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Enable AI Card
                    _PreferenceCard(
                      title: l10n.enableAiFeatures,
                      description: l10n.enableAiDescription,
                      icon: Icons.psychology,
                      iconColor: Colors.green,
                      isSelected: _selectedPreference == true,
                      onTap: () => setState(() => _selectedPreference = true),
                      isDark: isDark,
                      features: [
                        l10n.smartItemSuggestions,
                        l10n.patternRecognition,
                        l10n.timeBasedRecommendations,
                        l10n.personalizedExperience,
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Disable AI Card
                    _PreferenceCard(
                      title: l10n.disableAiFeatures,
                      description: l10n.disableAiDescription,
                      icon: Icons.block,
                      iconColor: Colors.orange,
                      isSelected: _selectedPreference == false,
                      onTap: () => setState(() => _selectedPreference = false),
                      isDark: isDark,
                      features: [
                        l10n.noDataAnalysis,
                        l10n.noAiSuggestions,
                        l10n.basicListManagement,
                        l10n.privacyFocused,
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
                      l10n.aiPreferenceChangeNote,
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
                    color: iconColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      color: iconColor.withOpacity(0.1),
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
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 16,
                          color: iconColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
