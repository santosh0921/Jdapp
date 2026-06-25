class WarehouseModel {
  final String id;
  final String? name;
  final String? address;
  final String? city;
  final int capacity;
  final bool isActive;

  const WarehouseModel({
    required this.id,
    this.name,
    this.address,
    this.city,
    this.capacity = 0,
    this.isActive = true,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) => WarehouseModel(
        id: json['id'].toString(),
        name: json['name'] as String?,
        address: json['address'] as String?,
        city: json['city'] as String?,
        capacity: json['capacity'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );
}

class ParcelModel {
  final String id;
  final String trackingId;
  final String status;
  final String? location;
  final double weight;
  final String? packageType;
  final DateTime createdAt;
  final DateTime? dispatchedAt;

  const ParcelModel({
    required this.id,
    required this.trackingId,
    required this.status,
    this.location,
    this.weight = 0.0,
    this.packageType,
    required this.createdAt,
    this.dispatchedAt,
  });

  factory ParcelModel.fromJson(Map<String, dynamic> json) => ParcelModel(
        id: json['id'].toString(),
        trackingId: json['tracking_id'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        location: json['location'] as String?,
        weight: (json['weight'] as num? ?? 0).toDouble(),
        packageType: json['package_type'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
        dispatchedAt: json['dispatched_at'] != null
            ? DateTime.tryParse(json['dispatched_at'] as String)
            : null,
      );
}
