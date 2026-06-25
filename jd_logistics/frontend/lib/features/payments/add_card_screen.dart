import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/custom_text_field.dart';
import 'package:jd_style_logistics/core/widgets/glass_card.dart';
import 'package:jd_style_logistics/core/widgets/gradient_background.dart';
import 'package:jd_style_logistics/core/widgets/gradient_button.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});
  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _saveCard = true;
  bool _loading = false;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardHolderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCard() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // TODO: call PaymentProvider.addCard(...)
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _loading = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Add Card', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.primaryGradient), borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.credit_card_rounded, color: Colors.white, size: 32),
                        const Spacer(),
                        Text(
                          _cardNumberCtrl.text.isEmpty ? '•••• •••• •••• ••••' : _cardNumberCtrl.text,
                          style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Row(children: [
                          Text(_cardHolderCtrl.text.isEmpty ? 'CARDHOLDER NAME' : _cardHolderCtrl.text.toUpperCase(),
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const Spacer(),
                          Text(_expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ]),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _cardNumberCtrl,
                    label: 'Card Number',
                    hint: '1234 5678 9012 3456',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                    onChanged: (_) => setState(() {}),
                    validator: (v) => (v?.length ?? 0) < 16 ? 'Enter valid card number' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _cardHolderCtrl,
                    label: 'Cardholder Name',
                    hint: 'As printed on card',
                    onChanged: (_) => setState(() {}),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: CustomTextField(
                      controller: _expiryCtrl,
                      label: 'Expiry (MM/YY)',
                      hint: '12/27',
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(5)],
                      onChanged: (_) => setState(() {}),
                      validator: (v) => (v?.length ?? 0) < 5 ? 'Invalid' : null,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(
                      controller: _cvvCtrl,
                      label: 'CVV',
                      hint: '•••',
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                      validator: (v) => (v?.length ?? 0) < 3 ? 'Invalid' : null,
                    )),
                  ]),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SwitchListTile(
                      value: _saveCard,
                      onChanged: (v) => setState(() => _saveCard = v),
                      title: const Text('Save card for future payments', style: TextStyle(color: Colors.white, fontSize: 14)),
                      activeThumbColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    onPressed: _addCard,
                    gradient: AppColors.primaryGradient,
                    isLoading: _loading,
                    child: const Text('Add Card'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
