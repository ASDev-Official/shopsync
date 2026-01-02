// lib/screens/onboarding.dart
import 'package:flutter/material.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import '../../services/storage/shared_prefs.dart';

class AnimatedShoppingCartPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double animation; // 0.0 to 1.0

  AnimatedShoppingCartPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cartPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    // Cart body with rounded corners
    final cartPath = Path();
    final width = size.width * 0.6;
    final height = size.height * 0.3;
    final x = (size.width - width) / 2;
    final y = size.height * 0.5;

    cartPath.moveTo(x, y);
    cartPath.lineTo(x + width, y);
    cartPath.lineTo(x + width * 0.9, y - height);
    cartPath.lineTo(x + width * 0.2, y - height);
    cartPath.close();

    // Animate cart filling
    final clipPath = Path()
      ..moveTo(x, y)
      ..lineTo(x + width * animation, y)
      ..lineTo(x + width * 0.9 * animation, y - height * animation)
      ..lineTo(x + width * 0.2, y - height * animation)
      ..close();

    canvas.drawPath(clipPath, fillPaint);
    canvas.drawPath(cartPath, cartPaint);

    // Wheels with animation
    final wheelRadius = size.width * 0.04;
    final wheel1Center = Offset(x + width * 0.25, y + wheelRadius * 2);
    final wheel2Center = Offset(x + width * 0.75, y + wheelRadius * 2);

    canvas.drawCircle(wheel1Center, wheelRadius * animation, cartPaint);
    canvas.drawCircle(wheel2Center, wheelRadius * animation, cartPaint);

    // Handle with animation
    final handlePath = Path()
      ..moveTo(x + width * 0.35, y - height)
      ..quadraticBezierTo(
        x + width * 0.5,
        y - height - (size.height * 0.1 * animation),
        x + width * 0.65,
        y - height,
      );

    canvas.drawPath(handlePath, cartPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedListPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double animation;

  AnimatedListPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final backgroundPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Paper background with shadow
    final paperRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width * 0.7,
        height: size.height * 0.7,
      ),
      Radius.circular(size.width * 0.03),
    );

    // Draw shadow
    canvas.drawRRect(
      paperRect.shift(Offset(0, 4)),
      Paint()
        ..color = primaryColor.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Draw paper background
    canvas.drawRRect(paperRect, backgroundPaint);
    canvas.drawRRect(paperRect, paint);

    // List items with animation
    final itemWidth = size.width * 0.5 * animation;
    final startX = size.width * 0.25;
    final itemSpacing = size.height * 0.12;

    for (var i = 0; i < 4; i++) {
      final y = size.height * 0.3 + (i * itemSpacing);

      // Checkbox
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, y, 15, 15),
          const Radius.circular(3),
        ),
        paint,
      );

      // Line
      canvas.drawLine(
        Offset(startX + 30, y + 7.5),
        Offset(startX + itemWidth, y + 7.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedSharePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double animation;

  AnimatedSharePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final nodeRadius = size.width * 0.08 * animation;
    final centerNode = Offset(size.width * 0.5, size.height * 0.3);
    final leftNode = Offset(size.width * 0.3, size.height * 0.7);
    final rightNode = Offset(size.width * 0.7, size.height * 0.7);

    // Draw connections with animation
    if (animation > 0.3) {
      final connectionProgress = ((animation - 0.3) / 0.7).clamp(0.0, 1.0);
      final path = Path()
        ..moveTo(centerNode.dx, centerNode.dy)
        ..lineTo(
          centerNode.dx + (leftNode.dx - centerNode.dx) * connectionProgress,
          centerNode.dy + (leftNode.dy - centerNode.dy) * connectionProgress,
        );
      canvas.drawPath(path, paint);

      final path2 = Path()
        ..moveTo(centerNode.dx, centerNode.dy)
        ..lineTo(
          centerNode.dx + (rightNode.dx - centerNode.dx) * connectionProgress,
          centerNode.dy + (rightNode.dy - centerNode.dy) * connectionProgress,
        );
      canvas.drawPath(path2, paint);
    }

    // Draw nodes with animation
    canvas.drawCircle(centerNode, nodeRadius, fillPaint);
    canvas.drawCircle(centerNode, nodeRadius, paint);

    if (animation > 0.5) {
      final nodeProgress = ((animation - 0.5) / 0.5).clamp(0.0, 1.0);
      canvas.drawCircle(leftNode, nodeRadius * nodeProgress, fillPaint);
      canvas.drawCircle(leftNode, nodeRadius * nodeProgress, paint);
      canvas.drawCircle(rightNode, nodeRadius * nodeProgress, fillPaint);
      canvas.drawCircle(rightNode, nodeRadius * nodeProgress, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _animationController;
  late final Animation<double> _pageAnimation;
  int _currentPage = 0;

  List<OnboardingPage> _buildPages(AppLocalizations l10n) => [
        OnboardingPage(
          title: l10n.welcomeToShopsync,
          description: l10n.onboardingWelcomeDescription,
          painter: (primary, secondary, animation) =>
              AnimatedShoppingCartPainter(
            primaryColor: primary,
            secondaryColor: secondary,
            animation: animation,
          ),
        ),
        OnboardingPage(
          title: l10n.smartLists,
          description: l10n.onboardingSmartListsDescription,
          painter: (primary, secondary, animation) => AnimatedListPainter(
            primaryColor: primary,
            secondaryColor: secondary,
            animation: animation,
          ),
        ),
        OnboardingPage(
          title: l10n.shareCollaborate,
          description: l10n.onboardingShareDescription,
          painter: (primary, secondary, animation) => AnimatedSharePainter(
            primaryColor: primary,
            secondaryColor: secondary,
            animation: animation,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Colors.green;
    final secondaryColor = Colors.green[700]!;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final pages = _buildPages(l10n);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageAnimation,
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 300,
                          width: 300,
                          child: CustomPaint(
                            painter: pages[index].painter(
                              primaryColor,
                              secondaryColor,
                              _pageAnimation.value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _pageAnimation.value,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(_pageAnimation),
                            child: Text(
                              pages[index].title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _pageAnimation.value,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(_pageAnimation),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                pages[index].description,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Positioned(
              bottom: 48,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _currentPage == pages.length - 1
                        ? null
                        : _finishOnboarding,
                    child: Text(
                      l10n.onboardingSkip,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? primaryColor
                              : primaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _currentPage < pages.length - 1
                        ? _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                        : _finishOnboarding(),
                    child: Text(
                      _currentPage == pages.length - 1
                          ? l10n.onboardingDone
                          : l10n.onboardingNext,
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pageAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _finishOnboarding() async {
    await SharedPrefs.setFirstLaunch();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final CustomPainter Function(Color primary, Color secondary, double animation)
      painter;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.painter,
  });
}
