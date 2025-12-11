import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';

class CustomLoadingSpinner extends StatelessWidget {
  final Color? color;
  final double size;

  const CustomLoadingSpinner({
    super.key,
    this.color,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: LoadingIndicatorM3E(
        variant: LoadingIndicatorM3EVariant.contained,
        color: Theme.of(context).brightness == Brightness.dark
            ? (color ?? Colors.green[900])
            : (color ?? Colors.green[400]),
        polygons: [
          MaterialShapes.softBurst,
          MaterialShapes.clover4Leaf,
          MaterialShapes.arrow,
          MaterialShapes.verySunny,
          MaterialShapes.bun,
          MaterialShapes.clamShell,
          MaterialShapes.softBoom,
          MaterialShapes.flower,
        ],
      ),
    );
  }
}
