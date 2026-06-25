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

    final docs = [
      _Doc('Bill of Lading', 'JDL-EXP-2043', 'BL-20430', Icons.receipt_long_rounded, AppColors.primary, 'Ready'),
      _Doc('Commercial Invoice', 'JDL-EXP-2043', 'INV-8823', Icons.description_rounded, _kLogisticsColor, 'Signed'),
      _Doc('Packing List', 'JDL-EXP-2043', 'PL-2043A', Icons.list_alt_rounded, AppColors.warning, 'Draft'),
      _Doc('Certificate of Origin', 'JDL-IMP-1001', 'CO-1001', Icons.verified_rounded, AppColors.success, 'Approved'),
      _Doc('Customs Declaration', 'JDL-IMP-1001', 'CD-1001X', Icons.account_balance_rounded, AppColors.adminColor, 'Pending'),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text('Documents', style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: _kLogisticsColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload banner
            Container(
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
            const SizedBox(height: 18),
            Text('Recent Documents', style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...docs.map((d) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.2 : 0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: d.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(d.icon, color: d.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.title, style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 13)),
                        Text('${d.shipmentId}  ·  ${d.docNumber}', style: TextStyle(color: sub, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: d.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(d.status, style: TextStyle(color: d.color, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _Doc {
  final String title, shipmentId, docNumber, status;
  final IconData icon;
  final Color color;
  const _Doc(this.title, this.shipmentId, this.docNumber, this.icon, this.color, this.status);
}
