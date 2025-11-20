import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '/models/item_suggestion.dart';

/// Service for generating smart item suggestions based on user behavior
/// This is an on-device ML system that learns from user patterns
class SmartSuggestionsService {
  static const String _cacheKey = 'smart_suggestions_cache';
  static const String _lastTrainedKey = 'suggestions_last_trained';
  static const int _minItemsForSuggestions = 5;
  static const int _maxSuggestions = 10;
  static const double _minConfidenceThreshold = 0.3;
  static const int _daysToAnalyze = 90; // Analyze last 90 days

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ItemSuggestion>? _cachedSuggestions;
  DateTime? _lastTrainedTime;
  bool _isTraining = false;

  /// Get smart suggestions for the current context
  Future<List<ItemSuggestion>> getSuggestions({
    String? listId,
    bool forceRefresh = false,
  }) async {
    try {
      // Load cached suggestions first for fast response
      if (_cachedSuggestions == null) {
        await _loadCachedSuggestions();
      }

      // Check if we need to retrain
      final shouldRetrain = await _shouldRetrain();

      // Train in background if needed (don't await to avoid blocking UI)
      if (forceRefresh || shouldRetrain) {
        // Fire and forget - train without blocking
        unawaited(_trainModel(listId: listId));
      }

      // Return cached suggestions immediately
      final contextRankedSuggestions = _rankSuggestionsByContext(
        _cachedSuggestions ?? [],
      );

      return contextRankedSuggestions.take(_maxSuggestions).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting suggestions: $e');
      }
      return [];
    }
  }

  /// Check if model should be retrained
  Future<bool> _shouldRetrain() async {
    if (_isTraining) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTrainedStr = prefs.getString(_lastTrainedKey);

      if (lastTrainedStr == null) return true;

      final lastTrained = DateTime.parse(lastTrainedStr);
      _lastTrainedTime = lastTrained;

      // Retrain every 24 hours
      return DateTime.now().difference(lastTrained).inHours >= 24;
    } catch (e) {
      return true;
    }
  }

  /// Train the model by analyzing user's item history
  Future<void> _trainModel({String? listId}) async {
    if (_isTraining) {
      if (kDebugMode) {
        print('Training already in progress, skipping');
      }
      return;
    }
    _isTraining = true;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _isTraining = false;
        return;
      }

      // Collect learning data from user's items (with limit to prevent blocking)
      final learningData = await _collectLearningData(user.uid, listId);

      if (learningData.length < _minItemsForSuggestions) {
        if (kDebugMode) {
          print('Not enough items for suggestions: ${learningData.length}');
        }
        _isTraining = false;
        return;
      }

      if (kDebugMode) {
        print('Training with ${learningData.length} item samples');
      }

      // Generate suggestions from learning data
      final suggestions = _generateSuggestions(learningData);

      // Cache suggestions
      await _cacheSuggestions(suggestions);
      _cachedSuggestions = suggestions;

      // Update last trained time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastTrainedKey, DateTime.now().toIso8601String());
      _lastTrainedTime = DateTime.now();

      if (kDebugMode) {
        print(
            'Model trained successfully with ${suggestions.length} suggestions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error training model: $e');
      }
    } finally {
      _isTraining = false;
    }
  }

  /// Collect learning data from Firestore
  Future<List<ItemLearningData>> _collectLearningData(
    String userId,
    String? listId,
  ) async {
    final learningData = <ItemLearningData>[];
    final cutoffDate = DateTime.now().subtract(Duration(days: _daysToAnalyze));

    try {
      Query query;

      if (listId != null) {
        // Get items from specific list
        query = _firestore
            .collection('lists')
            .doc(listId)
            .collection('items')
            .where('addedAt', isGreaterThan: cutoffDate)
            .orderBy('addedAt', descending: true)
            .limit(500);
      } else {
        // Get items from all lists the user has access to
        final listsSnapshot = await _firestore
            .collection('lists')
            .where('members', arrayContains: userId)
            .get();

        for (final listDoc in listsSnapshot.docs) {
          final itemsSnapshot = await _firestore
              .collection('lists')
              .doc(listDoc.id)
              .collection('items')
              .where('addedAt', isGreaterThan: cutoffDate)
              .orderBy('addedAt', descending: true)
              .limit(200)
              .get();

          for (final itemDoc in itemsSnapshot.docs) {
            final data = itemDoc.data();
            if (data['name'] != null && (data['name'] as String).isNotEmpty) {
              learningData.add(ItemLearningData.fromFirestore(data));
            }
          }
        }
        return learningData;
      }

      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['name'] != null && (data['name'] as String).isNotEmpty) {
          learningData.add(ItemLearningData.fromFirestore(data));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error collecting learning data: $e');
      }
    }

    return learningData;
  }

  /// Generate suggestions from learning data using pattern analysis
  List<ItemSuggestion> _generateSuggestions(
    List<ItemLearningData> learningData,
  ) {
    final suggestions = <ItemSuggestion>[];

    // Group items by normalized name
    final groupedItems = groupBy(
      learningData,
      (ItemLearningData item) => item.name,
    );

    for (final entry in groupedItems.entries) {
      final itemName = entry.key;
      final itemInstances = entry.value;

      // Skip if not enough instances
      if (itemInstances.isEmpty) continue;

      // Calculate frequency
      final frequency = itemInstances.length;

      // Find most common icon, location, and category
      final mostCommonIcon = _findMostCommon(
        itemInstances.map((t) => t.iconIdentifier).whereType<String>().toList(),
      );
      final mostCommonCategoryId = _findMostCommon(
        itemInstances.map((t) => t.categoryId).whereType<String>().toList(),
      );
      final mostCommonCategoryName = mostCommonCategoryId != null
          ? itemInstances
              .firstWhere(
                (t) => t.categoryId == mostCommonCategoryId,
                orElse: () => itemInstances.first,
              )
              .categoryName
          : null;

      // Get the most recent location (locations may vary)
      final mostRecentLocation = itemInstances
          .where((t) => t.location != null)
          .map((t) => t.location)
          .firstOrNull;

      // Analyze temporal patterns
      final daysOfWeek = itemInstances.map((t) => t.dayOfWeek).toList();
      final hoursOfDay = itemInstances.map((t) => t.hourOfDay).toList();

      // Find common days and hours
      final commonDays = _findCommonValues(daysOfWeek);
      final commonHours = _findCommonValues(hoursOfDay);

      // Calculate confidence based on multiple factors
      final confidence = _calculateConfidence(
        frequency: frequency,
        totalItems: learningData.length,
        dayPatternStrength: commonDays.length / 7.0,
        hourPatternStrength: commonHours.length / 24.0,
        lastUsed: itemInstances.map((t) => t.addedAt).reduce(
              (a, b) => a.isAfter(b) ? a : b,
            ),
      );

      // Only add if confidence meets threshold
      if (confidence >= _minConfidenceThreshold) {
        suggestions.add(ItemSuggestion(
          name: itemName,
          iconIdentifier: mostCommonIcon,
          location: mostRecentLocation,
          categoryId: mostCommonCategoryId,
          categoryName: mostCommonCategoryName,
          confidence: confidence,
          lastUsed: itemInstances.map((t) => t.addedAt).reduce(
                (a, b) => a.isAfter(b) ? a : b,
              ),
          frequency: frequency,
          commonDaysOfWeek: commonDays,
          commonHoursOfDay: commonHours,
        ));
      }
    }

    // Sort by confidence and recency
    suggestions.sort((a, b) {
      final confidenceCompare = b.confidence.compareTo(a.confidence);
      if (confidenceCompare != 0) return confidenceCompare;
      return b.lastUsed.compareTo(a.lastUsed);
    });

    return suggestions;
  }

  /// Calculate confidence score for a suggestion
  double _calculateConfidence({
    required int frequency,
    required int totalItems,
    required double dayPatternStrength,
    required double hourPatternStrength,
    required DateTime lastUsed,
  }) {
    // Base confidence from frequency
    double confidence = (frequency / totalItems).clamp(0.0, 1.0);

    // Boost for temporal patterns (if item has consistent timing)
    final patternBoost = (dayPatternStrength * 0.3 + hourPatternStrength * 0.2);
    confidence += patternBoost;

    // Boost for recent usage (decay over time)
    final daysSinceLastUse = DateTime.now().difference(lastUsed).inDays;
    final recencyBoost =
        (1.0 - (daysSinceLastUse / _daysToAnalyze)).clamp(0.0, 1.0) * 0.3;
    confidence += recencyBoost;

    // Normalize to 0-1 range
    return confidence.clamp(0.0, 1.0);
  }

  /// Find most common value in a list
  T? _findMostCommon<T>(List<T> values) {
    if (values.isEmpty) return null;

    final counts = <T, int>{};
    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }

    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Find values that appear more frequently than average
  List<T> _findCommonValues<T>(List<T> values) {
    if (values.isEmpty) return [];

    final counts = <T, int>{};
    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }

    // Calculate threshold (mean frequency)
    final avgFrequency = values.length / counts.length;

    return counts.entries
        .where((entry) => entry.value >= avgFrequency)
        .map((entry) => entry.key)
        .toList();
  }

  /// Rank suggestions based on current context (time of day, day of week)
  List<ItemSuggestion> _rankSuggestionsByContext(
    List<ItemSuggestion> suggestions,
  ) {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentHour = now.hour;

    final scoredSuggestions = suggestions.map((suggestion) {
      double contextScore = suggestion.confidence;

      // Boost if current day matches common days
      if (suggestion.commonDaysOfWeek.contains(currentDay)) {
        contextScore += 0.2;
      }

      // Boost if current hour matches common hours
      if (suggestion.commonHoursOfDay.contains(currentHour)) {
        contextScore += 0.15;
      }

      // Slight boost if hour is close to common hours
      final nearbyHours = suggestion.commonHoursOfDay.where(
        (hour) => (hour - currentHour).abs() <= 2,
      );
      if (nearbyHours.isNotEmpty) {
        contextScore += 0.05;
      }

      return MapEntry(suggestion, contextScore);
    }).toList();

    scoredSuggestions.sort((a, b) => b.value.compareTo(a.value));

    return scoredSuggestions.map((entry) => entry.key).toList();
  }

  /// Cache suggestions to shared preferences
  Future<void> _cacheSuggestions(List<ItemSuggestion> suggestions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = suggestions.map((s) => s.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      if (kDebugMode) {
        print('Error caching suggestions: $e');
      }
    }
  }

  /// Load cached suggestions from shared preferences
  Future<void> _loadCachedSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);

      if (cachedJson != null) {
        final jsonList = jsonDecode(cachedJson) as List;
        _cachedSuggestions = jsonList
            .map(
                (json) => ItemSuggestion.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cached suggestions: $e');
      }
    }
  }

  /// Clear all cached data (useful for testing or reset)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastTrainedKey);
      _cachedSuggestions = null;
      _lastTrainedTime = null;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
    }
  }

  /// Force retrain the model
  Future<void> forceRetrain({String? listId}) async {
    _cachedSuggestions = null;
    await _trainModel(listId: listId);
  }

  /// Get statistics about the suggestion system
  Future<Map<String, dynamic>> getStats() async {
    await _loadCachedSuggestions();

    return {
      'totalSuggestions': _cachedSuggestions?.length ?? 0,
      'lastTrained': _lastTrainedTime?.toIso8601String(),
      'isTraining': _isTraining,
      'suggestions': _cachedSuggestions
              ?.map((s) => {
                    'name': s.name,
                    'confidence': s.confidence,
                    'frequency': s.frequency,
                  })
              .toList() ??
          [],
    };
  }
}
