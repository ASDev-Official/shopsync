import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';

class WearCustomLicensesPage extends StatefulWidget {
  final String applicationName;
  final String applicationVersion;

  const WearCustomLicensesPage({
    super.key,
    required this.applicationName,
    required this.applicationVersion,
  });

  @override
  State<WearCustomLicensesPage> createState() => _WearCustomLicensesPageState();
}

class _WearCustomLicensesPageState extends State<WearCustomLicensesPage> {
  late Future<Map<String, List<_LicenseEntry>>> _licensesFuture;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _licensesFuture = _loadLicenses();
    _searchController.text = _searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return Scaffold(
              backgroundColor:
                  mode == WearMode.active ? Colors.black : Colors.black,
              body: FutureBuilder<Map<String, List<_LicenseEntry>>>(
                future: _licensesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                mode == WearMode.active
                                    ? Colors.green[300]!
                                    : Colors.grey[600]!,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Loading',
                            style: TextStyle(
                              fontSize: 12,
                              color: mode == WearMode.active
                                  ? Colors.white70
                                  : Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.all(
                        shape == WearShape.round ? 32.0 : 16.0,
                      ),
                      child: Center(
                        child: Text(
                          'Error loading licenses',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[300],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final licensesMap = snapshot.data ?? {};
                  var packageNames = licensesMap.keys.toList()..sort();

                  // Filter packages based on search query
                  if (_searchQuery.isNotEmpty) {
                    packageNames = packageNames
                        .where((name) => name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();
                  }

                  return _buildLicensesList(
                    packageNames,
                    licensesMap,
                    mode,
                    shape,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLicensesList(
    List<String> packageNames,
    Map<String, List<_LicenseEntry>> licensesMap,
    WearMode mode,
    WearShape shape,
  ) {
    return RotaryScrollbar(
      controller: _scrollController,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header with back button
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: shape == WearShape.round ? 32.0 : 16.0,
                right: shape == WearShape.round ? 32.0 : 16.0,
                top: shape == WearShape.round ? 24.0 : 16.0,
                bottom: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: mode == WearMode.active
                          ? Colors.white
                          : Colors.white60,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Licenses',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: mode == WearMode.active
                              ? Colors.white
                              : Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
          ),

          // App info card
          SliverPadding(
            padding: EdgeInsets.only(
              left: shape == WearShape.round ? 32.0 : 12.0,
              right: shape == WearShape.round ? 32.0 : 12.0,
              bottom: 16.0,
            ),
            sliver: SliverToBoxAdapter(
              child: Card(
                color: mode == WearMode.active
                    ? Colors.grey[900]
                    : Colors.grey[850],
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.article,
                        size: 16,
                        color: mode == WearMode.active
                            ? Colors.white54
                            : Colors.white38,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.applicationName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: mode == WearMode.active
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'v${widget.applicationVersion}',
                              style: TextStyle(
                                fontSize: 10,
                                color: mode == WearMode.active
                                    ? Colors.white54
                                    : Colors.white38,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Packages section header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: shape == WearShape.round ? 36.0 : 16.0,
                right: shape == WearShape.round ? 36.0 : 16.0,
                bottom: 8.0,
              ),
              child: Text(
                'Packages',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      mode == WearMode.active ? Colors.white54 : Colors.white38,
                ),
              ),
            ),
          ),

          // Search input
          SliverPadding(
            padding: EdgeInsets.only(
              left: shape == WearShape.round ? 32.0 : 12.0,
              right: shape == WearShape.round ? 32.0 : 12.0,
              bottom: 12.0,
            ),
            sliver: SliverToBoxAdapter(
              child: Card(
                color: mode == WearMode.active
                    ? Colors.grey[900]
                    : Colors.grey[850],
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search packages',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: mode == WearMode.active
                            ? Colors.white38
                            : Colors.white24,
                      ),
                      border: InputBorder.none,
                      isDense: false,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 16,
                        color: mode == WearMode.active
                            ? Colors.white54
                            : Colors.white38,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 16,
                                color: mode == WearMode.active
                                    ? Colors.white54
                                    : Colors.white38,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                              splashRadius: 18,
                            )
                          : null,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: mode == WearMode.active
                          ? Colors.white
                          : Colors.white70,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),
            ),
          ),

          // Packages list
          if (packageNames.isEmpty)
            SliverPadding(
              padding: EdgeInsets.all(
                shape == WearShape.round ? 32.0 : 16.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No packages' : 'No match',
                    style: TextStyle(
                      fontSize: 12,
                      color: mode == WearMode.active
                          ? Colors.white54
                          : Colors.white38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.only(
                left: shape == WearShape.round ? 32.0 : 12.0,
                right: shape == WearShape.round ? 32.0 : 12.0,
                bottom: 16.0,
              ),
              sliver: SliverList.builder(
                itemCount: packageNames.length,
                itemBuilder: (context, index) {
                  final packageName = packageNames[index];
                  final licenses = licensesMap[packageName] ?? [];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WearPackageLicensesPage(
                                  packageName: packageName,
                                  licenses: licenses,
                                  mode: mode,
                                  shape: shape,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    packageName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: mode == WearMode.active
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: mode == WearMode.active
                                      ? Colors.white38
                                      : Colors.white24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Page showing all licenses for a single package
class WearPackageLicensesPage extends StatefulWidget {
  final String packageName;
  final List<_LicenseEntry> licenses;
  final WearMode mode;
  final WearShape shape;

  const WearPackageLicensesPage({
    super.key,
    required this.packageName,
    required this.licenses,
    required this.mode,
    required this.shape,
  });

  @override
  State<WearPackageLicensesPage> createState() =>
      _WearPackageLicensesPageState();
}

class _WearPackageLicensesPageState extends State<WearPackageLicensesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AmbientMode(
      builder: (context, mode, child) {
        return Scaffold(
          backgroundColor:
              mode == WearMode.active ? Colors.black : Colors.black,
          body: RotaryScrollbar(
            controller: _scrollController,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Header with back button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: widget.shape == WearShape.round ? 32.0 : 16.0,
                      right: widget.shape == WearShape.round ? 32.0 : 16.0,
                      top: widget.shape == WearShape.round ? 24.0 : 16.0,
                      bottom: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: mode == WearMode.active
                                ? Colors.white
                                : Colors.white60,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.packageName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: mode == WearMode.active
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),

                // License content section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: widget.shape == WearShape.round ? 36.0 : 16.0,
                      right: widget.shape == WearShape.round ? 36.0 : 16.0,
                      bottom: 8.0,
                      top: 16.0,
                    ),
                    child: Text(
                      'License',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: mode == WearMode.active
                            ? Colors.white54
                            : Colors.white38,
                      ),
                    ),
                  ),
                ),

                // License content cards
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: widget.shape == WearShape.round ? 32.0 : 12.0,
                    right: widget.shape == WearShape.round ? 32.0 : 12.0,
                    bottom: 16.0,
                  ),
                  sliver: SliverList.builder(
                    itemCount: widget.licenses.length,
                    itemBuilder: (context, index) {
                      final license = widget.licenses[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          color: mode == WearMode.active
                              ? Colors.grey[900]
                              : Colors.grey[850],
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SingleChildScrollView(
                              child: Text(
                                license.licenseText,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                  color: mode == WearMode.active
                                      ? Colors.white70
                                      : Colors.white54,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
