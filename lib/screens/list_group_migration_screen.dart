import 'package:flutter/material.dart';
import 'package:shopsync/services/list_groups_service.dart';
import 'package:shopsync/widgets/loading_spinner.dart';

class ListGroupMigrationScreen extends StatefulWidget {
  const ListGroupMigrationScreen({super.key});

  @override
  State<ListGroupMigrationScreen> createState() =>
      _ListGroupMigrationScreenState();
}

class _ListGroupMigrationScreenState extends State<ListGroupMigrationScreen> {
  bool _isUpgrading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _performMigration();
  }

  Future<void> _performMigration() async {
    try {
      // Add a small delay for better UX (so users can see the message)
      await Future.delayed(const Duration(milliseconds: 500));

      final success = await ListGroupsService.migrateGroupIdToListIds();

      if (!mounted) return;

      if (success) {
        // Migration successful, navigate back to home
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isUpgrading = false;
          _hasError = true;
          _errorMessage = 'Failed to upgrade lists. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUpgrading = false;
        _hasError = true;
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
    }
  }

  Future<void> _retry() async {
    setState(() {
      _isUpgrading = true;
      _hasError = false;
      _errorMessage = null;
    });
    await _performMigration();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_isUpgrading,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green[400]!,
                          Colors.green[600]!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.upgrade,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    _hasError ? 'Upgrade Failed' : 'Upgrading your lists',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  if (!_hasError)
                    Text(
                      'Please wait while we update your list groups to the new format...',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),

                  if (_hasError && _errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red[700],
                      ),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 40),

                  // Loading indicator or retry button
                  if (_isUpgrading)
                    const CustomLoadingSpinner()
                  else if (_hasError)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Skip for now',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
