import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  String? tripID;
  String? driverId;

  LatLng? pickUpLatLng;
  String? pickUpAddress;

  LatLng? dropOffLatLng;
  String? dropOffAddress;

  String? userName;
  String? userPhone;

  TripDetails({
    this.tripID,
    this.driverId,
    this.pickUpLatLng,
    this.pickUpAddress,
    this.dropOffLatLng,
    this.dropOffAddress,
    this.userName,
    this.userPhone,
  });

  // Method to create TripDetails from a map
  factory TripDetails.fromMap(Map<String, dynamic> map) {
    return TripDetails(
      tripID: map['tripID'],
      driverId: map['driverID'],

      pickUpLatLng: LatLng(
        double.parse(map['pickUpLatLng']['latitude']),
        double.parse(map['pickUpLatLng']['longitude']),
      ),
      pickUpAddress: map['pickUpAddress'],

      dropOffLatLng: LatLng(
        double.parse(map['dropOffLatLng']['latitude']),
        double.parse(map['dropOffLatLng']['longitude']),
      ),
      dropOffAddress: map['dropOffAddress'],
      userName: map['userName'],
      userPhone: map['userPhone'],
    );
  }
}
