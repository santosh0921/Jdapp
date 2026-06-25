import 'package:flutter/material.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';

/// Country flag emoji + name badge for international shipments.
class CountryBadge extends StatelessWidget {
  final String country;
  final String? flag;
  final String? currency;
  final bool small;

  const CountryBadge({
    super.key,
    required this.country,
    this.flag,
    this.currency,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final flagEmoji = flag ?? _countryFlag(country);
    final fs = small ? 11.0 : 13.0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 7 : 10, vertical: small ? 3 : 5),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBg3
            : AppColors.skyBorder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.skyBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flagEmoji, style: TextStyle(fontSize: fs + 1)),
          SizedBox(width: small ? 4 : 5),
          Text(
            currency != null ? '$country · $currency' : country,
            style: TextStyle(
              color: isDark ? AppColors.darkSubtext : AppColors.textDark,
              fontSize: fs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static String _countryFlag(String country) {
    const flags = {
      'India': '🇮🇳',
      'UAE': '🇦🇪',
      'USA': '🇺🇸',
      'UK': '🇬🇧',
      'Singapore': '🇸🇬',
      'Russia': '🇷🇺',
      'Europe': '🇪🇺',
      'Japan': '🇯🇵',
      'Australia': '🇦🇺',
      'Canada': '🇨🇦',
      'Germany': '🇩🇪',
      'France': '🇫🇷',
      'China': '🇨🇳',
    };
    return flags[country] ?? '🌍';
  }
}
