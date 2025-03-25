import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      readOnly: readOnly,
      focusNode: focusNode,
      autofocus: autofocus,
      enabled: enabled,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: enabled 
          ? AppTheme.primaryTextColor 
          : AppTheme.disabledTextColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: enabled 
          ? theme.inputDecorationTheme.fillColor 
          : AppTheme.disabledTextColor.withOpacity(0.1),
      ),
    );
  }
} 