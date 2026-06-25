import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/custom_textfield.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  static const _country = _CountryData(
    countryCode: 'IN',
    countryName: 'India',
    flag: '🇮🇳',
    dialCode: '+91',
    region: 'South Asia',
    currency: 'INR',
    language: 'English / Hindi',
  );

  static const _faqs = [
    _Faq(
      category: 'Tracking',
      q: 'How do I track my shipment?',
      a:
          'Go to the Track tab and enter your tracking ID to see real-time logistics movement, ETA and delivery status.',
    ),
    _Faq(
      category: 'International',
      q: 'Do you support international shipments?',
      a:
          'Yes. JD Logistics supports domestic and international shipment flows with customs and region-wise tracking.',
    ),
    _Faq(
      category: 'Payments',
      q: 'What payment methods are accepted?',
      a:
          'We accept UPI, Credit/Debit Cards, Net Banking, Wallet and Cash on Delivery where available.',
    ),
    _Faq(
      category: 'Orders',
      q: 'How do I cancel a booking?',
      a:
          'You can cancel eligible bookings from My Orders before pickup or within the allowed cancellation window.',
    ),
    _Faq(
      category: 'Claims',
      q: 'What if my parcel is damaged?',
      a:
          'Raise a support claim from order details. Our team will review shipment images, invoice and delivery report.',
    ),
  ];

  static const _tickets = [
    _TicketData(
      id: 'TKT-JD-2048',
      shipmentId: 'JD-IND-2048',
      title: 'Delivery ETA clarification',
      status: 'In Progress',
      priority: 'Medium',
      team: 'Delivery Desk',
      date: 'Today',
      color: Color(0xFF2563EB),
      icon: Icons.local_shipping_rounded,
    ),
    _TicketData(
      id: 'TKT-JD-9172',
      shipmentId: 'JD-EXP-9172',
      title: 'Customs document review',
      status: 'Open',
      priority: 'High',
      team: 'Customs Team',
      date: '42 min ago',
      color: Color(0xFFFF8A00),
      icon: Icons.flight_takeoff_rounded,
    ),
    _TicketData(
      id: 'TKT-JD-8841',
      shipmentId: 'JD-DLV-8841',
      title: 'Invoice copy request',
      status: 'Resolved',
      priority: 'Low',
      team: 'Billing Desk',
      date: 'Yesterday',
      color: Color(0xFF16A34A),
      icon: Icons.receipt_long_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: palette.text,
        title: Text(
          'Help & Support',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: palette.text,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _SupportBackground(motion: _motion)),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 28 : 16,
                    16,
                    wide ? 28 : 16,
                    110,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SupportHero(country: _country, motion: _motion),
                          const SizedBox(height: 18),
                          _SupportStatsGrid(wide: wide),
                          const SizedBox(height: 18),
                          _ContactGrid(wide: wide),
                          const SizedBox(height: 18),
                          const _FaqCategories(),
                          const SizedBox(height: 18),
                          _ClayCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(
                                  title: 'Recent Support Tickets',
                                  subtitle:
                                      'Track open cases, customs queries and shipment support',
                                ),
                                const SizedBox(height: 14),
                                ..._tickets.map(
                                  (ticket) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _TicketTile(ticket: ticket),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _ClayCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(
                                  title: 'Frequently Asked Questions',
                                  subtitle:
                                      'Shipment, payment, customs and delivery help',
                                ),
                                const SizedBox(height: 12),
                                ..._faqs.map((faq) => _FaqTile(faq: faq)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _ClayCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(
                                  title: 'Send a Message',
                                  subtitle:
                                      'Tell us your shipment issue and support priority',
                                ),
                                const SizedBox(height: 14),
                                const CustomTextField(
                                  hint: 'Shipment ID / Invoice ID',
                                  prefixIcon: Icons.qr_code_rounded,
                                ),
                                const SizedBox(height: 12),
                                const CustomTextField(
                                  hint: 'Category: Shipment, Customs, Payment',
                                  prefixIcon: Icons.category_rounded,
                                ),
                                const SizedBox(height: 12),
                                const CustomTextField(
                                  hint: 'Priority: Low, Medium, High',
                                  prefixIcon: Icons.priority_high_rounded,
                                ),
                                const SizedBox(height: 12),
                                const CustomTextField(
                                  hint: 'Describe your issue...',
                                  maxLines: 4,
                                  prefixIcon: Icons.message_rounded,
                                ),
                                const SizedBox(height: 16),
                                GradientButton(
                                  label: 'Submit Support Request',
                                  onPressed: () {},
                                  colors: AppColors.primaryGradient,
                                  icon: Icons.send_rounded,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportHero extends StatelessWidget {
  final _CountryData country;
  final Animation<double> motion;

  const _SupportHero({
    required this.country,
    required this.motion,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return _ClayCard(
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        height: 235,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _WorldMapPainter())),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: motion,
                builder: (_, __) {
                  return CustomPaint(
                    painter: _HeroRoutePainter(value: motion.value),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              top: 4,
              right: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Pill(
                    label: 'JD GLOBAL SUPPORT HUB',
                    icon: Icons.support_agent_rounded,
                    color: Color(0xFFFF8A00),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Need help with your shipment?',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: palette.text,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Domestic • International • Customs • Payments',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.subText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniPill(
                        label: '${country.flag} ${country.countryName}',
                        color: const Color(0xFF2563EB),
                      ),
                      _MiniPill(
                        label: country.region,
                        color: const Color(0xFFFF8A00),
                      ),
                      _MiniPill(
                        label: country.currency,
                        color: const Color(0xFF16A34A),
                      ),
                      const _MiniPill(
                        label: 'Priority Desk',
                        color: Color(0xFF0EA5E9),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 8,
              child: AnimatedBuilder(
                animation: motion,
                builder: (_, __) {
                  return _HeroVisual(value: motion.value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  final double value;

  const _HeroVisual({required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: palette.highlight,
            offset: const Offset(-7, -7),
            blurRadius: 14,
          ),
          BoxShadow(
            color: palette.shadow,
            offset: const Offset(7, 7),
            blurRadius: 16,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.public_rounded,
            color: const Color(0xFF2563EB).withValues(alpha: 0.14),
            size: 90,
          ),
          Transform.translate(
            offset: Offset(math.sin(value * math.pi * 2) * 12, -28),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              color: Color(0xFFFF8A00),
              size: 24,
            ),
          ),
          Transform.translate(
            offset: Offset(math.cos(value * math.pi * 2) * 13, 24),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Color(0xFF2563EB),
              size: 27,
            ),
          ),
          Transform.translate(
            offset: Offset(0, math.sin(value * math.pi * 2) * 5),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFFFF8A00),
              size: 43,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportStatsGrid extends StatelessWidget {
  final bool wide;

  const _SupportStatsGrid({required this.wide});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: wide ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: wide ? 1.5 : 1.12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _SummaryCard(
          icon: Icons.confirmation_number_rounded,
          label: 'Open Tickets',
          value: '02',
          color: Color(0xFF2563EB),
        ),
        _SummaryCard(
          icon: Icons.verified_rounded,
          label: 'Resolved',
          value: '18',
          color: Color(0xFF16A34A),
        ),
        _SummaryCard(
          icon: Icons.schedule_rounded,
          label: 'Avg Resolve',
          value: '4h',
          color: Color(0xFFFF8A00),
        ),
        _SummaryCard(
          icon: Icons.public_rounded,
          label: 'Intl Cases',
          value: '05',
          color: Color(0xFF0EA5E9),
        ),
        _SummaryCard(
          icon: Icons.flight_takeoff_rounded,
          label: 'Customs',
          value: '03',
          color: Color(0xFFEA580C),
        ),
        _SummaryCard(
          icon: Icons.local_shipping_rounded,
          label: 'Delivery',
          value: '09',
          color: Color(0xFF2563EB),
        ),
        _SummaryCard(
          icon: Icons.payments_rounded,
          label: 'Payments',
          value: '04',
          color: Color(0xFF16A34A),
        ),
        _SummaryCard(
          icon: Icons.inventory_2_rounded,
          label: 'Claims',
          value: '01',
          color: Color(0xFFEF4444),
        ),
      ],
    );
  }
}

class _ContactGrid extends StatelessWidget {
  final bool wide;

  const _ContactGrid({required this.wide});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: wide ? 3 : 1,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: wide ? 1.55 : 3.25,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _ContactOption(
          icon: Icons.chat_bubble_rounded,
          label: 'Live Chat',
          subtitle: 'Connect with support',
          color: AppColors.success,
        ),
        _ContactOption(
          icon: Icons.call_rounded,
          label: 'Call Us',
          subtitle: 'Speak to logistics desk',
          color: AppColors.primary,
        ),
        _ContactOption(
          icon: Icons.email_rounded,
          label: 'Email',
          subtitle: 'Raise detailed ticket',
          color: AppColors.accent,
        ),
        _ContactOption(
          icon: Icons.phone_in_talk_rounded,
          label: 'WhatsApp Support',
          subtitle: 'Fast shipment help',
          color: Color(0xFF16A34A),
        ),
        _ContactOption(
          icon: Icons.confirmation_number_rounded,
          label: 'Ticket Center',
          subtitle: 'Track support cases',
          color: Color(0xFF2563EB),
        ),
        _ContactOption(
          icon: Icons.emergency_rounded,
          label: 'Emergency Desk',
          subtitle: 'Urgent logistics issue',
          color: Color(0xFFEF4444),
        ),
      ],
    );
  }
}

class _FaqCategories extends StatelessWidget {
  const _FaqCategories();

  @override
  Widget build(BuildContext context) {
    return const _ClayCard(
      padding: EdgeInsets.all(14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MiniPill(label: 'Shipment', color: Color(0xFF2563EB)),
          _MiniPill(label: 'Tracking', color: Color(0xFFFF8A00)),
          _MiniPill(label: 'Customs', color: Color(0xFF16A34A)),
          _MiniPill(label: 'Payments', color: Color(0xFF0EA5E9)),
          _MiniPill(label: 'Claims', color: Color(0xFFEF4444)),
          _MiniPill(label: 'International', color: Color(0xFFEA580C)),
        ],
      ),
    );
  }
}

class _ContactOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _ContactOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  State<_ContactOption> createState() => _ContactOptionState();
}

class _ContactOptionState extends State<_ContactOption> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {},
        child: AnimatedScale(
          scale: _down ? 0.96 : (_hover ? 1.025 : 1),
          duration: const Duration(milliseconds: 150),
          child: _ClayCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _Sticker(icon: widget.icon, color: widget.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.subText,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: palette.subText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  final _TicketData ticket;

  const _TicketTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: palette.highlight,
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: palette.shadow,
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          _Sticker(icon: ticket.icon, color: ticket.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ticket.id} • ${ticket.shipmentId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.subText,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniPill(label: ticket.status, color: ticket.color),
                    _MiniPill(
                      label: ticket.priority,
                      color: const Color(0xFFFF8A00),
                    ),
                    _MiniPill(
                      label: ticket.team,
                      color: const Color(0xFF2563EB),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            ticket.date,
            style: TextStyle(
              color: palette.subText,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _Faq faq;

  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: palette.highlight,
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: palette.shadow,
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: const Color(0xFF2563EB),
          collapsedIconColor: palette.subText,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniPill(label: faq.category, color: const Color(0xFF2563EB)),
              const SizedBox(height: 8),
              Text(
                faq.q,
                style: TextStyle(
                  color: palette.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          children: [
            Text(
              faq.a,
              style: TextStyle(
                color: palette.subText,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return _ClayCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Sticker(icon: icon, color: color),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: palette.text,
              fontWeight: FontWeight.w900,
              fontSize: 21,
            ),
          ),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.subText,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: palette.text,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.subText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ClayCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: palette.highlight,
            offset: const Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: palette.shadow,
            offset: const Offset(8, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Sticker extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _Sticker({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ClayPalette.of(context);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: palette.highlight,
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: palette.shadow,
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Pill({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _SupportBackground extends StatelessWidget {
  final Animation<double> motion;

  const _SupportBackground({required this.motion});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (_, __) {
        return CustomPaint(painter: _BackgroundPainter(value: motion.value));
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double value;

  _BackgroundPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.08)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final saffron = Paint()
      ..color = const Color(0xFFFF8A00).withValues(alpha: 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final nodes = [
      Offset(size.width * .08, size.height * .16),
      Offset(size.width * .46, size.height * .08),
      Offset(size.width * .88, size.height * .22),
      Offset(size.width * .18, size.height * .58),
      Offset(size.width * .72, size.height * .68),
      Offset(size.width * .38, size.height * .88),
    ];

    for (var i = 0; i < nodes.length - 1; i++) {
      final start = nodes[i];
      final control = Offset(size.width * .52, nodes[i].dy - 42);
      final end = nodes[i + 1];

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

      canvas.drawPath(path, i.isEven ? blue : saffron);

      final moving = _quadraticPoint(start, control, end, (value + i * .17) % 1);

      canvas.drawCircle(
        moving,
        4,
        Paint()
          ..color = i.isEven
              ? const Color(0xFF2563EB).withValues(alpha: 0.70)
              : const Color(0xFFFF8A00).withValues(alpha: 0.70),
      );
    }

    for (final node in nodes) {
      canvas.drawCircle(
        node,
        5,
        Paint()..color = const Color(0xFF2563EB).withValues(alpha: 0.10),
      );
      canvas.drawCircle(
        node,
        13,
        Paint()..color = const Color(0xFFFF8A00).withValues(alpha: 0.045),
      );
    }
  }

  Offset _quadraticPoint(Offset a, Offset b, Offset c, double t) {
    final x = math.pow(1 - t, 2) * a.dx +
        2 * (1 - t) * t * b.dx +
        math.pow(t, 2) * c.dx;
    final y = math.pow(1 - t, 2) * a.dy +
        2 * (1 - t) * t * b.dy +
        math.pow(t, 2) * c.dy;

    return Offset(x.toDouble(), y.toDouble());
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

class _HeroRoutePainter extends CustomPainter {
  final double value;

  _HeroRoutePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final route = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.20)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final start = Offset(size.width * .15, size.height * .74);
    final control = Offset(size.width * .48, size.height * .10);
    final end = Offset(size.width * .86, size.height * .52);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    canvas.drawPath(path, route);

    final moving = _quadraticPoint(start, control, end, value);

    canvas.drawCircle(
      Offset(size.width * .25, size.height * .60),
      5,
      Paint()..color = const Color(0xFF2563EB),
    );
    canvas.drawCircle(
      Offset(size.width * .72, size.height * .43),
      5,
      Paint()..color = const Color(0xFFFF8A00),
    );
    canvas.drawCircle(
      moving,
      5,
      Paint()..color = const Color(0xFFFF8A00),
    );
  }

  Offset _quadraticPoint(Offset a, Offset b, Offset c, double t) {
    final x = math.pow(1 - t, 2) * a.dx +
        2 * (1 - t) * t * b.dx +
        math.pow(t, 2) * c.dx;
    final y = math.pow(1 - t, 2) * a.dy +
        2 * (1 - t) * t * b.dy +
        math.pow(t, 2) * c.dy;

    return Offset(x.toDouble(), y.toDouble());
  }

  @override
  bool shouldRepaint(covariant _HeroRoutePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

class _WorldMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.045)
      ..style = PaintingStyle.fill;

    final shapes = [
      Rect.fromLTWH(size.width * .08, size.height * .20, 70, 34),
      Rect.fromLTWH(size.width * .22, size.height * .34, 90, 40),
      Rect.fromLTWH(size.width * .45, size.height * .16, 110, 48),
      Rect.fromLTWH(size.width * .65, size.height * .38, 130, 52),
      Rect.fromLTWH(size.width * .36, size.height * .62, 100, 38),
    ];

    for (final rect in shapes) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(24)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter oldDelegate) => false;
}

class _ClayPalette {
  final Color background;
  final Color card;
  final Color highlight;
  final Color shadow;
  final Color text;
  final Color subText;

  const _ClayPalette({
    required this.background,
    required this.card,
    required this.highlight,
    required this.shadow,
    required this.text,
    required this.subText,
  });

  static _ClayPalette of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    if (dark) {
      return const _ClayPalette(
        background: AppColors.darkBg1,
        card: AppColors.darkCard,
        highlight: AppColors.clayHighlightDark,
        shadow: AppColors.clayShadowDark,
        text: Colors.white,
        subText: AppColors.darkSubtext,
      );
    }

    return const _ClayPalette(
      background: Color(0xFFEAF4FF),
      card: Color(0xFFF8FBFF),
      highlight: Color(0xFFFFFFFF),
      shadow: Color(0xFFBDD2EA),
      text: Color(0xFF0F172A),
      subText: Color(0xFF64748B),
    );
  }
}

class _CountryData {
  final String countryCode;
  final String countryName;
  final String flag;
  final String dialCode;
  final String region;
  final String currency;
  final String language;

  const _CountryData({
    required this.countryCode,
    required this.countryName,
    required this.flag,
    required this.dialCode,
    required this.region,
    required this.currency,
    required this.language,
  });
}

class _TicketData {
  final String id;
  final String shipmentId;
  final String title;
  final String status;
  final String priority;
  final String team;
  final String date;
  final Color color;
  final IconData icon;

  const _TicketData({
    required this.id,
    required this.shipmentId,
    required this.title,
    required this.status,
    required this.priority,
    required this.team,
    required this.date,
    required this.color,
    required this.icon,
  });
}

class _Faq {
  final String category;
  final String q;
  final String a;

  const _Faq({
    required this.category,
    required this.q,
    required this.a,
  });
}