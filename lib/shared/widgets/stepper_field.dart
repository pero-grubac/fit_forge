import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepBtn(
          icon: Icons.remove,
          onTap: value > min
              ? () => onChanged((value - step).clamp(min, max))
              : null,
        ),
        Container(
          width: 56,
          alignment: Alignment.center,
          child: Text(
            value == value.truncateToDouble()
                ? '${value.toInt()} kg'
                : '${value.toStringAsFixed(1)} kg',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text1),
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          onTap: value < max
              ? () => onChanged((value + step).clamp(min, max))
              : null,
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.bg3 : AppColors.bg4,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.border2),
        ),
        child: Icon(icon,
            size: 16, color: onTap != null ? AppColors.text2 : AppColors.text3),
      ),
    );
  }
}

class StepperField extends StatelessWidget {
  const StepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.text2)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg3,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.border2),
          ),
          child: Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.remove, size: 18, color: AppColors.text2),
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Text('$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text1)),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18, color: AppColors.text2),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
