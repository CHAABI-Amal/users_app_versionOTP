
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String userPhone = "";
String userID = FirebaseAuth.instance.currentUser!.uid;
StreamSubscription<Position>? positionStreamHomePage;
StreamSubscription<Position>? positionStreamNewTripPage;

Position? userCurrentPosition;
String googleMapKey = "AIzaSyCw0p-ZDOS_uTLfvQ9DvwAgQwGHxBrozz8";

//String serverKeyFCM = "key=";

const CameraPosition googlePlexInitioalPosition = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);


String userPhoto = "";
String userEmail = "";

