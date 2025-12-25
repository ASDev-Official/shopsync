class StatuspageConfig {
  // Base API URL for your Atlassian Statuspage. Update to your page's domain.
  // Example: https://yourpage.statuspage.io/api/v2
  static const String baseApiUrl = 'https://shopsync.statuspage.io/api/v2';

  // Polling interval in minutes to avoid rate limits
  static const Duration pollingInterval = Duration(minutes: 1);

  // Whether to show the initial fullscreen outage dialog once per app run
  static const bool showInitialDialog = true;
}
