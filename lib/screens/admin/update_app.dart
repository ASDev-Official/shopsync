import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import '../../services/platform/update_service.dart';

class UpdateAppScreen extends StatefulWidget {
  final AppUpdateInfo updateInfo;
  final Function(bool) onUpdateComplete;

  const UpdateAppScreen({
    super.key,
    required this.updateInfo,
    required this.onUpdateComplete,
  });

  @override
  State<UpdateAppScreen> createState() => _UpdateAppScreenState();
}

class _UpdateAppScreenState extends State<UpdateAppScreen> {
  bool _isDownloading = false;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();

    // Listen to download status changes
    InAppUpdate.installUpdateListener.listen((status) {
      if (status == InstallStatus.downloaded) {
        setState(() {
          _isDownloaded = true;
          _isDownloading = false;
        });
      } else if (status == InstallStatus.downloading) {
        setState(() {
          _isDownloading = true;
          _isDownloaded = false;
        });
      } else if (status == InstallStatus.installed) {
        widget.onUpdateComplete(true);
      }
    });
  }

  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await UpdateService.isUpdateDownloaded();
    if (isDownloaded) {
      setState(() {
        _isDownloaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
          elevation: 0,
          title: const Text(
            'ShopSync Update',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.system_update,
                  size: 100,
                  color: Colors.green,
                ),
                const SizedBox(height: 32),
                const Text(
                  'ShopSync has an update',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please update the app to continue using the latest features and improvements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                if (_isDownloading && !_isDownloaded) ...[
                  StreamBuilder<InstallStatus>(
                    stream: UpdateService.getUpdateStatus(),
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          // Indeterminate progress indicator
                          const LinearProgressIndicator(
                            backgroundColor: Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Downloading update...',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isDownloading && !_isDownloaded
                        ? null
                        : () => _handleUpdateButtonPress(),
                    child: Text(
                      _isDownloaded
                          ? 'Install'
                          : (_isDownloading ? 'Downloading...' : 'Update'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdateButtonPress() async {
    try {
      // Directly start an immediate update
      final result = await InAppUpdate.performImmediateUpdate();

      if (result == AppUpdateResult.success) {
        debugPrint('Immediate update completed successfully');
      } else if (result == AppUpdateResult.userDeniedUpdate) {
        debugPrint('User denied the immediate update');
      } else {
        debugPrint('Immediate update failed: $result');
      }
    } catch (e) {
      debugPrint('Immediate update action failed: $e');
    }
  }
}
