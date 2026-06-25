class ShipmentModel {
  final String id;
  final String trackingId;
  final String status;
  final String pickupAddress;
  final String deliveryAddress;
  final String packageType;
  final double weight;
  final double amount;
  final String? driverId;
  final String? warehouseId;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final String? notes;

  const ShipmentModel({
    required this.id,
    required this.trackingId,
    required this.status,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.packageType,
    required this.weight,
    required this.amount,
    this.driverId,
    this.warehouseId,
    required this.createdAt,
    this.estimatedDelivery,
    this.deliveredAt,
    this.notes,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) => ShipmentModel(
        id: json['id'].toString(),
        trackingId: json['tracking_id'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        pickupAddress: json['pickup_address'] as String? ?? '',
        deliveryAddress: json['delivery_address'] as String? ?? '',
        packageType: json['package_type'] as String? ?? '',
        weight: (json['weight'] as num? ?? 0).toDouble(),
        amount: (json['amount'] as num? ?? 0).toDouble(),
        driverId: json['driver_id']?.toString(),
        warehouseId: json['warehouse_id']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
        estimatedDelivery: json['estimated_delivery'] != null
            ? DateTime.tryParse(json['estimated_delivery'] as String)
            : null,
        deliveredAt: json['delivered_at'] != null
            ? DateTime.tryParse(json['delivered_at'] as String)
            : null,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tracking_id': trackingId,
        'status': status,
        'pickup_address': pickupAddress,
        'delivery_address': deliveryAddress,
        'package_type': packageType,
        'weight': weight,
        'amount': amount,
        'driver_id': driverId,
        'warehouse_id': warehouseId,
        'created_at': createdAt.toIso8601String(),
        'notes': notes,
      };
}

class TrackingEventModel {
  final String id;
  final String status;
  final String location;
  final String? note;
  final DateTime createdAt;

  const TrackingEventModel({
    required this.id,
    required this.status,
    required this.location,
    this.note,
    required this.createdAt,
  });

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) =>
      TrackingEventModel(
        id: json['id'].toString(),
        status: json['status'] as String? ?? '',
        location: json['location'] as String? ?? '',
        note: json['note'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
