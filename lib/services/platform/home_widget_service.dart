import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String _widgetName = 'ShopSyncWidget';

  /// Initialize the home widget
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.com.aadishsamir.shopsync');
  }

  /// Update the widget with app name, icon and theme information
  static Future<void> updateWidget({bool? isDarkMode}) async {
    try {
      // Get current theme if not provided
      final isDark = isDarkMode ?? false;

      await HomeWidget.saveWidgetData<String>('title', 'ShopSync');
      await HomeWidget.saveWidgetData<String>(
          'subtitle', 'Your Shopping Companion');
      await HomeWidget.saveWidgetData<bool>('isDarkMode', isDark);

      // Save color values for theming
      await HomeWidget.saveWidgetData<String>(
          'primaryColor', isDark ? '#2E7D32' : '#388E3C');
      await HomeWidget.saveWidgetData<String>(
          'backgroundColor', isDark ? '#1A1A1A' : '#FFFFFF');
      await HomeWidget.saveWidgetData<String>(
          'textColor', isDark ? '#FFFFFF' : '#000000');
      await HomeWidget.saveWidgetData<String>(
          'subtitleColor', isDark ? '#B0BEC5' : '#757575');

      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: 'ShopSyncWidgetProvider',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating widget: $e');
      }
    }
  }

  /// Update widget theme based on current app theme
  static Future<void> updateWidgetTheme(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await updateWidget(isDarkMode: isDark);
  }

  /// Register a callback when the widget is clicked
  static Future<void> setAppGroupId() async {
    await HomeWidget.setAppGroupId('group.com.aadishsamir.shopsync');
  }

  /// Check if home widget is available
  static Future<bool> isWidgetAvailable() async {
    return await HomeWidget.initiallyLaunchedFromHomeWidget() != null;
  }
}
