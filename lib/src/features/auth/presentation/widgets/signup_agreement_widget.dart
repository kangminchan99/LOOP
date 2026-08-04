import 'package:flutter/material.dart';
import 'package:loop/src/core/styles/app_colors.dart';

class SignupAgreementWidget extends StatefulWidget {
  final ValueChanged<bool> onChanged;
  final bool initialValue;

  const SignupAgreementWidget({
    super.key,
    required this.onChanged,
    this.initialValue = false,
  });

  @override
  State<SignupAgreementWidget> createState() => _SignupAgreementWidgetState();
}

class _SignupAgreementWidgetState extends State<SignupAgreementWidget> {
  late bool _isAgreed;

  @override
  void initState() {
    super.initState();
    _isAgreed = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isAgreed = !_isAgreed;
        });
        widget.onChanged(_isAgreed);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: _isAgreed ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: _isAgreed ? AppColors.primary : theme.dividerColor,
                  width: 2,
                ),
              ),
              child:
                  _isAgreed
                      ? const Center(
                        child: Text(
                          '✓',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'loop 이용약관과 개인정보 처리방침에 동의합니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
