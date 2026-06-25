class PaymentMethodModel {
  final String id;
  final String type;
  final String displayName;
  final String? last4;
  final String? upiId;
  final String? bankName;
  final bool isDefault;
  final String? cardBrand;

  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.displayName,
    this.last4,
    this.upiId,
    this.bankName,
    this.isDefault = false,
    this.cardBrand,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodModel(
        id: json['id'].toString(),
        type: json['type'] as String? ?? '',
        displayName: json['display_name'] as String? ?? '',
        last4: json['last4'] as String?,
        upiId: json['upi_id'] as String?,
        bankName: json['bank_name'] as String?,
        isDefault: json['is_default'] as bool? ?? false,
        cardBrand: json['card_brand'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'display_name': displayName,
        'last4': last4,
        'upi_id': upiId,
        'bank_name': bankName,
        'is_default': isDefault,
        'card_brand': cardBrand,
      };
}

class PaymentTransactionModel {
  final String id;
  final String? shipmentId;
  final double amount;
  final String status;
  final String method;
  final String type;
  final String? reference;
  final String? description;
  final DateTime createdAt;

  const PaymentTransactionModel({
    required this.id,
    this.shipmentId,
    required this.amount,
    required this.status,
    required this.method,
    required this.type,
    this.reference,
    this.description,
    required this.createdAt,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) =>
      PaymentTransactionModel(
        id: json['id'].toString(),
        shipmentId: json['shipment_id']?.toString(),
        amount: (json['amount'] as num? ?? 0).toDouble(),
        status: json['status'] as String? ?? '',
        method: json['method'] as String? ?? '',
        type: json['type'] as String? ?? 'debit',
        reference: json['reference'] as String?,
        description: json['description'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

class WalletModel {
  final String id;
  final double balance;

  const WalletModel({required this.id, required this.balance});

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        id: json['id'].toString(),
        balance: (json['balance'] as num? ?? 0).toDouble(),
      );

  WalletModel copyWith({double? balance}) =>
      WalletModel(id: id, balance: balance ?? this.balance);
}
