import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paymob_flutter/paymob_flutter.dart';
import 'package:paymob_flutter/src/services/paymob_service.dart';

class WalletPaymentScreen extends StatefulWidget {
  final PaymobConfig config;
  final PaymobOrder order;
  final BillingData billing;
  final void Function(PaymentResult) onResult;

  const WalletPaymentScreen({
    super.key,
    required this.config,
    required this.order,
    required this.billing,
    required this.onResult,
  });

  @override
  State<WalletPaymentScreen> createState() => _WalletPaymentScreenState();
}

class _WalletPaymentScreenState extends State<WalletPaymentScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  WalletType? _selectedWallet;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _walletData = {
    WalletType.vodafone: _WalletStyle(
      gradient: [Color(0xFFE60000), Color(0xFFFF4444)],
      icon: '📱',
      description: 'ادفع بـ Vodafone Cash',
    ),
    WalletType.orange: _WalletStyle(
      gradient: [Color(0xFFFF6600), Color(0xFFFFAA00)],
      icon: '🟠',
      description: 'ادفع بـ Orange Money',
    ),
    WalletType.etisalat: _WalletStyle(
      gradient: [Color(0xFF00A850), Color(0xFF00D467)],
      icon: '💚',
      description: 'ادفع بـ Etisalat Cash',
    ),
    WalletType.we: _WalletStyle(
      gradient: [Color(0xFF0066CC), Color(0xFF0099FF)],
      icon: '🔵',
      description: 'ادفع بـ WE Pay',
    ),
  };

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
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWallet == null) {
      _showError('Please select a wallet provider');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final service = PaymobService(widget.config);
      final response = await service.initiateWalletPayment(
        order: widget.order,
        billing: widget.billing,
        phoneNumber: _phoneController.text,
        walletType: _selectedWallet!,
      );

      final redirectUrl = response['redirect_url'] as String?;
      final transactionId = response['id']?.toString();

      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        widget.onResult(PaymentResult.pending(transactionId ?? ''));
      } else {
        final success = response['success'] == true;
        if (success) {
          widget.onResult(
              PaymentResult.success(transactionId ?? '', raw: response));
        } else {
          widget.onResult(PaymentResult.failed(
              response['data']?['message'] ?? 'Payment failed'));
        }
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      widget.onResult(PaymentResult.failed(e.toString()));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
          'Wallet Payment',
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
                  _AmountBadge(order: widget.order, isDark: isDark),
                  const SizedBox(height: 28),
                  _buildLabel('Choose Wallet', isDark),
                  const SizedBox(height: 12),
                  _buildWalletGrid(isDark),
                  const SizedBox(height: 28),
                  _buildLabel('Wallet Phone Number', isDark),
                  const SizedBox(height: 8),
                  _buildPhoneField(isDark),
                  const SizedBox(height: 12),
                  _buildInfoNote(isDark),
                  const SizedBox(height: 40),
                  _PayButton(
                    isLoading: _isLoading,
                    selectedWallet: _selectedWallet,
                    amount: widget.order.amount,
                    currency: widget.order.currency,
                    walletData: _walletData,
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

  Widget _buildWalletGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: WalletType.values.map((wallet) {
        final style = _walletData[wallet]!;
        final isSelected = _selectedWallet == wallet;
        return _WalletCard(
          wallet: wallet,
          style: style,
          isSelected: isSelected,
          isDark: isDark,
          onTap: () => setState(() => _selectedWallet = wallet),
        );
      }).toList(),
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 16,
        letterSpacing: 1.5,
      ),
      decoration: InputDecoration(
        hintText: '01xxxxxxxxx',
        hintStyle: TextStyle(
          color: isDark ? Colors.white24 : Colors.black26,
          fontSize: 15,
          letterSpacing: 1,
        ),
        prefixIcon: Icon(Icons.phone_android_rounded,
            size: 20, color: isDark ? Colors.white38 : Colors.black38),
        prefixText: '+20  ',
        prefixStyle: TextStyle(
          color: isDark ? Colors.white60 : Colors.black54,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
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
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _selectedWallet != null
                ? _walletData[_selectedWallet]!.gradient[0]
                : const Color(0xFF6C63FF),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Phone number is required';
        if (v.length < 10) return 'Invalid phone number';
        return null;
      },
    );
  }

  Widget _buildInfoNote(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You\'ll receive an OTP on your wallet phone to confirm the payment.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.amber.shade200 : Colors.amber.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final WalletType wallet;
  final _WalletStyle style;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _WalletCard({
    required this.wallet,
    required this.style,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isSelected ? LinearGradient(colors: style.gradient) : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white10 : Colors.black12),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: style.gradient[0].withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(style.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              wallet.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 14),
            ],
          ],
        ),
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
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
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
  final WalletType? selectedWallet;
  final double amount;
  final String currency;
  final Map<WalletType, _WalletStyle> walletData;
  final VoidCallback? onTap;

  const _PayButton({
    required this.isLoading,
    required this.selectedWallet,
    required this.amount,
    required this.currency,
    required this.walletData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = selectedWallet != null ? walletData[selectedWallet] : null;
    final colors =
        style?.gradient ?? [const Color(0xFF6C63FF), const Color(0xFF3B82F6)];

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    const Icon(Icons.phone_android_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      selectedWallet != null
                          ? 'Pay $amount $currency via ${selectedWallet!.label}'
                          : 'Pay $amount $currency',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
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

class _WalletStyle {
  final List<Color> gradient;
  final String icon;
  final String description;

  const _WalletStyle({
    required this.gradient,
    required this.icon,
    required this.description,
  });
}
