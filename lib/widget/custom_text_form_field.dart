import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.suffixIcon,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    required this.validator,
    required this.type,
    this.fillColor,
    this.labelColor,
  });
  final TextEditingController controller;
  final Widget? suffixIcon;
  final String labelText;
  final Widget prefixIcon;
  final bool obscureText;
  final String? Function(String?) validator;
  final TextInputType type;
  final Color? fillColor;
  final Color? labelColor;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(),
        filled: fillColor != null,
        fillColor: fillColor,
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: type,
    );
  }
}
