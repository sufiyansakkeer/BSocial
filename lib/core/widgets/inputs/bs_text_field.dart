import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../utils/ui_constants.dart';

/// A customizable text field component for BSocial
class BSTextField extends StatefulWidget {
  /// Creates a BSocial text field
  const BSTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.enabled = true,
    this.autofocus = false,
    this.readOnly = false,
    this.borderRadius,
    this.filled = true,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.helperStyle,
    this.contentPadding,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.showCursor,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.togglePasswordVisibility = false,
  });

  /// The controller for the text field
  final TextEditingController? controller;

  /// The label text for the text field
  final String? labelText;

  /// The hint text for the text field
  final String? hintText;

  /// The helper text for the text field
  final String? helperText;

  /// The error text for the text field
  final String? errorText;

  /// The prefix icon for the text field
  final Widget? prefixIcon;

  /// The suffix icon for the text field
  final Widget? suffixIcon;

  /// Whether to obscure the text (for passwords)
  final bool obscureText;

  /// The keyboard type for the text field
  final TextInputType? keyboardType;

  /// The text input action for the text field
  final TextInputAction? textInputAction;

  /// The maximum number of lines for the text field
  final int? maxLines;

  /// The minimum number of lines for the text field
  final int? minLines;

  /// The maximum length of the text field
  final int? maxLength;

  /// Callback when the text field value changes
  final ValueChanged<String>? onChanged;

  /// Callback when the text field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Validator for the text field
  final FormFieldValidator<String>? validator;

  /// Input formatters for the text field
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the text field is enabled
  final bool enabled;

  /// Whether the text field should autofocus
  final bool autofocus;

  /// Whether the text field is read-only
  final bool readOnly;

  /// The border radius of the text field
  final BorderRadius? borderRadius;

  /// Whether the text field is filled
  final bool filled;

  /// The fill color of the text field
  final Color? fillColor;

  /// The border color of the text field
  final Color? borderColor;

  /// The focused border color of the text field
  final Color? focusedBorderColor;

  /// The error border color of the text field
  final Color? errorBorderColor;

  /// The text style of the text field
  final TextStyle? textStyle;

  /// The label style of the text field
  final TextStyle? labelStyle;

  /// The hint style of the text field
  final TextStyle? hintStyle;

  /// The error style of the text field
  final TextStyle? errorStyle;

  /// The helper style of the text field
  final TextStyle? helperStyle;

  /// The content padding of the text field
  final EdgeInsetsGeometry? contentPadding;

  /// The text alignment of the text field
  final TextAlign textAlign;

  /// The text capitalization of the text field
  final TextCapitalization textCapitalization;

  /// Whether to show the cursor
  final bool? showCursor;

  /// Whether to enable autocorrect
  final bool autocorrect;

  /// Whether to enable suggestions
  final bool enableSuggestions;

  /// Whether to show a toggle button for password visibility
  final bool togglePasswordVisibility;

  @override
  State<BSTextField> createState() => _BSTextFieldState();
}

class _BSTextFieldState extends State<BSTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = widget.borderRadius ??
        BorderRadius.circular(UiConstants.borderRadiusMedium);

    final effectiveFillColor = widget.fillColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade100);

    final effectiveBorderColor = widget.borderColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade300);

    final effectiveFocusedBorderColor =
        widget.focusedBorderColor ?? theme.colorScheme.primary;

    final effectiveErrorBorderColor =
        widget.errorBorderColor ?? theme.colorScheme.error;

    final effectiveContentPadding = widget.contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16);

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final effectiveSuffixIcon = widget.togglePasswordVisibility
        ? IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _isFocused
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
            ),
            onPressed: _togglePasswordVisibility,
          )
        : widget.suffixIcon;

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      textAlign: widget.textAlign,
      textCapitalization: widget.textCapitalization,
      showCursor: widget.showCursor,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      style: widget.textStyle ?? theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: effectiveSuffixIcon,
        filled: widget.filled,
        fillColor: effectiveFillColor,
        labelStyle: widget.labelStyle,
        hintStyle: widget.hintStyle,
        errorStyle: widget.errorStyle,
        helperStyle: widget.helperStyle,
        contentPadding: effectiveContentPadding,
        border: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(color: effectiveFocusedBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(color: effectiveErrorBorderColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: effectiveBorderRadius,
          borderSide: BorderSide(color: effectiveErrorBorderColor, width: 2),
        ),
      ),
    );
  }
}
