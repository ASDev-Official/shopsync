import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shopsync/l10n/app_localizations.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const String _formsHost = 'forms.shopsync.aadish.dev';
  static const String _closeRoutePath = '/close-shopsync';

  bool isLoading = true;
  bool _isClosing = false;

  bool _isCloseRoute(WebUri? uri) {
    if (uri == null) {
      return false;
    }

    final host = uri.host;
    final isFormsRoute = host.isEmpty || host == _formsHost;
    if (!isFormsRoute) {
      return false;
    }

    final normalizedPath =
        uri.path.toLowerCase().replaceAll(RegExp(r'/+$'), '');
    final normalizedClose = _closeRoutePath.toLowerCase();

    if (normalizedPath == normalizedClose) {
      return true;
    }

    final fragment = uri.fragment.toLowerCase().replaceAll(RegExp(r'/+$'), '');
    return fragment == normalizedClose || fragment.endsWith(normalizedClose);
  }

  void _returnToHome() {
    if (!mounted || _isClosing) {
      return;
    }

    _isClosing = true;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        // Intentionally ignore back actions on this screen.
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri('https://forms.shopsync.aadish.dev'),
                ),
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: false,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  iframeAllow: "camera; microphone",
                  iframeAllowFullscreen: true,
                  javaScriptEnabled: true,
                  supportZoom: false,
                  javaScriptCanOpenWindowsAutomatically: true,
                ),
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url;

                  if (uri != null) {
                    if (_isCloseRoute(uri)) {
                      _returnToHome();
                      return NavigationActionPolicy.CANCEL;
                    }

                    final host = uri.host;

                    // Allow navigation within the forms domain
                    if (host == _formsHost) {
                      return NavigationActionPolicy.ALLOW;
                    }

                    // Open external links in system browser
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }

                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStart: (controller, url) {
                  if (_isCloseRoute(url)) {
                    _returnToHome();
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });
                },
                onUpdateVisitedHistory: (controller, url, isReload) {
                  if (_isCloseRoute(url)) {
                    _returnToHome();
                  }
                },
                onLoadStop: (controller, url) async {
                  if (_isCloseRoute(url)) {
                    _returnToHome();
                    return;
                  }
                  // Add 500ms delay before hiding loading screen
                  await Future.delayed(const Duration(milliseconds: 500));

                  setState(() {
                    isLoading = false;
                  });
                },
                onReceivedError: (controller, request, error) {
                  setState(() {
                    isLoading = false;
                  });
                },
              ),
              if (isLoading)
                Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF121212) // Dark background
                      : const Color(0xFFFFFFFF), // Light background
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      title: Text(AppLocalizations.of(context)!.shopsyncForms),
                      titleTextStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Color.fromRGBO(65, 137, 68, 1),
                      foregroundColor: Colors.white,
                    ),
                    body: Center(
                      child: CustomLoadingSpinner(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
