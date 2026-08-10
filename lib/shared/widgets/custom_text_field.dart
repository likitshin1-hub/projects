import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
