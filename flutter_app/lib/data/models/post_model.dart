import '../../core/constants/api_constants.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final LocationData location;
  final String status;
  final int views;
  final int favorites;
  final DateTime createdAt;
  final double? distance; // in kilometers
  final CreatorData createdBy;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.location,
    required this.status,
    required this.views,
    required this.favorites,
    required this.createdAt,
    this.distance,
    required this.createdBy,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      category: json['category'] ?? '',
      location: LocationData.fromJson(json['location'] ?? {}),
      status: json['status'] ?? 'active',
      views: json['views'] ?? 0,
      favorites: json['favorites'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      distance: json['distance']?.toDouble(),
      createdBy: CreatorData.fromJson(json['createdBy'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'location': location.toJson(),
      'status': status,
      'views': views,
      'favorites': favorites,
      'createdAt': createdAt.toIso8601String(),
      'distance': distance,
      'createdBy': createdBy.toJson(),
    };
  }

  String get thumbnail {
    if (images.isEmpty) return '';
    final imagePath = images.first;
    // If already a full URL, return as is
    if (imagePath.startsWith('http')) return imagePath;
    // Build full URL from relative path
    if (imagePath.startsWith('/')) {
      // Use the base URL from ApiConstants
      return '${ApiConstants.baseUrlNoApi}$imagePath';
    }
    // If path doesn't start with /, assume it's already a full path
    return imagePath;
  }
  
  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toInt()}m away';
    }
    return '${distance!.toStringAsFixed(1)} km away';
  }
}

class LocationData {
  final String type;
  final List<double> coordinates; // [longitude, latitude]
  final String address;

  LocationData({
    required this.type,
    required this.coordinates,
    required this.address,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [0.0, 0.0],
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      'address': address,
    };
  }

  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;
  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
}

class CreatorData {
  final String id;
  final String name;
  final String? location;

  CreatorData({
    required this.id,
    required this.name,
    this.location,
  });

  factory CreatorData.fromJson(Map<String, dynamic> json) {
    return CreatorData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'location': location,
    };
  }
}

