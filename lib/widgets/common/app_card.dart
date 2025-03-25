import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 4,
      color: backgroundColor ?? Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
} 