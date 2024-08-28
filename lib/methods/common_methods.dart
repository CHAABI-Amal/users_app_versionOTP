import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:users_app/appinfo/app_info.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/models/address_model.dart';

import '../models/direction_details.dart';
import '../models/online_nearby_drivers.dart';
import 'manage_driveres_methods.dart';

class CommonMethods {
  BitmapDescriptor? carIconNearbyDriver;
  Set<Marker> driverMarkers = {};
  Set<Marker> markerSet ={};
  Set<Circle> circleSet ={};

  Future<void> checkConnectivity(BuildContext context) async
  {
    var connectionResult = await Connectivity().checkConnectivity();
    if (connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      displaySnackBar("Your Internet is not available. Check your connection. Try again.", context);
    }
  }

  void displaySnackBar(String messageText, BuildContext context)
  {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<dynamic> sendRequestToAPI(String apiUrl) async
  {
    try {
      http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }

  /// Reverse Geocoding
  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(Position position, BuildContext context) async
  {
    String humanReadableAddress = "";
    String apiGeoCodingUrl = "https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&addressdetails=1";

    var responseFromAPI = await sendRequestToAPI(apiGeoCodingUrl);

    if (responseFromAPI != "error") {
      if (responseFromAPI["address"] != null) {
        var address = responseFromAPI["address"];
        String town = address["town"] ?? "";
        String city = address["city"] ?? "";
        String stateDistrict = address["state_district"] ?? "";
        String country = address["country"] ?? "";

        // Combine address components into a human-readable format
        List<String> addressParts = [town, city, stateDistrict];
        humanReadableAddress = addressParts.where((element) => element.isNotEmpty).join(", ");

        // Optionally, remove non-Latin characters
        humanReadableAddress = humanReadableAddress.replaceAll(RegExp(r'[^\x00-\x7F]'), '');

        AddressModel model = AddressModel();
        model.humanReadableAdress = humanReadableAddress;
        model.longitudePosition = position.longitude;
        model.latitudePosition = position.latitude;

        Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(model);
      } else {
        print("No address found for the given coordinates.");
        humanReadableAddress = "Unknown address";
      }
    } else {
      print("Error fetching the address from the API.");
      humanReadableAddress = "Error fetching address";
    }

    return humanReadableAddress;
  }

  ///Directions API ? null checker
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(LatLng source, LatLng destination) async
  {
    String urlDirectionsAPI = "https://router.project-osrm.org/route/v1/driving/${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=polyline&alternatives=true&steps=true";

    var responseFromDirectionAPI = await sendRequestToAPI(urlDirectionsAPI);
    if(responseFromDirectionAPI == "error") {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();

    detailsModel.distanceTextString = (responseFromDirectionAPI["routes"][0]["distance"] / 1000).toStringAsFixed(2) + " km";
    detailsModel.distanceValueDigits = responseFromDirectionAPI["routes"][0]["distance"].toInt();

    detailsModel.durationTextString = (responseFromDirectionAPI["routes"][0]["duration"] / 60).toStringAsFixed(0) + " mins";
    detailsModel.durationValueDigits = responseFromDirectionAPI["routes"][0]["duration"].toInt();

    detailsModel.encodedPoints = responseFromDirectionAPI["routes"][0]["geometry"];

    return detailsModel;
  }


  double calculateFareAmount(DirectionDetails directionDetails) {
    double distancePerKmAmount = 0.4;
    double durationPerMinuteAmount = 0.3;
    double baseFareAmount = 2;

    double totalDistanceFareAmount = (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    double totalDurationSpendFareAmount = (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

    double overAllTotalFareAmount = baseFareAmount + totalDistanceFareAmount + totalDurationSpendFareAmount;

    // Round to one decimal place
    double fareAmount = double.parse(overAllTotalFareAmount.toStringAsFixed(1)); // 12.4567 -> 12.5

    // Apply 50% discount
    ///fareAmount = fareAmount * 0.5;

    // Remove any decimal part, leaving only the integer
    fareAmount = fareAmount.floorToDouble();

    return fareAmount;
  }



/*
  calculateFareAmount(DirectionDetails directionDetails)
  {
    double distancePerKmAmount =0.4;
    double durationPerMinuteAmount=0.3;
    double baseFareAmount =2;


    double totalDistanceFareAmount = (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    double totalDurationSpendFareAmount =(directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;


    double overAllTotalFareAmount = baseFareAmount + totalDistanceFareAmount + totalDurationSpendFareAmount;

    return overAllTotalFareAmount.toStringAsFixed(1);//12.4567 -> 12.5
  }



 */
  updateAvailableNearbyOnlineDriversOnMap()
  {


    Set<Marker> markersTempSet = Set<Marker>();
    print("Number of drivers in the list: ${ManageDriversMethods.nearbyOnlineDriversList.length}");

    for (OnlineNearbyDrivers eachOnlineNearbyDriver in ManageDriversMethods.nearbyOnlineDriversList) {
      LatLng driverCurrentPosition = LatLng(eachOnlineNearbyDriver.latDriver!, eachOnlineNearbyDriver.lngDriver!);
      print("i m in the louuuuuuuuuuuuuuuuuuuuuuuuuuuuuupppppppppppppp: ${ManageDriversMethods.nearbyOnlineDriversList.length}");

      Marker driverMarker = Marker(
        markerId: MarkerId("driver ID = " + eachOnlineNearbyDriver.uidDriver.toString()),
        position: driverCurrentPosition,
        icon: carIconNearbyDriver!,
      );

      markersTempSet.add(driverMarker);
    }


  }


  void turnOnLocationUpdatesHomePage() {
    print("*****************************ana fi common methods *****************************************************************************************************PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPppppp");

    // Resume the position stream
    positionStreamHomePage!.resume();

    // Set the location using Geofire
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      userCurrentPosition!.latitude,
      userCurrentPosition!.longitude,
    );

    // Update the nearby online drivers on the map
    updateAvailableNearbyOnlineDriversOnMap();
  }



}