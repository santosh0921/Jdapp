import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/network/api_exception.dart';
import 'package:jd_style_logistics/providers/theme_provider.dart';
import 'package:jd_style_logistics/services/courier_service.dart';
import 'package:jd_style_logistics/services/payment_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Push this screen with:
//   context.push('/courier/payment', extra: CourierPaymentArgs(...))

class CourierPaymentArgs {
  final String orderId;
  final double totalAmount;
  final String fromCity;
  final String toCity;
  final String packageType;
  final String partner;
  final String mode;
  final String weight;
  final bool withInsurance;
  final String notes;

  const CourierPaymentArgs({
    required this.orderId,
    required this.totalAmount,
    required this.fromCity,
    required this.toCity,
    required this.packageType,
    required this.partner,
    this.mode = 'road',
    this.weight = '1 kg',
    this.withInsurance = false,
    this.notes = '',
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

  final _upiCtrl = TextEditingController();

  static const _methods = [
    {'label': 'UPI',         'icon': Icons.account_balance_wallet_rounded, 'sub': 'Pay via any UPI app'},
    {'label': 'Card',        'icon': Icons.credit_card_rounded,            'sub': 'Credit / Debit card'},
    {'label': 'Net Banking', 'icon': Icons.account_balance_rounded,        'sub': 'All major banks'},
    {'label': 'JD Wallet',   'icon': Icons.wallet_rounded,                 'sub': 'Instant — no OTP needed'},
    {'label': 'OBC Points',  'icon': Icons.stars_rounded,                  'sub': 'Redeem loyalty points'},
    {'label': 'COD',         'icon': Icons.payments_rounded,               'sub': 'Cash on delivery'},
  ];

  @override
  void dispose() {
    _upiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _paying = true);
    String? errorMsg;
    String? realOrderId;

    try {
      final weightNum = double.tryParse(
              widget.args.weight.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          1.0;
      final method = _methods[_selectedMethod]['label'] as String;

      // Step 1 — Create the courier order on the backend.
      final orderData = await CourierService.instance.createOrder({
        'pickup_address': widget.args.fromCity,
        'delivery_address': widget.args.toCity,
        'package_type': widget.args.packageType,
        'weight': weightNum,
        'amount': widget.args.totalAmount,
        'mode': widget.args.mode,
        'partner': widget.args.partner,
        'insurance': widget.args.withInsurance,
        'payment_method': method,
        if (widget.args.notes.isNotEmpty) 'notes': widget.args.notes,
      });

      realOrderId = orderData['id']?.toString() ??
          orderData['tracking_id']?.toString() ??
          orderData['order_id']?.toString();

      // Step 2 — Handle payment by method.
      switch (_selectedMethod) {
        case 0: // UPI
          await _launchUpi(widget.args.totalAmount, realOrderId ?? widget.args.orderId);
          break;

        case 3: // JD Wallet — deduct via /payments/withdraw
          final wallet = await PaymentService.instance.getWallet();
          if (wallet.balance < widget.args.totalAmount) {
            throw Exception('Insufficient wallet balance. Available: ₹${wallet.balance.toStringAsFixed(0)}');
          }
          await PaymentService.instance.withdraw(widget.args.totalAmount);
          break;

        case 5: // COD — no payment step needed
          break;

        default:
          // Card / Net Banking / OBC — not yet supported without payment gateway
          throw Exception('$method payment not yet available. Please use UPI, JD Wallet, or Cash on Delivery.');
      }
    } catch (e) {
      errorMsg = e is ApiException ? e.message : e.toString();
    }

    if (!mounted) return;
    setState(() => _paying = false);

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

    final ordId = realOrderId ?? widget.args.orderId;
    context.pushReplacement(
      '/shipment/delivery-success?id=${Uri.encodeComponent(ordId)}&mode=${widget.args.mode}',
    );
  }

  Future<void> _launchUpi(double amount, String orderId) async {
    final amountStr = amount.toStringAsFixed(2);
    final note = Uri.encodeComponent('JD Logistics - Order $orderId');
    // Try app-specific schemes first, then fall back to generic upi://
    final schemes = [
      'gpay://upi/pay?pa=jdlogistics@okaxis&pn=JD%20Logistics&am=$amountStr&cu=INR&tn=$note',
      'phonepe://pay?pa=jdlogistics@ybl&pn=JD%20Logistics&am=$amountStr&cu=INR&tn=$note',
      'paytmmp://pay?pa=jdlogistics@paytm&pn=JD%20Logistics&am=$amountStr&cu=INR&tn=$note',
      'upi://pay?pa=jdlogistics@okaxis&pn=JD%20Logistics&am=$amountStr&cu=INR&tn=$note',
    ];

    bool launched = false;
    for (final scheme in schemes) {
      final uri = Uri.parse(scheme);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        launched = true;
        break;
      }
    }

    if (!launched) {
      throw Exception('No UPI app found. Please install GPay, PhonePe, or Paytm and try again.');
    }
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
      body: _buildForm(dark),
      bottomNavigationBar: _buildPayBar(dark),
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
                    Expanded(
                      child: Text(args.fromCity,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: Colors.white54, size: 14),
                    ),
                    Expanded(
                      child: Text(args.toCity,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                    const SizedBox(width: 8),
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
}
