import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';

const _kLogisticsColor = Color(0xFF0D9488);

class LogisticsDocumentsScreen extends StatelessWidget {
  const LogisticsDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;
    final bg = dark ? AppColors.darkBg1 : const Color(0xFFF5F6FA);
    final card = dark ? AppColors.darkCard : Colors.white;
    final text = dark ? Colors.white : AppColors.textDark;
    final sub = dark ? AppColors.darkSubtext : AppColors.textDarkSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text('Documents', style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: _kLogisticsColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Document upload coming soon'),
                backgroundColor: _kLogisticsColor,
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload banner
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Document upload coming soon'),
                  backgroundColor: _kLogisticsColor,
                  behavior: SnackBarBehavior.floating,
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kLogisticsColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _kLogisticsColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.upload_file_rounded, color: _kLogisticsColor, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upload Documents', style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 13)),
                          Text('Tap to upload invoices, BL, certificates & more', style: TextStyle(color: sub, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Recent Documents', style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.description_outlined, color: sub, size: 40),
                    const SizedBox(height: 12),
                    Text('No documents yet', style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Upload shipping documents using the button above', style: TextStyle(color: sub, fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
