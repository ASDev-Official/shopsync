import '/libraries/icons/food_icons_map.dart';

/// Detects food icons from text input
class FoodIconDetector {
  /// Detects a food icon based on the input text
  /// Returns the icon identifier if found, null otherwise
  static String? detectFoodIcon(String input) {
    if (input.trim().length < 2) return null;

    final query = input.trim().toLowerCase();

    // Search for matching icons using the FoodIconMap's search function
    final results = FoodIconMap.searchFoodIcons(query);

    if (results.isEmpty) return null;

    // Try to find an exact match first
    for (var icon in results) {
      if (icon.displayName.toLowerCase() == query) {
        return icon.identifier;
      }
    }

    // Try to find a match that starts with the query
    for (var icon in results) {
      if (icon.displayName.toLowerCase().startsWith(query)) {
        return icon.identifier;
      }
    }

    // Conservative fallback: only return if the first result contains the query
    if (results.first.displayName.toLowerCase().contains(query)) {
      return results.first.identifier;
    }

    // No conservative match found
    return null;
  }
}
