/// Egyptian mobile-wallet providers supported by Paymob.
enum WalletType {
  /// Vodafone Cash
  vodafone('Vodafone Cash', '🔴'),

  /// Orange Money
  orange('Orange Money', '🟠'),

  /// Etisalat Cash
  etisalat('Etisalat Cash', '🟢'),

  /// WE Pay
  we('WE Pay', '🔵');

  /// Human-readable label shown in the UI.
  final String label;

  /// Emoji icon used alongside the label.
  final String emoji;

  const WalletType(this.label, this.emoji);
}
