import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({super.key, required this.controller, this.suffixIcon, required this.labelText, required this.prefixIcon, this.obscureText = false, required this.validator, required this.type});
  final TextEditingController controller;
  final Widget? suffixIcon;
  final String labelText;
  final Widget prefixIcon;
  final bool obscureText;
  final String? Function(String?) validator;
  final TextInputType type;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        labelText: labelText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(),
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: type,
    );
  }
}
