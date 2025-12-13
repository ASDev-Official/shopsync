import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import '/utils/icons/food_icons_map.dart';

class ChooseItemIconScreen extends StatefulWidget {
  final FoodIconMapping? selectedIcon;

  const ChooseItemIconScreen({
    super.key,
    this.selectedIcon,
  });

  @override
  State<ChooseItemIconScreen> createState() => _ChooseItemIconScreenState();
}

class _ChooseItemIconScreenState extends State<ChooseItemIconScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _searchAnimationController;
  late AnimationController _gridAnimationController;
  late AnimationController _categoryAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _searchAnimation;

  FoodIconMapping? _selectedIcon;
  String _selectedCategory = 'all';
  List<FoodIconMapping> _filteredIcons = [];
  bool _isLoading = false;
  bool _isSearchFocused = false;

  final List<String> _categories = [
    'all',
    'popular',
    'bakery',
    'berries',
    'desserts',
    'dishes',
    'drinks',
    'fastfood',
    'fruits',
    'vegetables',
    'ingredients',
    'meat',
    'nutrition',
    'nuts',
    'pastries',
    'seafood',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;

    // Initialize animation controllers
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _categoryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animations
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _searchAnimationController, curve: Curves.easeInOut),
    );

    // Setup focus node listener
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
      if (_searchFocusNode.hasFocus) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
      }
    });

    // Start initial animations
    _updateFilteredIcons();
    _gridAnimationController.forward();
    _categoryAnimationController.forward();

    // Delayed FAB animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchAnimationController.dispose();
    _gridAnimationController.dispose();
    _categoryAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _updateFilteredIcons() async {
    setState(() {
      _isLoading = true;
    });

    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 150));

    List<FoodIconMapping> icons;

    if (_selectedCategory == 'all') {
      icons = FoodIconMap.getAllIcons();
    } else {
      icons = FoodIconMap.getFoodIconsByCategory(_selectedCategory);
    }

    if (_searchController.text.isNotEmpty) {
      icons = icons
          .where((icon) =>
              icon.displayName
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              icon.identifier
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    if (mounted) {
      setState(() {
        _filteredIcons = icons;
        _isLoading = false;
      });

      // Restart grid animation
      _gridAnimationController.reset();
      _gridAnimationController.forward();
    }
  }

  void _onSearchChanged(String query) {
    _updateFilteredIcons();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });

    // Add haptic feedback
    HapticFeedback.selectionClick();

    // Reset and restart category animation for subtle bounce effect
    _categoryAnimationController.forward(from: 0.8);

    _updateFilteredIcons();
  }

  void _onIconSelected(FoodIconMapping icon) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIcon = icon;
    });

    // Animate FAB if not already visible
    if (!_fabAnimationController.isCompleted) {
      _fabAnimationController.forward();
    }
  }

  void _onConfirm() {
    Navigator.of(context).pop(_selectedIcon);
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Choose Icon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _onCancel,
        ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: _selectedIcon != null
                ? Container(
                    key: const ValueKey('done_button'),
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: _onConfirm,
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(
                    key: ValueKey('empty'),
                    width: 80,
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          AnimatedBuilder(
            animation: _searchAnimation,
            builder: (context, child) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Transform.scale(
                  scale:
                      (0.95 + (0.05 * _searchAnimation.value)).clamp(0.95, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green[800]!.withValues(
                            alpha: 0.2 * _searchAnimation.value,
                          ),
                          blurRadius: 12 * _searchAnimation.value,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search icons...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        prefixIcon: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: _isSearchFocused ? 1000 : 0,
                            ),
                            tween: Tween(
                              begin: 0.0,
                              end: _isSearchFocused ? 1.0 : 0.0,
                            ),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 1.0 + (0.1 * value),
                                child: Icon(
                                  Icons.search,
                                  color: _isSearchFocused
                                      ? Colors.green[800]
                                      : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                                ),
                              );
                            },
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? AnimatedScale(
                                scale: 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey[700]! : Colors.green[200]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                isDark ? Colors.grey[700]! : Colors.green[200]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green[800]!,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Category Chips
          AnimatedBuilder(
            animation: _categoryAnimationController,
            builder: (context, child) {
              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;

                    // Staggered animation
                    final animationDelay = index * 0.1;
                    final animation =
                        Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _categoryAnimationController,
                        curve: Interval(
                          animationDelay.clamp(0.0, 1.0),
                          (animationDelay + 0.5).clamp(0.0, 1.0),
                          curve: Curves.elasticOut,
                        ),
                      ),
                    );

                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: animation.value.clamp(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: FilterChip(
                                label: Text(
                                  category == 'all'
                                      ? 'All'
                                      : category.substring(0, 1).toUpperCase() +
                                          category.substring(1),
                                  style: TextStyle(
                                    color: isSelected
                                        ? (isDark
                                            ? Colors.white
                                            : Colors.green[800])
                                        : (isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[700]),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    HapticFeedback.selectionClick();
                                    _onCategoryChanged(category);
                                  }
                                },
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                                selectedColor: isDark
                                    ? Colors.green[800]
                                    : Colors.green[100],
                                checkmarkColor:
                                    isDark ? Colors.white : Colors.green[800],
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.green[800]!
                                      : (isDark
                                          ? Colors.grey[600]!
                                          : Colors.grey[300]!),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Selected Icon Preview
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _selectedIcon != null
                ? TweenAnimationBuilder<double>(
                    key: ValueKey(_selectedIcon!.identifier),
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Transform.scale(
                          scale: (0.8 + (0.2 * value)).clamp(0.1, 1.0),
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Hero(
                                tag:
                                    'selected_icon_${_selectedIcon!.identifier}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.green[800]
                                          : Colors.green[100],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.green[800]!,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green[800]!
                                              .withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.green[700]
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: _selectedIcon!.buildIcon(
                                              width: 28,
                                              height: 28,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.green[800],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Selected Icon',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white.withValues(
                                                          alpha: 0.8)
                                                      : Colors.green[800]!
                                                          .withValues(
                                                              alpha: 0.8),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _selectedIcon!.displayName,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.green[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(
                                              milliseconds: 1200),
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          builder:
                                              (context, rotateValue, child) {
                                            return Transform.rotate(
                                              angle: rotateValue * 0.5,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.green[800],
                                                size: 28,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),

          if (_selectedIcon != null) const SizedBox(height: 16),

          // Icons Grid
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CustomLoadingSpinner(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading icons...',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredIcons.isEmpty
                    ? Center(
                        child: AnimatedBuilder(
                          animation: _gridAnimationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _gridAnimationController.value
                                  .clamp(0.0, 1.0),
                              child: Opacity(
                                opacity: _gridAnimationController.value
                                    .clamp(0.0, 1.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.rotate(
                                          angle: value * 0.1,
                                          child: Icon(
                                            Icons.search_off,
                                            size: 64,
                                            color: isDark
                                                ? Colors.grey[600]
                                                : Colors.grey[400],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No icons found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your search or category filter',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.grey[500]
                                            : Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: _filteredIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _filteredIcons[index];
                          final isSelected =
                              _selectedIcon?.identifier == icon.identifier;

                          // Staggered animation for grid items
                          final animationDelay = (index * 0.05).clamp(0.0, 1.0);

                          return AnimatedBuilder(
                            animation: _gridAnimationController,
                            builder: (context, child) {
                              final animation = Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: _gridAnimationController,
                                  curve: Interval(
                                    animationDelay,
                                    (animationDelay + 0.3).clamp(0.0, 1.0),
                                    curve: Curves.elasticOut,
                                  ),
                                ),
                              );

                              return Transform.scale(
                                scale: animation.value.clamp(0.0, 1.0),
                                child: Transform.translate(
                                  offset: Offset(0, 50 * (1 - animation.value)),
                                  child: Opacity(
                                    opacity: animation.value.clamp(0.0, 1.0),
                                    child: Hero(
                                      tag: 'icon_${icon.identifier}',
                                      child: Material(
                                        color: Colors.transparent,
                                        child: GestureDetector(
                                          onTap: () => _onIconSelected(icon),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            curve: Curves.easeInOut,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? (isDark
                                                      ? Colors.green[800]
                                                      : Colors.green[100])
                                                  : (isDark
                                                      ? Colors.grey[800]
                                                      : Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.green[800]!
                                                    : (isDark
                                                        ? Colors.grey[600]!
                                                        : Colors.grey[300]!),
                                                width: isSelected ? 2 : 1,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors
                                                            .green[800]!
                                                            .withValues(
                                                                alpha: 0.3),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: isDark
                                                                    ? 0.3
                                                                    : 0.1),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                AnimatedScale(
                                                  scale: isSelected ? 1.1 : 1.0,
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  child: icon.buildIcon(
                                                    width: 28,
                                                    height: 28,
                                                    color: isSelected
                                                        ? (isDark
                                                            ? Colors.white
                                                            : Colors.green[800])
                                                        : (isDark
                                                            ? Colors.grey[300]
                                                            : Colors.grey[700]),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                AnimatedDefaultTextStyle(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: isSelected
                                                        ? (isDark
                                                            ? Colors.white
                                                            : Colors.green[800])
                                                        : (isDark
                                                            ? Colors.grey[400]
                                                            : Colors.grey[600]),
                                                  ),
                                                  child: Text(
                                                    icon.displayName,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
