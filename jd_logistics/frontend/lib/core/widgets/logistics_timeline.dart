import 'package:flutter/material.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

/// Vertical shipment timeline.
/// Each step shows status, location, and timestamp.
class LogisticsTimeline extends StatelessWidget {
  final List<TimelineStep> steps;

  const LogisticsTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final isLast = i == steps.length - 1;
        return _TimelineRow(
            step: step, isLast: isLast, isDark: isDark);
      }).toList(),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineStep step;
  final bool isLast;
  final bool isDark;

  const _TimelineRow(
      {required this.step,
      required this.isLast,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final dotColor = step.active
        ? AppColors.primary
        : step.done
            ? AppColors.warehouseColor
            : (isDark ? AppColors.darkBorder : AppColors.skyBorder);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dot + line column
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: step.done || step.active
                      ? dotColor
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: step.done && !step.active
                    ? const Icon(Icons.check_rounded,
                        size: 10, color: Colors.white)
                    : step.active
                        ? Container(
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 44,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: step.done
                          ? [
                              AppColors.warehouseColor,
                              AppColors.warehouseColor
                                  .withValues(alpha: 0.3),
                            ]
                          : [
                              isDark ? AppColors.darkBorder : AppColors.skyBorder,
                              isDark ? AppColors.darkBorder : AppColors.skyBorder,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          color: step.active
                              ? AppColors.primary
                              : AppColors.text(context),
                          fontSize: 14,
                          fontWeight: step.active
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (step.active)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Current',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                if (step.location != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.textDarkSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          step.location!,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkSubtext
                                : AppColors.textDarkSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (step.time != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.time!,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkSubtext.withValues(alpha: 0.7)
                          : AppColors.textDarkHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TimelineStep {
  final String title;
  final String? location;
  final String? time;
  final bool done;
  final bool active;

  const TimelineStep({
    required this.title,
    this.location,
    this.time,
    this.done = false,
    this.active = false,
  });
}
