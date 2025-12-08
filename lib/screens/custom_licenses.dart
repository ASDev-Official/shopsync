import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shopsync/widgets/loading_spinner.dart';

class CustomLicensesPage extends StatefulWidget {
  final String applicationName;
  final String applicationVersion;

  const CustomLicensesPage({
    super.key,
    required this.applicationName,
    required this.applicationVersion,
  });

  @override
  State<CustomLicensesPage> createState() => _CustomLicensesPageState();
}

class _CustomLicensesPageState extends State<CustomLicensesPage> {
  late Future<Map<String, List<_LicenseEntry>>> _licensesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _licensesFuture = _loadLicenses();
  }

  Future<Map<String, List<_LicenseEntry>>> _loadLicenses() async {
    final licensesMap = <String, List<_LicenseEntry>>{};

    // Get all licenses from LicenseRegistry
    await for (final entry in LicenseRegistry.licenses) {
      final licenseText =
          entry.paragraphs.map((paragraph) => paragraph.text).join('\n\n');

      for (final package in entry.packages) {
        if (!licensesMap.containsKey(package)) {
          licensesMap[package] = [];
        }
        licensesMap[package]!.add(
          _LicenseEntry(
            package: package,
            licenseText: licenseText,
          ),
        );
      }
    }

    return licensesMap;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF23262B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.grey[900]!;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        title: Text(
          'Licenses',
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
      body: FutureBuilder<Map<String, List<_LicenseEntry>>>(
        future: _licensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CustomLoadingSpinner(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading licenses: ${snapshot.error}',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final licensesMap = snapshot.data ?? {};
          var packageNames = licensesMap.keys.toList()..sort();

          // Filter packages based on search query
          if (_searchQuery.isNotEmpty) {
            packageNames = packageNames
                .where((name) =>
                    name.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search packages...',
                    hintStyle: TextStyle(color: subtitleColor),
                    prefixIcon: Icon(Icons.search, color: subtitleColor),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: subtitleColor),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),
              ),
              // Licenses list
              Expanded(
                child: packageNames.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No packages found'
                              : 'No packages match your search',
                          style: TextStyle(color: subtitleColor),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: packageNames.length,
                        itemBuilder: (context, index) {
                          final packageName = packageNames[index];
                          final licenses = licensesMap[packageName] ?? [];
                          if (index == 0) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.applicationName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Version ${widget.applicationVersion}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subtitleColor,
                                    ),
                                  ),
                                  Text(
                                    'Powered by Flutter',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subtitleColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return PackageTile(
                            packageName: packageName,
                            licenses: licenses,
                            isDark: isDark,
                            cardColor: cardColor,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LicenseEntry {
  final String package;
  final String licenseText;

  _LicenseEntry({
    required this.package,
    required this.licenseText,
  });
}

class PackageTile extends StatelessWidget {
  final String packageName;
  final List<_LicenseEntry> licenses;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;

  const PackageTile({
    super.key,
    required this.packageName,
    required this.licenses,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageLicensesPage(
              packageName: packageName,
              licenses: licenses,
              isDark: isDark,
              cardColor: cardColor,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    packageName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${licenses.length} license${licenses.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}

class PackageLicensesPage extends StatelessWidget {
  final String packageName;
  final List<_LicenseEntry> licenses;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;

  const PackageLicensesPage({
    super.key,
    required this.packageName,
    required this.licenses,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        title: Text(
          packageName,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            licenses.length,
            (index) {
              final license = licenses[index];
              final licenseNumber = licenses.length > 1 ? '${index + 1}' : '';
              final titleText =
                  licenses.length > 1 ? 'License $licenseNumber' : 'License';

              return Column(
                children: [
                  if (index > 0)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      height: 1,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleText,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          license.licenseText,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor,
                            height: 1.6,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
