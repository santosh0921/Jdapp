import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/services/payment_service.dart';
import 'package:provider/provider.dart';

// Push this screen with:
//   context.push('/courier/payment', extra: CourierPaymentArgs(...))

class CourierPaymentArgs {
  final String orderId;
  final double totalAmount;
  final String fromCity;
  final String toCity;
  final String packageType;
  final String partner;

  const CourierPaymentArgs({
    required this.orderId,
    required this.totalAmount,
    required this.fromCity,
    required this.toCity,
    required this.packageType,
    required this.partner,
  });
}

class CourierPaymentScreen extends StatefulWidget {
  final CourierPaymentArgs args;
  const CourierPaymentScreen({super.key, required this.args});

  @override
  State<CourierPaymentScreen> createState() => _CourierPaymentScreenState();
}

class _CourierPaymentScreenState extends State<CourierPaymentScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMethod = 0;
  bool _paying = false;
  bool _paymentDone = false;

  late final AnimationController _successCtrl;
  late final Animation<double> _scaleAnim;

  final _upiCtrl = TextEditingController();

  static const _methods = [
    {'label': 'UPI',         'icon': Icons.account_balance_wallet_rounded, 'sub': 'Pay via any UPI app'},
    {'label': 'Card',        'icon': Icons.credit_card_rounded,            'sub': 'Credit / Debit card'},
    {'label': 'Net Banking', 'icon': Icons.account_balance_rounded,        'sub': 'All major banks'},
    {'label': 'JD Wallet',   'icon': Icons.wallet_rounded,                 'sub': 'Balance: ₹2,480'},
    {'label': 'OBC Points',  'icon': Icons.stars_rounded,                  'sub': '1,240 pts = ₹124'},
    {'label': 'COD',         'icon': Icons.payments_rounded,               'sub': 'Cash on delivery'},
  ];

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      final order = await PaymentService.instance.createPaymentOrder(
        orderId: widget.args.orderId,
        amount: widget.args.totalAmount,
        method: _methods[_selectedMethod]['label'] as String,
      );
      await PaymentService.instance.verifyPayment(
        paymentId: order['payment_id'] as String? ?? 'PAY_DEMO',
        orderId: widget.args.orderId,
      );
    } catch (_) {}
    if (!mounted) return;
    setState(() { _paying = false; _paymentDone = true; });
    _successCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg1 : AppColors.lightBg2,
      appBar: AppBar(
        backgroundColor: dark ? AppColors.darkBg2 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Pay for Courier',
            style: TextStyle(
                color: dark ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
      body: _paymentDone ? _buildSuccess(dark) : _buildForm(dark),
      bottomNavigationBar: _paymentDone ? null : _buildPayBar(dark),
    );
  }

  Widget _buildForm(bool dark) {
    final args = widget.args;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF003EAA), Color(0xFF001A6E)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping_rounded,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(args.orderId,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const Spacer(),
                    Text(args.partner,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(args.fromCity,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: Colors.white54, size: 14),
                    ),
                    Text(args.toCity,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(args.packageType,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount',
                        style: TextStyle(color: Colors.white60, fontSize: 13)),
                    Text('₹${args.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('Choose Payment Method',
              style: TextStyle(
                  color: dark ? Colors.white : AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...List.generate(_methods.length, (i) {
            final m = _methods[i];
            final selected = _selectedMethod == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedMethod = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : (dark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : (dark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.grey.withValues(alpha: 0.15)),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(m['icon'] as IconData,
                        color: selected
                            ? AppColors.primary
                            : (dark ? Colors.white54 : AppColors.textDarkSecondary),
                        size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['label'] as String,
                              style: TextStyle(
                                  color: dark ? Colors.white : AppColors.textDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          Text(m['sub'] as String,
                              style: TextStyle(
                                  color: dark
                                      ? Colors.white54
                                      : AppColors.textDarkSecondary,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    if (selected)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 13),
                      ),
                  ],
                ),
              ),
            );
          }),
          if (_selectedMethod == 0) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _upiCtrl,
              style: TextStyle(
                  color: dark ? Colors.white : AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Enter UPI ID (e.g. name@upi)',
                hintStyle: TextStyle(
                    color: dark ? Colors.white38 : Colors.black38),
                filled: true,
                fillColor:
                    dark ? AppColors.darkCard : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.alternate_email_rounded,
                    size: 18),
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPayBar(bool dark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkBg2 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total',
                  style: TextStyle(
                      color: dark ? Colors.white54 : AppColors.textDarkSecondary,
                      fontSize: 12)),
              Text(
                '₹${widget.args.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: _paying ? null : _pay,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _paying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      'Pay via ${_methods[_selectedMethod]['label']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(bool dark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 60),
              ),
            ),
            const SizedBox(height: 24),
            Text('Booking Confirmed!',
                style: TextStyle(
                    color: dark ? Colors.white : AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              '${widget.args.fromCity} → ${widget.args.toCity}\n${widget.args.partner} · ${widget.args.orderId}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: dark ? Colors.white54 : AppColors.textDarkSecondary,
                  fontSize: 14),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/customer/home'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Back to Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go('/customer/track'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: AppColors.primary),
              ),
              icon: const Icon(Icons.route_rounded, color: AppColors.primary),
              label: const Text('Track Shipment',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
