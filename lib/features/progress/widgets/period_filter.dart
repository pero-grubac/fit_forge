import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:flutter/material.dart';

class PeriodFilter extends StatelessWidget {
  const PeriodFilter(
      {super.key, required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      (label: '1 mj', days: 30),
      (label: '3 mj', days: 90),
      (label: '6 mj', days: 180),
      (label: context.l10n.progress_period_all, days: 9999),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Row(
        children: options.map((opt) {
          final active = selected == opt.days;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(opt.days),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : AppColors.bg3,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active ? AppColors.accent : AppColors.border2),
                ),
                child: Text(opt.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: active ? Colors.white : AppColors.text2)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
