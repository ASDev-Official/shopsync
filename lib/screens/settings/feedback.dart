import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  InAppWebViewController? webViewController;
  bool isLoading = true;

  Future<bool> _onWillPop() async {
    if (webViewController != null) {
      // Check if webview can go back
      if (await webViewController!.canGoBack()) {
        // Go back in webview
        await webViewController!.goBack();
        return false; // Don't pop the screen
      }
    }
    // If no webview history, allow normal back navigation
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri('https://as-shopsync-forms.pages.dev'),
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
                onWebViewCreated: (controller) {
                  webViewController = controller;

                  // Add handler for close button
                  controller.addJavaScriptHandler(
                    handlerName: 'closeShopSync',
                    callback: (args) async {
                      final shouldPop = await _onWillPop();
                      if (shouldPop && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  );
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url;

                  if (uri != null) {
                    final host = uri.host;

                    // Allow navigation within the forms domain
                    if (host == 'as-shopsync-forms.pages.dev') {
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
                  setState(() {
                    isLoading = true;
                  });
                },
                onLoadStop: (controller, url) async {
                  // Get current theme mode
                  final isDarkMode =
                      Theme.of(context).brightness == Brightness.dark;

                  // Inject theme information and back button
                  await controller.evaluateJavascript(source: '''
                    (function() {
                      // Set theme information
                      window.shopSyncTheme = {
                        isDark: ${isDarkMode ? 'true' : 'false'},
                        brightness: '${isDarkMode ? 'dark' : 'light'}'
                      };
                      
                      // Dispatch custom event to notify webpage of theme
                      window.dispatchEvent(new CustomEvent('shopSyncThemeChanged', {
                        detail: window.shopSyncTheme
                      }));
                      
                      function addCloseButton() {
                        const titleElement = document.querySelector('.MuiTypography-root.MuiTypography-h6.css-m9fo68');
                        const toolbar = document.querySelector('.MuiToolbar-root');
                        
                        if (titleElement && toolbar && !document.getElementById('shopsync-close-btn')) {
                          const closeButton = document.createElement('button');
                          closeButton.id = 'shopsync-close-btn';
                          closeButton.innerHTML = `
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                              <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z" fill="currentColor"/>
                            </svg>
                          `;
                          closeButton.style.cssText = `
                            position: absolute;
                            left: 16px;
                            top: 50%;
                            transform: translateY(-50%);
                            width: 40px;
                            height: 40px;
                            background: transparent;
                            border: none;
                            color: white;
                            cursor: pointer;
                            border-radius: 4px;
                            transition: all 0.2s;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            z-index: 9999;
                            padding: 8px;
                          `;
                          
                          closeButton.onmouseover = function() {
                            this.style.backgroundColor = 'rgba(255, 255, 255, 0.1)';
                          };
                          
                          closeButton.onmouseout = function() {
                            this.style.backgroundColor = 'transparent';
                          };
                          
                          closeButton.onclick = function() {
                            window.flutter_inappwebview.callHandler('closeShopSync');
                          };
                          
                          // Add to toolbar instead of title element
                          toolbar.style.position = 'relative';
                          toolbar.appendChild(closeButton);
                          
                          // Adjust title element margin to make room for close button
                          titleElement.style.marginLeft = '40px';
                        }
                      }
                      
                      // Try to add button immediately
                      addCloseButton();
                      
                      // Also try after a short delay in case the element loads later
                      setTimeout(addCloseButton, 500);
                      setTimeout(addCloseButton, 1000);
                      setTimeout(addCloseButton, 2000);
                      
                      // Watch for DOM changes to catch dynamically loaded content
                      const observer = new MutationObserver(function(mutations) {
                        addCloseButton();
                      });
                      
                      observer.observe(document.body, {
                        childList: true,
                        subtree: true
                      });
                    })();
                  ''');
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
                      title: const Text('ShopSync Forms'),
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
