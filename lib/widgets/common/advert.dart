import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';

class AdvertWidget extends StatefulWidget {
  /// The AdMob advertisement to display
  final Ad? ad;

  /// Optional height for the advertisement container
  /// If not provided, will use the ad's actual height
  final double? height;

  /// Optional width for the advertisement container
  /// If not provided, will use the ad's actual width
  final double? width;

  /// Background color for the container when ad is loading or null
  final Color backgroundColor;

  /// Placeholder widget to show when ad is null or loading
  final Widget? placeholder;

  /// Whether to show a loading indicator when ad is null
  final bool showLoadingIndicator;

  /// Whether to show the advertisement label above the ad
  final bool showLabel;

  /// Custom label text (defaults to 'ADVERTISEMENT')
  final String labelText;

  /// Custom label icon (defaults to Icons.ads_click)
  final IconData labelIcon;

  const AdvertWidget({
    super.key,
    required this.ad,
    this.height,
    this.width,
    this.backgroundColor = Colors.grey,
    this.placeholder,
    this.showLoadingIndicator = true,
    this.showLabel = true,
    this.labelText = 'ADVERTISEMENT',
    this.labelIcon = Icons.ads_click,
  });

  @override
  State<AdvertWidget> createState() => _AdvertWidgetState();
}

class _AdvertWidgetState extends State<AdvertWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Advertisement label
        if (widget.showLabel)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.labelIcon,
                  size: 14.0,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4.0),
                Text(
                  widget.labelText,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        // Advertisement container
        Container(
          height: widget.height ?? _getAdHeight(),
          width: widget.width ?? _getAdWidth(),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          child: _buildAdContent(),
        ),
      ],
    );
  }

  /// Builds the content of the advertisement container
  Widget _buildAdContent() {
    // Don't show ads on web platform
    if (kIsWeb) {
      return _buildWebPlaceholder();
    }

    if (widget.ad == null) {
      return _buildPlaceholder();
    }

    // Check if the ad is a banner ad and if it's loaded
    if (widget.ad is BannerAd) {
      final bannerAd = widget.ad as BannerAd;
      return AdWidget(ad: bannerAd);
    }

    // Check if the ad is a native ad
    if (widget.ad is NativeAd) {
      final nativeAd = widget.ad as NativeAd;
      return AdWidget(ad: nativeAd);
    }

    // For other ad types or if ad is not ready
    return _buildPlaceholder();
  }

  /// Builds the placeholder content when ad is not available
  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showLoadingIndicator) ...[
            const CustomLoadingSpinner(),
            const SizedBox(height: 8.0),
          ],
          Text(
            'Advertisement',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a placeholder for web platform where ads are not supported
  Widget _buildWebPlaceholder() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.web,
              color: Colors.grey.shade500,
              size: 24.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Ads not supported on web',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the height of the advertisement
  double _getAdHeight() {
    // Return default height for web
    if (kIsWeb) {
      return 60.0;
    }

    if (widget.ad is BannerAd) {
      final bannerAd = widget.ad as BannerAd;
      return bannerAd.size.height.toDouble();
    }

    // Default height for other ad types or when ad is null
    return 60.0;
  }

  /// Gets the width of the advertisement
  double _getAdWidth() {
    // Return default width for web
    if (kIsWeb) {
      return double.infinity;
    }

    if (widget.ad is BannerAd) {
      final bannerAd = widget.ad as BannerAd;
      return bannerAd.size.width.toDouble();
    }

    // Default width for other ad types or when ad is null
    return double.infinity;
  }

  @override
  void dispose() {
    // Note: The parent widget should dispose of the ad
    // This widget only displays it
    super.dispose();
  }
}

/// A specialized widget for banner advertisements
class BannerAdvertWidget extends StatelessWidget {
  final BannerAd? bannerAd;
  final double? height;
  final double? width;
  final Color backgroundColor;
  final bool showLabel;
  final String labelText;
  final IconData labelIcon;

  const BannerAdvertWidget({
    super.key,
    required this.bannerAd,
    this.height,
    this.width,
    this.backgroundColor = Colors.grey,
    this.showLabel = true,
    this.labelText = 'ADVERTISEMENT',
    this.labelIcon = Icons.ads_click,
  });

  @override
  Widget build(BuildContext context) {
    return AdvertWidget(
      ad: bannerAd,
      height: height,
      width: width,
      backgroundColor: backgroundColor,
      showLabel: showLabel,
      labelText: labelText,
      labelIcon: labelIcon,
    );
  }
}

/// A specialized widget for native advertisements
class NativeAdvertWidget extends StatelessWidget {
  final NativeAd? nativeAd;
  final double? height;
  final double? width;
  final Color backgroundColor;
  final bool showLabel;
  final String labelText;
  final IconData labelIcon;

  const NativeAdvertWidget({
    super.key,
    required this.nativeAd,
    this.height,
    this.width,
    this.backgroundColor = Colors.grey,
    this.showLabel = true,
    this.labelText = 'ADVERTISEMENT',
    this.labelIcon = Icons.ads_click,
  });

  @override
  Widget build(BuildContext context) {
    return AdvertWidget(
      ad: nativeAd,
      height: height,
      width: width,
      backgroundColor: backgroundColor,
      showLabel: showLabel,
      labelText: labelText,
      labelIcon: labelIcon,
    );
  }
}
