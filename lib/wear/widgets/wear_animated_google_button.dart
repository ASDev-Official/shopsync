import 'package:flutter/material.dart';

class WearAnimatedGoogleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;

  const WearAnimatedGoogleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.height = 48.0,
  });

  @override
  State<WearAnimatedGoogleButton> createState() =>
      _WearAnimatedGoogleButtonState();
}

class _WearAnimatedGoogleButtonState extends State<WearAnimatedGoogleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !widget.isLoading,
      label:
          widget.isLoading ? 'Signing in with Google' : 'Continue with Google',
      child: SizedBox(
        width: double.infinity,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: widget.height, // WearOS accessibility requirement
            minWidth: widget.height,
          ),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.isLoading ? Colors.grey[800] : Colors.transparent,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            // Rounded image (default/unpressed state)
                            Opacity(
                              opacity: 1 - _animation.value,
                              child: Image.asset(
                                'assets/badges/google/android/png@4x/dark/android_dark_rd_na@4x.png',
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            // Square image (pressed state)
                            Opacity(
                              opacity: _animation.value,
                              child: Image.asset(
                                'assets/badges/google/android/png@4x/dark/android_dark_sq_na@4x.png',
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
          ),
        ),
      ),
    );
  }
}
