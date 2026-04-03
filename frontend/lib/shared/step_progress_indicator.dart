import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep; // 0-indexed
  final int totalSteps;
  final List<String> labels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.labels = const ['Phone', 'Details', 'Platform'],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isActive = index == currentStep;

        return Row(
          children: [
            // Dot
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isActive ? 32 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? AppTheme.primary
                        : const Color(0xFF2A2A4A),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  index < labels.length ? labels[index] : '',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isCompleted || isActive
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            // Connector line
            if (index < totalSteps - 1)
              Container(
                width: 40,
                height: 2,
                margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
                color: isCompleted
                    ? AppTheme.primary
                    : const Color(0xFF2A2A4A),
              ),
          ],
        );
      }),
    );
  }
}
