import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';

class DispatchScreen extends StatefulWidget {
  const DispatchScreen({super.key});

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : AppColors.lightBg2,
      body: Column(
        children: [
          // ── Hero + tabs ───────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF162233), Color(0xFF001A6E), Color(0xFF003EAA)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_rounded,
                            color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Dispatch Queue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.saffron.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '6 Pending',
                            style: TextStyle(
                              color: AppColors.saffronLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tab,
                    indicatorColor: AppColors.saffron,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Pending'),
                      Tab(text: 'In Transit'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tab content ────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _DispatchList(
                    items: _pending, isDark: isDark, showAction: true),
                _DispatchList(items: _inTransit, isDark: isDark),
                _DispatchList(items: _completed, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _pending   = <Map<String, String>>[];
  static const _inTransit = <Map<String, String>>[];
  static const _completed = <Map<String, String>>[];
}

class _DispatchList extends StatelessWidget {
  final List<Map<String, String>> items;
  final bool isDark;
  final bool showAction;

  const _DispatchList({
    required this.items,
    required this.isDark,
    this.showAction = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 64,
                color: isDark
                    ? Colors.white24
                    : AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 14),
            Text(
              'All clear!',
              style: TextStyle(
                color:
                    isDark ? Colors.white54 : AppColors.textDarkSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _DispatchCard(
          data: items[i],
          isDark: isDark,
          showAction: showAction,
        ),
      ),
    );
  }
}

class _DispatchCard extends StatelessWidget {
  final Map<String, String> data;
  final bool isDark;
  final bool showAction;

  const _DispatchCard(
      {required this.data, required this.isDark, required this.showAction});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(data['status']!);
    final isUnassigned = data['driver'] == 'Unassigned';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['id']!,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data['destination']!,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : AppColors.textDarkSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data['status']!,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaChip(
                icon: Icons.person_rounded,
                label: data['driver']!,
                isDark: isDark,
                warn: isUnassigned,
              ),
              const SizedBox(width: 8),
              _MetaChip(
                icon: Icons.scale_rounded,
                label: data['weight']!,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _MetaChip(
                icon: Icons.access_time_rounded,
                label: data['time']!,
                isDark: isDark,
              ),
            ],
          ),
          if (showAction) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => HapticFeedback.mediumImpact(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Dispatch Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isUnassigned) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => HapticFeedback.lightImpact(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.saffron.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.saffron.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_rounded,
                                color: AppColors.saffron, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Assign Driver',
                              style: TextStyle(
                                color: AppColors.saffron,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Ready':
        return AppColors.warehouseColor;
      case 'In Transit':
        return AppColors.primary;
      case 'Delivered':
        return AppColors.success;
      default:
        return AppColors.saffron;
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool warn;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.warn = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = warn
        ? AppColors.saffron
        : (isDark ? Colors.white60 : AppColors.textDarkSecondary);
    final bg = warn
        ? AppColors.saffron.withValues(alpha: 0.1)
        : (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.primary.withValues(alpha: 0.06));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
