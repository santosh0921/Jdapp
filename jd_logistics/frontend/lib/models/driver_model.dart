class DriverModel {
  final String id;
  final String userId;
  final bool isOnline;
  final bool isVerified;
  final double rating;
  final int totalDeliveries;
  final double totalEarnings;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? licenseNumber;
  final double? currentLat;
  final double? currentLng;

  const DriverModel({
    required this.id,
    required this.userId,
    this.isOnline = false,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.totalEarnings = 0.0,
    this.vehicleType,
    this.vehicleNumber,
    this.licenseNumber,
    this.currentLat,
    this.currentLng,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        id: json['id'].toString(),
        userId: json['user_id'].toString(),
        isOnline: json['is_online'] as bool? ?? false,
        isVerified: json['is_verified'] as bool? ?? false,
        rating: (json['rating'] as num? ?? 0).toDouble(),
        totalDeliveries: json['total_deliveries'] as int? ?? 0,
        totalEarnings: (json['total_earnings'] as num? ?? 0).toDouble(),
        vehicleType: json['vehicle_type'] as String?,
        vehicleNumber: json['vehicle_number'] as String?,
        licenseNumber: json['license_number'] as String?,
        currentLat: json['current_lat'] != null
            ? (json['current_lat'] as num).toDouble()
            : null,
        currentLng: json['current_lng'] != null
            ? (json['current_lng'] as num).toDouble()
            : null,
      );

  DriverModel copyWith({bool? isOnline}) => DriverModel(
        id: id,
        userId: userId,
        isOnline: isOnline ?? this.isOnline,
        isVerified: isVerified,
        rating: rating,
        totalDeliveries: totalDeliveries,
        totalEarnings: totalEarnings,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
        licenseNumber: licenseNumber,
        currentLat: currentLat,
        currentLng: currentLng,
      );
}

class EarningModel {
  final String id;
  final String? shipmentId;
  final double amount;
  final String type;
  final String? description;
  final DateTime createdAt;

  const EarningModel({
    required this.id,
    this.shipmentId,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) => EarningModel(
        id: json['id'].toString(),
        shipmentId: json['shipment_id']?.toString(),
        amount: (json['amount'] as num? ?? 0).toDouble(),
        type: json['type'] as String? ?? 'debit',
        description: json['description'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
