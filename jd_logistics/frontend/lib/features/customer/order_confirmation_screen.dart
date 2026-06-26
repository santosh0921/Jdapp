import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/network/api_exception.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';
import 'package:jd_style_logistics/services/courier_service.dart';
import 'package:jd_style_logistics/services/payment_service.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String mode;
  final String total;
  final String pickup;
  final String drop;
  final String weight;
  final String packageType;

  const OrderConfirmationScreen({
    super.key,
    this.mode = 'road',
    this.total = '1952',
    this.pickup = '',
    this.drop = '',
    this.weight = '1',
    this.packageType = 'Parcel',
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  String _payMethod = 'upi';
  bool _placing = false;

  static const _methods = [
    _PayMethod(id: 'upi', label: 'UPI / GPay', icon: Icons.account_balance_wallet_rounded, color: AppColors.success),
    _PayMethod(id: 'card', label: 'Credit / Debit Card', icon: Icons.credit_card_rounded, color: AppColors.primary),
    _PayMethod(id: 'netbanking', label: 'Net Banking', icon: Icons.account_balance_rounded, color: AppColors.oceanColor),
    _PayMethod(id: 'cod', label: 'Cash on Delivery', icon: Icons.money_rounded, color: AppColors.warning),
    _PayMethod(id: 'wallet', label: 'JD Wallet', icon: Icons.wallet_rounded, color: AppColors.saffron),
  ];

  Color get _modeColor {
    switch (widget.mode) {
      case 'air': return AppColors.airColor;
      case 'ocean': return AppColors.oceanColor;
      default: return AppColors.roadColor;
    }
  }

  IconData get _modeIcon {
    switch (widget.mode) {
      case 'air': return Icons.flight_takeoff_rounded;
      case 'ocean': return Icons.directions_boat_rounded;
      default: return Icons.local_shipping_rounded;
    }
  }

  String get _pickupLabel =>
      widget.pickup.isNotEmpty ? widget.pickup : '12, Andheri Industrial Area, Mumbai 400053';

  String get _dropLabel =>
      widget.drop.isNotEmpty ? widget.drop : '45, Connaught Place, New Delhi 110001';

  Future<void> _placeOrder() async {
    HapticFeedback.mediumImpact();
    setState(() => _placing = true);

    String? errorMsg;
    String? realOrderId;

    try {
      final amount = double.tryParse(widget.total) ?? 1952.0;
      final weightNum = double.tryParse(widget.weight) ?? 1.0;

      // Create courier order.
      final orderData = await CourierService.instance.createOrder({
        'pickup_address': _pickupLabel,
        'delivery_address': _dropLabel,
        'package_type': widget.packageType,
        'weight': weightNum,
        'amount': amount,
        'mode': widget.mode,
        'payment_method': _payMethod,
      });

      realOrderId = orderData['id']?.toString() ??
          orderData['tracking_id']?.toString() ??
          orderData['order_id']?.toString();

      // Create and verify payment.
      final payData = await PaymentService.instance.createPaymentOrder(
        orderId: realOrderId ?? 'JD${DateTime.now().millisecondsSinceEpoch % 100000}',
        amount: amount,
        method: _payMethod,
      );
      final paymentId = payData['payment_id'] as String? ??
          payData['id']?.toString() ??
          'PAY_${DateTime.now().millisecondsSinceEpoch}';

      await PaymentService.instance.verifyPayment(
        paymentId: paymentId,
        orderId: realOrderId ?? 'JD-OC',
      );
    } catch (e) {
      errorMsg = e is ApiException ? e.message : e.toString();
    }

    if (!mounted) return;
    setState(() => _placing = false);

    if (errorMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final ordId = realOrderId ?? 'JD-${DateTime.now().millisecondsSinceEpoch % 100000}';
    context.pushReplacement(
      '/shipment/delivery-success?id=${Uri.encodeComponent(ordId)}&mode=${widget.mode}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : const Color(0xFFEAF4FF),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg2 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Confirm Order',
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(mini: true)],
      ),
      body: Column(
        children: [
          _StepBanner(current: 6, total: 6, isDark: isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order summary card
                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _modeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_modeIcon, color: _modeColor, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order Summary',
                                    style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.textDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15)),
                                Text('Review before placing',
                                    style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkSubtext
                                            : AppColors.textDarkSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _SummaryRow(
                            label: 'Route',
                            value: '${_pickupLabel.split(',').first} → ${_dropLabel.split(',').first}',
                            isDark: isDark),
                        _SummaryRow(
                            label: 'Mode',
                            value: '${widget.mode[0].toUpperCase()}${widget.mode.substring(1)} Freight',
                            isDark: isDark),
                        _SummaryRow(label: 'Weight',
                            value: '${widget.weight} kg', isDark: isDark),
                        _SummaryRow(label: 'Package Type',
                            value: widget.packageType, isDark: isDark),
                        _SummaryRow(label: 'ETA',
                            value: '2–3 business days', isDark: isDark),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount',
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textDark,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                            Text('₹${widget.total}',
                                style: TextStyle(
                                    color: _modeColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Addresses
                  _SLabel('Pickup & Delivery', isDark: isDark),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _AddressRow(
                        icon: Icons.circle,
                        iconColor: _modeColor,
                        label: 'Pickup',
                        address: _pickupLabel,
                        isDark: isDark,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                            width: 2,
                            height: 18,
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.skyBorder),
                      ),
                      _AddressRow(
                        icon: Icons.location_on_rounded,
                        iconColor: AppColors.error,
                        label: 'Delivery',
                        address: _dropLabel,
                        isDark: isDark,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Payment method
                  _SLabel('Payment Method', isDark: isDark),
                  GlassCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: _methods.map((m) => _MethodTile(
                            method: m,
                            selected: _payMethod == m.id,
                            isDark: isDark,
                            onTap: () =>
                                setState(() => _payMethod = m.id),
                          )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'By placing this order you agree to JD Logistics Terms & Conditions. Estimated delivery is subject to carrier availability.',
                          style: TextStyle(
                              color: isDark
                                  ? AppColors.darkSubtext
                                  : AppColors.textDarkSecondary,
                              fontSize: 11),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // Place Order CTA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg2 : Colors.white,
              border: Border(
                  top: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.skyBorder)),
            ),
            child: GradientButton(
              isLoading: _placing,
              label: 'Place Order — ₹${widget.total}',
              onPressed: _placing ? null : _placeOrder,
              gradient: AppColors.primaryGradient,
              height: 54,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayMethod {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  const _PayMethod(
      {required this.id,
      required this.label,
      required this.icon,
      required this.color});
}

class _MethodTile extends StatelessWidget {
  final _PayMethod method;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _MethodTile(
      {required this.method,
      required this.selected,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? method.color.withValues(alpha: isDark ? 0.12 : 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected
                    ? method.color
                    : Colors.transparent,
                width: 1.5),
          ),
          child: Row(children: [
            Icon(method.icon, color: method.color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(method.label,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: method.color, size: 18),
          ]),
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _SummaryRow(
      {required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: isDark
                        ? AppColors.darkSubtext
                        : AppColors.textDarkSecondary,
                    fontSize: 13)),
            Flexible(
              child: Text(value,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ],
        ),
      );
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final bool isDark;
  const _AddressRow(
      {required this.icon,
      required this.iconColor,
      required this.label,
      required this.address,
      required this.isDark});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    color: isDark
                        ? AppColors.darkSubtext
                        : AppColors.textDarkSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            Text(address,
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      ]);
}

class _SLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SLabel(this.text, {required this.isDark});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      );
}

class _StepBanner extends StatelessWidget {
  final int current;
  final int total;
  final bool isDark;
  const _StepBanner(
      {required this.current, required this.total, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
        color: isDark ? AppColors.darkBg2 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Text('Step $current of $total',
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkSubtext
                      : AppColors.textDarkSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: current / total,
                backgroundColor:
                    isDark ? AppColors.darkBorder : AppColors.skyBorder,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('${((current / total) * 100).round()}%',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}
