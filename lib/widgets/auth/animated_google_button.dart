import 'package:flutter/material.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';

class AnimatedGoogleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDarkMode;

  const AnimatedGoogleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isDarkMode = false,
  });

  @override
  State<AnimatedGoogleButton> createState() => _AnimatedGoogleButtonState();
}

class _AnimatedGoogleButtonState extends State<AnimatedGoogleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  // ignore: unused_field
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  String _getRoundedAsset() {
    if (widget.isDarkMode) {
      return 'assets/badges/google/android/png@4x/dark/android_dark_rd_ctn@4x.png';
    } else {
      return 'assets/badges/google/android/png@4x/light/android_light_rd_ctn@4x.png';
    }
  }

  String _getSquareAsset() {
    if (widget.isDarkMode) {
      return 'assets/badges/google/android/png@4x/dark/android_dark_sq_ctn@4x.png';
    } else {
      return 'assets/badges/google/android/png@4x/light/android_light_sq_ctn@4x.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: widget.isLoading
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CustomLoadingSpinner(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              )
            : AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Rounded image (circle - default state)
                      Opacity(
                        opacity: 1 - _animation.value,
                        child: Image.asset(
                          _getRoundedAsset(),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      // Square image (appears when pressed)
                      Opacity(
                        opacity: _animation.value,
                        child: Image.asset(
                          _getSquareAsset(),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
