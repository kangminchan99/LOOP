import 'package:flutter/material.dart';
import 'package:loop/src/core/styles/app_colors.dart';

class SignupInputFieldWidget extends StatefulWidget {
  final String label;
  final String placeholder;
  final bool isPasswordField;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const SignupInputFieldWidget({
    super.key,
    required this.label,
    required this.placeholder,
    this.isPasswordField = false,
    this.controller,
    this.validator,
  });

  @override
  State<SignupInputFieldWidget> createState() => _SignupInputFieldWidgetState();
}

class _SignupInputFieldWidgetState extends State<SignupInputFieldWidget> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPasswordField;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.surfaceVariant,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: widget.placeholder,
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.isPasswordField)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Text(
                      _obscureText ? '보기' : '숨기기',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
