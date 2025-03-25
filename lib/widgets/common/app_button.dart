import 'package:flutter/material.dart';
import '../../core/theme.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  variant == AppButtonVariant.outline
                      ? AppTheme.primaryColor
                      : Colors.white,
                ),
              ),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(icon, size: 18),
          ),
        Text(text),
      ],
    );

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: theme.elevatedButtonTheme.style,
          child: buttonChild,
        );
        break;
      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: theme.elevatedButtonTheme.style?.copyWith(
            backgroundColor: MaterialStateProperty.all(AppTheme.secondaryColor),
          ),
          child: buttonChild,
        );
        break;
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: theme.outlinedButtonTheme.style,
          child: buttonChild,
        );
        break;
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: theme.textButtonTheme.style,
          child: buttonChild,
        );
        break;
    }

    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    } else if (width != null) {
      button = SizedBox(
        width: width,
        child: button,
      );
    }

    if (height != null) {
      button = SizedBox(
        height: height,
        child: button,
      );
    }

    if (padding != null) {
      button = Padding(
        padding: padding!,
        child: button,
      );
    }

    return button;
  }
} 