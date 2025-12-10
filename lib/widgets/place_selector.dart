import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopsync/widgets/loading_spinner.dart';

class LocationSelector extends StatefulWidget {
  final Function(Map<String, dynamic>) onLocationSelected;
  final Map<String, dynamic>? initialLocation;
  final String? listId; // Add listId to access saved locations

  const LocationSelector({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
    this.listId,
  });

  static void show(
      BuildContext context, Function(Map<String, dynamic>) onLocationSelected,
      {Map<String, dynamic>? initialLocation, String? listId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LocationSelector(
        onLocationSelected: onLocationSelected,
        initialLocation: initialLocation,
        listId: listId,
      ),
    );
  }

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector>
    with SingleTickerProviderStateMixin {
  final _storeNameController = TextEditingController();
  final _addressController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _firestore = FirebaseFirestore.instance;
  bool _showSavedLocations = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _storeNameController.text = widget.initialLocation!['name'] ?? '';
      _addressController.text = widget.initialLocation!['address'] ?? '';
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enter Store Location',
                  style: theme.textTheme.titleLarge,
                ),
                if (widget.listId != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showSavedLocations = !_showSavedLocations;
                      });
                    },
                    icon: Icon(
                      _showSavedLocations ? Icons.keyboard : Icons.bookmark,
                      size: 16,
                    ),
                    label: Text(_showSavedLocations ? 'Manual' : 'Saved'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_showSavedLocations && widget.listId != null)
              _buildSavedLocationsList(isDark)
            else ...[
              _buildStoreNameCard(isDark),
              const SizedBox(height: 16),
              _buildAddressCard(isDark),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSavedLocationsList(bool isDark) {
    return SizedBox(
      height: 300,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('lists')
            .doc(widget.listId!)
            .collection('saved_locations')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoadingSpinner());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved locations',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showSavedLocations = false;
                      });
                    },
                    child: const Text('Add new location'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green[800],
                      size: 16,
                    ),
                  ),
                  title: Text(
                    data['name'] ?? 'Unnamed Location',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle:
                      data['address'] != null ? Text(data['address']) : null,
                  onTap: () {
                    widget.onLocationSelected({
                      'name': data['name'],
                      'address': data['address'],
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStoreNameCard(bool isDark) {
    return Card(
      elevation: 8,
      shadowColor: isDark ? Colors.black87 : Colors.grey[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.store, color: Colors.green[800]),
        ),
        title: TextField(
          controller: _storeNameController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: TextStyle(
                color: isDark ? Colors.green[400] : Colors.green[800]),
            labelText: 'Store name',
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(bool isDark) {
    return Card(
      elevation: 8,
      shadowColor: isDark ? Colors.black87 : Colors.grey[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.location_on, color: Colors.green[800]),
        ),
        title: TextField(
          controller: _addressController,
          maxLines: 3,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: TextStyle(
                color: isDark ? Colors.green[400] : Colors.green[800]),
            labelText: 'Store address',
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        if (_storeNameController.text.isEmpty &&
            _addressController.text.isEmpty) {
          widget.onLocationSelected({});
        } else {
          widget.onLocationSelected({
            'name': _storeNameController.text,
            'address': _addressController.text,
          });
        }
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.save, size: 18),
          SizedBox(width: 8),
          Text('Save Changes'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
