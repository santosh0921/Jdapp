import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/services/admin_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _search = TextEditingController();
  String _query = '';
  bool _isLoading = false;
  String? _error;

  List<Map<String, String>> _customers = [];
  List<Map<String, String>> _drivers   = [];
  List<Map<String, String>> _warehouse = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final users   = await AdminService.instance.getUsers();
      final drivers = await AdminService.instance.getDrivers();
      if (!mounted) return;
      setState(() {
        _customers = users
            .where((u) => (u['role'] as String?) != 'courier_driver')
            .map((u) => {
                  'name':   u['name']   as String? ?? '',
                  'phone':  u['phone']  as String? ?? '',
                  'orders': '${u['orders'] ?? 0}',
                  'status': (u['status'] as String? ?? 'active') == 'active' ? 'Active' : 'Inactive',
                })
            .toList();
        _drivers = drivers
            .map((d) => {
                  'name':   d['name']  as String? ?? '',
                  'phone':  d['phone'] as String? ?? '',
                  'orders': '${d['deliveries_today'] ?? 0} today',
                  'status': (d['status'] as String? ?? 'online') == 'online' ? 'Online' : 'Offline',
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : AppColors.lightBg2,
      body: Column(
        children: [
          // ── Hero ─────────────────────────────────────────────────────
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
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.group_rounded,
                            color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Users',
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
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('3,241 Total',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  // Search
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _search,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (v) => setState(() => _query = v.toLowerCase()),
                        decoration: const InputDecoration(
                          hintText: 'Search users...',
                          hintStyle: TextStyle(color: Colors.white54),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
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
                      Tab(text: 'Customers'),
                      Tab(text: 'Drivers'),
                      Tab(text: 'Warehouse'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tabs ──────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_off_rounded, size: 42, color: AppColors.error),
                            const SizedBox(height: 12),
                            Text('Load failed', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textDark)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tab,
                        children: [
                          _UserList(users: _filter(_customers), role: 'Customer', isDark: isDark),
                          _UserList(users: _filter(_drivers),   role: 'Driver',   isDark: isDark),
                          _UserList(users: _filter(_warehouse), role: 'Warehouse', isDark: isDark),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _filter(List<Map<String, String>> list) {
    if (_query.isEmpty) return list;
    return list
        .where((u) =>
            u['name']!.toLowerCase().contains(_query) ||
            u['phone']!.contains(_query))
        .toList();
  }

}

class _UserList extends StatelessWidget {
  final List<Map<String, String>> users;
  final String role;
  final bool isDark;

  const _UserList(
      {required this.users, required this.role, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56,
                color: isDark
                    ? Colors.white24
                    : AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('No users found',
                style: TextStyle(
                    color: isDark
                        ? Colors.white54
                        : AppColors.textDarkSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: users.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _UserCard(data: users[i], role: role, isDark: isDark),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, String> data;
  final String role;
  final bool isDark;

  const _UserCard(
      {required this.data, required this.role, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final status = data['status']!;
    final statusColor = status == 'Active' || status == 'Online'
        ? AppColors.warehouseColor
        : status == 'Offline'
            ? AppColors.textDarkSecondary
            : AppColors.error;

    final roleColor = role == 'Driver'
        ? AppColors.saffron
        : role == 'Warehouse'
            ? AppColors.warehouseColor
            : AppColors.primary;

    final initials = data['name']!
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join();

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: TextStyle(
                  color: roleColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name']!,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  data['phone']!,
                  style: TextStyle(
                    color:
                        isDark ? Colors.white54 : AppColors.textDarkSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
              Text(
                role == 'Warehouse'
                    ? data['orders']!
                    : '${data['orders']} orders',
                style: TextStyle(
                  color: isDark ? Colors.white54 : AppColors.textDarkSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Icon(Icons.more_vert_rounded,
                color: isDark ? Colors.white38 : Colors.black26, size: 20),
          ),
        ],
      ),
    );
  }
}
