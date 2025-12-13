import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '/widgets/ui/loading_spinner.dart';
import '/widgets/lists/place_selector.dart';
import '/widgets/lists/category_picker.dart';
import '/widgets/lists/smart_suggestions_widget.dart';
import '/utils/icons/food_icons_map.dart';
import '/screens/lists/choose_item_icon.dart';
import '/services/data/smart_suggestions_service.dart';
import '/models/item_suggestion.dart';
import '/utils/food_icon_detector.dart';

class CreateItemScreen extends StatefulWidget {
  final String listId;

  const CreateItemScreen({super.key, required this.listId});

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDeadline;
  TimeOfDay? _selectedTime;
  Map<String, dynamic>? _location;
  bool _isLoading = false;
  int _counter = 1;
  FoodIconMapping? _selectedIcon;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _iconManuallySelected = false;
  Timer? _debounceTimer;

  // Smart suggestions
  final _suggestionsService = SmartSuggestionsService();
  List<ItemSuggestion> _suggestions = [];
  bool _isLoadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    if (!mounted) return;
    setState(() => _isLoadingSuggestions = true);

    try {
      // Add timeout to prevent blocking UI indefinitely
      final suggestions = await _suggestionsService
          .getSuggestions(
        listId: widget.listId,
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) {
            print('Suggestions loading timed out');
          }
          return <ItemSuggestion>[];
        },
      );

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading suggestions: $e');
      }
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
      }
    }
  }

  void _applySuggestion(ItemSuggestion suggestion) {
    // Capitalize first letter for display
    final name = suggestion.name.isEmpty
        ? ''
        : '${suggestion.name[0].toUpperCase()}${suggestion.name.substring(1)}';

    setState(() {
      _titleController.text = name;

      // Apply icon if available
      if (suggestion.iconIdentifier != null) {
        _selectedIcon = FoodIconMap.getIcon(suggestion.iconIdentifier!);
      }

      // Apply location if available
      if (suggestion.location != null) {
        _location = suggestion.location;
      }

      // Apply category if available
      if (suggestion.categoryId != null) {
        _selectedCategoryId = suggestion.categoryId;
        _selectedCategoryName = suggestion.categoryName;
      }
    });
    // Note: Visual feedback is now handled by the animation in the suggestion chip
  }

  Future<void> _createItem() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an item title'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.red[800],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      DateTime? deadline;
      if (_selectedDeadline != null && _selectedTime != null) {
        deadline = DateTime(
          _selectedDeadline!.year,
          _selectedDeadline!.month,
          _selectedDeadline!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      final itemData = {
        'name': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'completed': false,
        'addedBy': user.uid,
        'addedByName': user.displayName,
        'addedAt': FieldValue.serverTimestamp(),
        'priority': 'low',
        'deadline': deadline,
        'location': _location,
        'counter': _counter,
        'iconIdentifier': _selectedIcon?.identifier,
      };

      // Add category if selected
      if (_selectedCategoryId != null) {
        itemData['categoryId'] = _selectedCategoryId;
        itemData['categoryName'] = _selectedCategoryName;
      }

      await FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.listId)
          .collection('items')
          .add(itemData);

      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Create Item',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Suggestions
            if (_suggestions.isNotEmpty || _isLoadingSuggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SmartSuggestionsWidget(
                  suggestions: _suggestions,
                  onSuggestionTapped: _applySuggestion,
                  isLoading: _isLoadingSuggestions,
                ),
              ),

            // Item Name
            _buildCard(
              title: 'Item Name',
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Item Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleController,
                        onChanged: (text) {
                          // Skip auto-fill if user has manually selected an icon
                          if (_iconManuallySelected) return;

                          // Cancel previous timer
                          _debounceTimer?.cancel();

                          // Auto-fill icon based on food item name after debounce delay
                          if (text.trim().isEmpty) return;

                          _debounceTimer =
                              Timer(const Duration(milliseconds: 500), () {
                            if (!mounted || _iconManuallySelected) return;

                            final iconIdentifier =
                                FoodIconDetector.detectFoodIcon(text);
                            if (iconIdentifier != null) {
                              final icon = FoodIconMap.getIcon(iconIdentifier);
                              if (icon != null && mounted) {
                                setState(() {
                                  _selectedIcon = icon;
                                });
                              }
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter item name...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.green[800]!, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[200]!),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[850]
                                  : Colors.grey[50],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Category Selection Card
            _buildCard(
              title: 'Category',
              child: StreamBuilder<DocumentSnapshot>(
                stream: _selectedCategoryId != null
                    ? FirebaseFirestore.instance
                        .collection('lists')
                        .doc(widget.listId)
                        .collection('categories')
                        .doc(_selectedCategoryId)
                        .snapshots()
                    : null,
                builder: (context, categorySnapshot) {
                  Map<String, dynamic>? categoryData;
                  if (categorySnapshot.hasData &&
                      categorySnapshot.data!.exists) {
                    categoryData =
                        categorySnapshot.data!.data() as Map<String, dynamic>;
                  }

                  return Card(
                    elevation: 8,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CategoryPicker(
                            listId: widget.listId,
                            selectedCategoryId: _selectedCategoryId,
                            onCategorySelected: (categoryId, categoryName) {
                              setState(() {
                                _selectedCategoryId = categoryId;
                                _selectedCategoryName = categoryName;
                              });
                            },
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: categoryData != null
                                  ? () {
                                      final iconIdentifier =
                                          categoryData!['iconIdentifier']
                                              as String?;
                                      final categoryIcon = iconIdentifier !=
                                              null
                                          ? FoodIconMap.getIcon(iconIdentifier)
                                          : null;

                                      return categoryIcon != null
                                          ? categoryIcon.buildIcon(
                                              width: 24,
                                              height: 24,
                                              color: Colors.green[800],
                                            )
                                          : Icon(
                                              Icons.label,
                                              color: Colors.green[800],
                                            );
                                    }()
                                  : Icon(
                                      Icons.label,
                                      color: Colors.green[800],
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Category',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedCategoryName ??
                                        'Select a category',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Icon Selection Card
            _buildCard(
              title: 'Icon',
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push<FoodIconMapping>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChooseItemIconScreen(
                          selectedIcon: _selectedIcon,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _selectedIcon = result;
                        _iconManuallySelected = true;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _selectedIcon != null
                              ? _selectedIcon!.buildIcon(
                                  width: 24,
                                  height: 24,
                                  color: Colors.green[800],
                                )
                              : Icon(
                                  Icons.category,
                                  color: Colors.green[800],
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Item Icon',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedIcon?.displayName ?? 'Choose an icon',
                                style: TextStyle(color: Colors.grey[600]),
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

            // Deadline Card
            _buildCard(
              title: 'Deadline',
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: isDark
                              ? ColorScheme.dark(
                                  primary: Colors.green[800]!,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.white,
                                  surface: Colors.grey[900]!,
                                )
                              : ColorScheme.light(
                                  primary: Colors.green[800]!,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: isDark
                                  ? ColorScheme.dark(
                                      primary: Colors.green[800]!,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.white,
                                      surface: Colors.grey[900]!,
                                    )
                                  : ColorScheme.light(
                                      primary: Colors.green[800]!,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (!mounted) return;
                      setState(() {
                        _selectedDeadline = date;
                        _selectedTime = time;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.calendar_today,
                              color: Colors.green[800]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deadline',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedDeadline != null
                                    ? '${DateFormat('MMM dd, yyyy').format(_selectedDeadline!)} ${_selectedTime?.format(context) ?? ''}'
                                    : 'Set deadline',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedDeadline != null)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _selectedDeadline = null;
                              _selectedTime = null;
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            _buildCard(
              title: 'Location',
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => LocationSelector(
                        initialLocation: _location,
                        listId:
                            widget.listId, // Pass listId for saved locations
                        onLocationSelected: (location) {
                          if (!mounted) return;
                          if (location.isNotEmpty) {
                            _location = location;
                          }
                          setState(() {});
                        },
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Icon(Icons.location_on, color: Colors.green[800]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _location != null
                                    ? '${_location!['name']}\n${_location!['address']}'
                                    : 'Set location',
                                style: TextStyle(color: Colors.grey[600]),
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

            // Counter Card
            _buildCard(
              title: 'Counter',
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.tag, color: Colors.green[800]),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Counter',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _counter > 1
                                ? () => setState(() => _counter--)
                                : null,
                            icon: Icon(
                              Icons.remove,
                              color: _counter > 1
                                  ? Colors.green[800]
                                  : Colors.grey[400],
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: _counter > 1
                                  ? Colors.green[100]
                                  : Colors.grey[200],
                              shape: const CircleBorder(),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[850]
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green[200]!,
                              ),
                            ),
                            child: Text(
                              '$_counter',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            onPressed: _counter < 99
                                ? () => setState(() => _counter++)
                                : null,
                            icon: Icon(
                              Icons.add,
                              color: _counter < 99
                                  ? Colors.green[800]
                                  : Colors.grey[400],
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: _counter < 99
                                  ? Colors.green[100]
                                  : Colors.grey[200],
                              shape: const CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Description Card
            _buildCard(
              title: 'Description',
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.description,
                                color: Colors.green[800]),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Add description...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.green[800]!, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[200]!),
                          ),
                          filled: true,
                          fillColor:
                              isDark ? Colors.grey[850] : Colors.grey[50],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CustomLoadingSpinner(
                      color: Colors.green,
                      size: 20.0,
                    ),
                  )
                : const Text(
                    'Create Item',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }
}
