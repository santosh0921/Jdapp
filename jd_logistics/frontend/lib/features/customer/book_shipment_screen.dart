import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_app_bar.dart';
import 'package:jd_style_logistics/core/widgets/custom_button.dart';
import 'package:jd_style_logistics/core/widgets/custom_textfield.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/features/customer/courier_payment_screen.dart';

class BookShipmentScreen extends StatefulWidget {
  const BookShipmentScreen({super.key});

  @override
  State<BookShipmentScreen> createState() => _BookShipmentScreenState();
}

class _BookShipmentScreenState extends State<BookShipmentScreen>
    with TickerProviderStateMixin {
  final _pickupCtrl = TextEditingController();
  final _dropCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late final AnimationController _floatCtrl;
  late final AnimationController _routeCtrl;

  String _selectedType = 'Parcel';
  String _selectedMode = 'Road';
  String _selectedPartner = 'Delhivery';
  bool _insurance = true;

  final _types = const [
    _ShipmentType('Document', 'Files & papers', Icons.description_rounded, '₹99'),
    _ShipmentType('Parcel', 'Small packages', Icons.inventory_2_rounded, '₹149'),
    _ShipmentType('Freight', 'Bulk cargo', Icons.local_shipping_rounded, '₹799'),
    _ShipmentType('International', 'Cross-border', Icons.public_rounded, '₹3999'),
  ];

  final _modes = const [
    _Mode('Road', 'Truck network', Icons.local_shipping_rounded, AppColors.roadColor),
    _Mode('Air', 'Fast cargo', Icons.flight_takeoff_rounded, AppColors.airColor),
    _Mode('Ocean', 'Port freight', Icons.directions_boat_rounded, AppColors.oceanColor),
  ];

  final _partners = const [
    'Delhivery',
    'Blue Dart',
    'VRL Logistics',
    'DHL',
    'FedEx',
    'Maersk',
  ];

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _routeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    _floatCtrl.dispose();
    _routeCtrl.dispose();
    super.dispose();
  }

  _ShipmentType get _type =>
      _types.firstWhere((e) => e.title == _selectedType);

  _Mode get _mode => _modes.firstWhere((e) => e.title == _selectedMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: JdAppBar(
        title: 'Book Shipment',
        onBack: () => context.pop(),
      ),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;

              return AnimatedBuilder(
                animation: Listenable.merge([_floatCtrl, _routeCtrl]),
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 28 : 16,
                      16,
                      wide ? 28 : 16,
                      120,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroBanner(
                              floatValue: _floatCtrl.value,
                              routeValue: _routeCtrl.value,
                              mode: _mode,
                            ),
                            const SizedBox(height: 18),
                            const _SectionTitle(
                              title: 'Shipment Type',
                              subtitle: 'Choose your cargo category',
                            ),
                            const SizedBox(height: 12),
                            _ShipmentTypeGrid(
                              wide: wide,
                              types: _types,
                              selected: _selectedType,
                              onSelected: (value) {
                                setState(() => _selectedType = value);
                              },
                            ),
                            const SizedBox(height: 18),
                            const _SectionTitle(
                              title: 'Shipment Mode',
                              subtitle: 'Road, air or ocean freight',
                            ),
                            const SizedBox(height: 12),
                            _ModeSelector(
                              modes: _modes,
                              selected: _selectedMode,
                              onSelected: (value) {
                                setState(() => _selectedMode = value);
                              },
                            ),
                            const SizedBox(height: 18),
                            Flex(
                              direction: wide ? Axis.horizontal : Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: wide ? 3 : 0,
                                  fit: wide ? FlexFit.tight : FlexFit.loose,
                                  child: _BookingForm(
                                    pickupCtrl: _pickupCtrl,
                                    dropCtrl: _dropCtrl,
                                    weightCtrl: _weightCtrl,
                                    notesCtrl: _notesCtrl,
                                  ),
                                ),
                                SizedBox(
                                  width: wide ? 16 : 0,
                                  height: wide ? 0 : 16,
                                ),
                                Flexible(
                                  flex: wide ? 2 : 0,
                                  fit: wide ? FlexFit.tight : FlexFit.loose,
                                  child: _SummaryCard(
                                    type: _type,
                                    mode: _mode,
                                    selectedPartner: _selectedPartner,
                                    partners: _partners,
                                    insurance: _insurance,
                                    onPartnerChanged: (value) {
                                      setState(() => _selectedPartner = value);
                                    },
                                    onInsuranceChanged: (value) {
                                      setState(() => _insurance = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            GradientButton(
                              label: 'Get Quote & Book',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () {
                                _showBookingSuccess(context, _mode);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showBookingSuccess(BuildContext context, _Mode mode) {
    final rawPrice = _type.price.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(rawPrice) ?? 149.0;
    context.push(
      '/courier/payment',
      extra: CourierPaymentArgs(
        orderId: 'JD${DateTime.now().millisecondsSinceEpoch % 100000}',
        totalAmount: amount,
        fromCity: _pickupCtrl.text.isNotEmpty ? _pickupCtrl.text : 'Origin',
        toCity: _dropCtrl.text.isNotEmpty ? _dropCtrl.text : 'Destination',
        packageType: _type.title,
        partner: _selectedPartner,
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final double floatValue;
  final double routeValue;
  final _Mode mode;

  const _HeroBanner({
    required this.floatValue,
    required this.routeValue,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;
    final dark = AppColors.isDark(context);

    return GlassCard(
      borderRadius: 34,
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: SizedBox(
        height: compact ? 246 : 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HeroRoutePainter(
                  dark: dark,
                  progress: routeValue,
                  color: mode.color,
                ),
              ),
            ),
            const Positioned(
              left: 0,
              top: 0,
              child: _Pill(
                label: 'JD SMART BOOKING',
                icon: Icons.public_rounded,
              ),
            ),
            Positioned(
              left: 0,
              top: 48,
              right: compact ? 0 : 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book domestic & international shipments',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontSize: compact ? 24 : 28,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Road, air and ocean freight with verified logistics partners, insurance and live tracking.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 4,
              bottom: 6,
              child: Transform.translate(
                offset: Offset(0, math.sin(floatValue * math.pi) * -8),
                child: GlassCard(
                  width: 96,
                  height: 96,
                  borderRadius: 32,
                  padding: EdgeInsets.zero,
                  child: Icon(mode.icon, color: mode.color, size: 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentTypeGrid extends StatelessWidget {
  final bool wide;
  final List<_ShipmentType> types;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ShipmentTypeGrid({
    required this.wide,
    required this.types,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: types.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: wide ? 1.45 : 1.05,
      ),
      itemBuilder: (context, index) {
        final type = types[index];
        final selectedCard = selected == type.title;

        return GlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(15),
          color: selectedCard
              ? AppColors.saffron.withValues(
                  alpha: AppColors.isDark(context) ? 0.18 : 0.10,
                )
              : null,
          borderColor: selectedCard ? AppColors.saffron : null,
          onTap: () => onSelected(type.title),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -8,
                child: Icon(
                  type.icon,
                  size: 58,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    type.icon,
                    color: selectedCard ? AppColors.saffron : AppColors.primary,
                    size: 32,
                  ),
                  const Spacer(),
                  Text(
                    type.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    type.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From ${type.price}',
                    style: TextStyle(
                      color: selectedCard ? AppColors.saffron : AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final List<_Mode> modes;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ModeSelector({
    required this.modes,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: modes.map((mode) {
        final active = selected == mode.title;

        return SizedBox(
          width: (MediaQuery.sizeOf(context).width - 44) / 3,
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            color: active
                ? mode.color.withValues(
                    alpha: AppColors.isDark(context) ? 0.18 : 0.10,
                  )
                : null,
            borderColor: active ? mode.color : null,
            onTap: () => onSelected(mode.title),
            child: Column(
              children: [
                Icon(mode.icon, color: mode.color, size: 28),
                const SizedBox(height: 8),
                Text(
                  mode.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mode.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.subtext(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BookingForm extends StatelessWidget {
  final TextEditingController pickupCtrl;
  final TextEditingController dropCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController notesCtrl;

  const _BookingForm({
    required this.pickupCtrl,
    required this.dropCtrl,
    required this.weightCtrl,
    required this.notesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 30,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Pickup & Destination',
            subtitle: 'Add route details for smart pricing',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: pickupCtrl,
            label: 'Pickup Address',
            hint: 'Mumbai, Navi Mumbai, warehouse or office',
            prefixIcon: Icons.my_location_rounded,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: dropCtrl,
            label: 'Delivery Address',
            hint: 'Delhi, Dubai, Singapore, London...',
            prefixIcon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: weightCtrl,
            label: 'Approx Weight',
            hint: 'Example: 2 kg / 120 kg / 1 container',
            prefixIcon: Icons.scale_rounded,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: notesCtrl,
            label: 'Shipment Notes',
            hint: 'Fragile, customs info, delivery instructions',
            prefixIcon: Icons.edit_note_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _ShipmentType type;
  final _Mode mode;
  final String selectedPartner;
  final List<String> partners;
  final bool insurance;
  final ValueChanged<String> onPartnerChanged;
  final ValueChanged<bool> onInsuranceChanged;

  const _SummaryCard({
    required this.type,
    required this.mode,
    required this.selectedPartner,
    required this.partners,
    required this.insurance,
    required this.onPartnerChanged,
    required this.onInsuranceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 30,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Shipment Summary',
            subtitle: 'Estimated quote preview',
          ),
          const SizedBox(height: 18),
          Center(
            child: GlassCard(
              width: 88,
              height: 88,
              borderRadius: 28,
              padding: EdgeInsets.zero,
              child: Icon(mode.icon, color: mode.color, size: 42),
            ),
          ),
          const SizedBox(height: 18),
          _SummaryRow(label: 'Shipment Type', value: type.title),
          _SummaryRow(label: 'Shipping Mode', value: mode.title),
          _SummaryRow(label: 'Base Fare', value: type.price),
          _SummaryRow(label: 'Currency', value: 'INR / USD ready'),
          const SizedBox(height: 10),
          Text(
            'Partner Company',
            style: TextStyle(
              color: AppColors.subtext(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: partners.map((partner) {
              final active = partner == selectedPartner;
              return ChoiceChip(
                label: Text(partner),
                selected: active,
                onSelected: (_) => onPartnerChanged(partner),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: insurance,
            onChanged: onInsuranceChanged,
            title: Text(
              'Shipment Insurance',
              style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              'Protect declared value and damage risk',
              style: TextStyle(
                color: AppColors.subtext(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(color: AppColors.border(context), height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Estimated Total',
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                type.price,
                style: TextStyle(
                  color: mode.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SecureNote(mode: mode),
        ],
      ),
    );
  }
}

class _SecureNote extends StatelessWidget {
  final _Mode mode;

  const _SecureNote({required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mode.color.withValues(
          alpha: AppColors.isDark(context) ? 0.14 : 0.09,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: mode.color.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: mode.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'KYC, partner verification, insurance and tracking will be checked before dispatch.',
              style: TextStyle(
                color: AppColors.subtext(context),
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.subtext(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w900,
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.subtext(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Pill({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.portOrange.withValues(alpha: dark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppColors.portOrange.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public_rounded, color: AppColors.portOrange, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: dark ? AppColors.saffronLight : const Color(0xFFC2410C),
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroRoutePainter extends CustomPainter {
  final bool dark;
  final double progress;
  final Color color;

  _HeroRoutePainter({
    required this.dark,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (dark ? AppColors.routeBlue : AppColors.routeLine)
          .withValues(alpha: dark ? 0.30 : 0.34)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * .14, size.height * .72)
      ..quadraticBezierTo(
        size.width * .46,
        size.height * .10,
        size.width * .86,
        size.height * .54,
      );

    canvas.drawPath(path, paint);

    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * progress);

    if (tangent != null) {
      canvas.drawCircle(tangent.position, 5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroRoutePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.dark != dark ||
        oldDelegate.color != color;
  }
}

class _ShipmentType {
  final String title;
  final String subtitle;
  final IconData icon;
  final String price;

  const _ShipmentType(this.title, this.subtitle, this.icon, this.price);
}

class _Mode {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _Mode(this.title, this.subtitle, this.icon, this.color);
}