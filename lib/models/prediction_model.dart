class PredictionModel {
  final String displayName;
  final String placeId;
  final double latitude;
  final double longitude;
  final String country; // Add this field

  PredictionModel({
    required this.displayName,
    required this.placeId,
    required this.latitude,
    required this.longitude,
    required this.country, // Update constructor
  });

  // Factory method for creating a PredictionModel from Nominatim JSON
  factory PredictionModel.fromJsonNominatim(Map<String, dynamic> json) {
    return PredictionModel(
      displayName: json['display_name'] ?? '',
      placeId: json['osm_id'].toString(),
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
      country: json['address']['country'] ?? '', // Parse country
    );
  }

  // Method to get the main part of the address
  String get mainText {
    List<String> parts = displayName.split(',');
    return parts.isNotEmpty ? parts[0] : displayName;
  }

  // Method to get the secondary part of the address
  String get secondaryText {
    List<String> parts = displayName.split(',');
    return parts.length > 1 ? parts[1].trim() : '';
  }
}
