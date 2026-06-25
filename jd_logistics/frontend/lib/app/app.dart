import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jd_style_logistics/app/app_router.dart';
import 'package:jd_style_logistics/app/app_theme.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

class JdStyleLogisticsApp extends StatelessWidget {
  const JdStyleLogisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'JD Style Logistics',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}