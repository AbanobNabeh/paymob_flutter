enum WalletType {
  vodafone('Vodafone Cash', '🔴'),
  orange('Orange Money', '🟠'),
  etisalat('Etisalat Cash', '🟢'),
  we('WE Pay', '🔵');

  final String label;
  final String emoji;
  const WalletType(this.label, this.emoji);
}
