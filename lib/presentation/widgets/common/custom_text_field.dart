import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_constants.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    required this.controller,
    required this.hintText,
    super.key,
    this.labelText,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.filled = true,
    this.fillColor,
    this.border,
    this.contentPadding,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.showErrorAnimation = true,
    this.helperText,
    this.autofocus = false,
  });
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final TextInputType keyboardType;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;
  final bool filled;
  final Color? fillColor;
  final InputBorder? border;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final bool showErrorAnimation;
  final String? helperText;
  final bool autofocus;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  String? _errorText;
  late AnimationController _errorAnimationController;
  late Animation<Offset> _errorAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _errorAnimationController = AnimationController(
      vsync: this,
      duration: UiConstants.animFast,
    );

    _errorAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.05, 0),
    ).animate(
      CurvedAnimation(
        parent: _errorAnimationController,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);
    _errorAnimationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    // Trigger a rebuild when focus changes
    if (_focusNode.hasFocus) {
      setState(() {});
    }
  }

  void _validateField(String? value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      if (error != null && error != _errorText) {
        setState(() {
          _errorText = error;
        });

        if (widget.showErrorAnimation) {
          _errorAnimationController.reset();
          _errorAnimationController.forward().then((_) {
            _errorAnimationController.reverse();
          });
        }
      } else if (error == null && _errorText != null) {
        setState(() {
          _errorText = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultBorderRadius =
        BorderRadius.circular(UiConstants.borderRadiusMedium);

    return AnimatedBuilder(
      animation: _errorAnimationController,
      builder: (context, child) => Transform.translate(
        offset: _errorAnimation.value * 10, // Scale the effect
        child: child,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          helperText: widget.helperText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          filled: widget.filled,
          fillColor: widget.fillColor ??
              (theme.brightness == Brightness.dark
                  ? AppColors.surfaceDark.withAlpha(150)
                  : AppColors.backgroundLight),
          border: widget.border ??
              OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: defaultBorderRadius,
              ),
          enabledBorder: widget.border ??
              OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: defaultBorderRadius,
              ),
          focusedBorder: widget.border ??
              OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
                borderRadius: defaultBorderRadius,
              ),
          errorBorder: widget.border ??
              OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.error),
                borderRadius: defaultBorderRadius,
              ),
          focusedErrorBorder: widget.border ??
              OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.error, width: 2),
                borderRadius: defaultBorderRadius,
              ),
          contentPadding: widget.contentPadding ?? UiConstants.paddingAll16,
          hintStyle: widget.hintStyle ??
              TextStyle(
                color: theme.hintColor,
              ),
          labelStyle: widget.labelStyle,
          // Add subtle animation for focus state
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        style: widget.style,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword,
        validator: (value) {
          _validateField(value);
          return _errorText;
        },
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
          _validateField(value);
        },
        onFieldSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction,
        autofocus: widget.autofocus,
      ),
    );
  }
}
