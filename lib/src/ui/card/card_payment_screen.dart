import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paymob_flutter/paymob_flutter.dart';
import 'package:paymob_flutter/src/services/paymob_service.dart';

class CardPaymentScreen extends StatefulWidget {
  final PaymobConfig config;
  final PaymobOrder order;
  final BillingData billing;
  final void Function(PaymentResult) onResult;

  const CardPaymentScreen({
    super.key,
    required this.config,
    required this.order,
    required this.billing,
    required this.onResult,
  });

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCvv = true;
  String _cardType = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  void _detectCardType(String value) {
    final clean = value.replaceAll(' ', '');
    String type = '';
    if (clean.startsWith('4')) {
      type = 'visa';
    } else if (RegExp(r'^5[1-5]').hasMatch(clean)) {
      type = 'mastercard';
    } else if (RegExp(r'^3[47]').hasMatch(clean)) {
      type = 'amex';
    }
    setState(() => _cardType = type);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = PaymobService(widget.config);
      final paymentKey = await service.getCardPaymentToken(
        order: widget.order,
        billing: widget.billing,
      );

      final result = await service.payWithCard(
        paymentKey: paymentKey,
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardHolderName: _cardHolderController.text,
        expiryMonth: _expiryController.text.split('/')[0],
        expiryYear: _expiryController.text.split('/')[1],
        cvv: _cvvController.text,
      );

      widget.onResult(result);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      widget.onResult(PaymentResult.failed(e.toString()));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () {
            widget.onResult(PaymentResult.cancelled());
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Card Payment',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardPreview(
                    cardNumber: _cardNumberController.text,
                    cardHolder: _cardHolderController.text,
                    expiry: _expiryController.text,
                    cardType: _cardType,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  _AmountBadge(order: widget.order, isDark: isDark),
                  const SizedBox(height: 28),
                  _buildLabel('Card Number', isDark),
                  const SizedBox(height: 8),
                  _buildCardNumberField(isDark),
                  const SizedBox(height: 20),
                  _buildLabel('Card Holder Name', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _cardHolderController,
                    hint: 'John Doe',
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Expiry Date', isDark),
                            const SizedBox(height: 8),
                            _buildExpiryField(isDark),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('CVV', isDark),
                            const SizedBox(height: 8),
                            _buildCvvField(isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _PayButton(
                    isLoading: _isLoading,
                    amount: widget.order.amount,
                    currency: widget.order.currency,
                    onTap: _isLoading ? null : _pay,
                  ),
                  const SizedBox(height: 24),
                  const _SecurityNote(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.black54,
          letterSpacing: 0.3,
        ),
      );

  Widget _buildCardNumberField(bool isDark) {
    return _buildTextField(
      controller: _cardNumberController,
      hint: '0000 0000 0000 0000',
      icon: Icons.credit_card_rounded,
      isDark: isDark,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CardNumberFormatter(),
      ],
      maxLength: 19,
      onChanged: _detectCardType,
      validator: (v) {
        final clean = v?.replaceAll(' ', '') ?? '';
        if (clean.length < 16) return 'Invalid card number';
        return null;
      },
    );
  }

  Widget _buildExpiryField(bool isDark) {
    return _buildTextField(
      controller: _expiryController,
      hint: 'MM/YY',
      icon: Icons.calendar_today_outlined,
      isDark: isDark,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ExpiryFormatter(),
      ],
      maxLength: 5,
      validator: (v) {
        if (v == null || v.length < 5) return 'Invalid';
        final parts = v.split('/');
        final month = int.tryParse(parts[0]) ?? 0;
        if (month < 1 || month > 12) return 'Invalid month';
        return null;
      },
    );
  }

  Widget _buildCvvField(bool isDark) {
    return TextFormField(
      controller: _cvvController,
      obscureText: _obscureCvv,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 16,
        letterSpacing: 4,
      ),
      decoration: _inputDecoration(
        hint: '•••',
        icon: Icons.lock_outline_rounded,
        isDark: isDark,
        suffix: IconButton(
          icon: Icon(
            _obscureCvv
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          onPressed: () => setState(() => _obscureCvv = !_obscureCvv),
        ),
      ),
      validator: (v) {
        if (v == null || v.length < 3) return 'Invalid CVV';
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
      decoration: _inputDecoration(hint: hint, icon: icon, isDark: isDark),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white24 : Colors.black26,
        fontSize: 15,
      ),
      prefixIcon:
          Icon(icon, size: 20, color: isDark ? Colors.white38 : Colors.black38),
      suffixIcon: suffix,
      counterText: '',
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _CardPreview extends StatelessWidget {
  final String cardNumber;
  final String cardHolder;
  final String expiry;
  final String cardType;
  final bool isDark;

  const _CardPreview({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiry,
    required this.cardType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.amber.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              if (cardType == 'visa')
                const Text('VISA',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        fontStyle: FontStyle.italic))
              else if (cardType == 'mastercard')
                Row(children: [
                  Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: Colors.red.shade400, shape: BoxShape.circle)),
                  Transform.translate(
                    offset: const Offset(-8, 0),
                    child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                            color:
                                Colors.orange.shade400.withValues(alpha: 0.8),
                            shape: BoxShape.circle)),
                  ),
                ]),
            ],
          ),
          const Spacer(),
          Text(
            cardNumber.isEmpty ? '•••• •••• •••• ••••' : cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CARD HOLDER',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                          letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(
                    cardHolder.isEmpty ? 'YOUR NAME' : cardHolder.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EXPIRES',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                          letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(
                    expiry.isEmpty ? 'MM/YY' : expiry,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountBadge extends StatelessWidget {
  final PaymobOrder order;
  final bool isDark;

  const _AmountBadge({required this.order, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: Color(0xFF6C63FF), size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Amount',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45)),
              Text(
                '${order.amount} ${order.currency}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  final bool isLoading;
  final double amount;
  final String currency;
  final VoidCallback? onTap;

  const _PayButton({
    required this.isLoading,
    required this.amount,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Pay $amount $currency',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 14, color: Colors.green.shade400),
        const SizedBox(width: 6),
        Text(
          'Secured by Paymob · 256-bit SSL',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 4 ? digits.substring(0, 4) : digits;
    String formatted;
    if (limited.length >= 3) {
      formatted = '${limited.substring(0, 2)}/${limited.substring(2)}';
    } else {
      formatted = limited;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
