import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import '../../screens/admin/update_app.dart';

class UpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          context.mounted) {
        // Show update screen - replace the current route with the update screen
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UpdateAppScreen(
              updateInfo: updateInfo,
              onUpdateComplete: (completed) {
                // This won't be called immediately as the app will restart after update
                if (completed && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  // Check if an update is downloaded and ready to install
  static Future<bool> isUpdateDownloaded() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      return updateInfo.installStatus == InstallStatus.downloaded;
    } catch (e) {
      debugPrint('Check for downloaded update failed: $e');
      return false;
    }
  }

  // Get the current update status
  static Stream<InstallStatus> getUpdateStatus() {
    return InAppUpdate.installUpdateListener;
  }
}
