import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/global/trip_var.dart';
import 'package:users_app/methods/manage_driveres_methods.dart';
import 'package:users_app/methods/push_notification_service.dart';
import 'package:users_app/models/direction_details.dart';
import 'package:users_app/models/online_nearby_drivers.dart';
import 'package:users_app/pages/profile_page.dart';
import 'package:users_app/pages/redeem_coupon.dart';
import 'package:users_app/pages/refer_earn.dart';
import 'package:users_app/pages/safety.dart';
import 'package:users_app/pages/search_destination_page.dart';
import 'package:users_app/pages/select_nearst_active_driver_screen.dart';
import 'package:users_app/pages/settings.dart';
import 'package:users_app/pages/trips_history_page.dart';
import 'package:users_app/widgets/info_dialog.dart';
import 'package:users_app/widgets/payment_dialog.dart';

import '../appinfo/app_info.dart';
import '../authenfication/login_screen.dart';
import '../global/trip_var.dart';
import '../methods/common_methods.dart';
import '../models/prediction_model.dart';
import '../models/trip_details.dart';
import '../widgets/loading_dialog.dart';
import 'dart:async';

import 'about_page.dart';
class HomePage extends StatefulWidget {
  final TripDetails? newTripDetailsInfo;
  HomePage({super.key,this.newTripDetailsInfo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Completer<GoogleMapController> googleMapCompleterController = Completer<
      GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  DirectionDetails? tripdirectionDetailsInfo;
  List<PredictionModel> predictionList = [];
  Marker? currentLocationMarker;
  List<LatLng> polylineCoOrdinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet ={};
  Set<Circle> circleSet ={};
  bool isDrawerOpened = true;
  String stateOfApp = "normal";
  bool nearbyOnlineDriverKeysLoaded = false;
  BitmapDescriptor? carIconNearbyDriver;
  Set<Marker> driverMarkers = {};
  DatabaseReference? tripRequestRef;
  List<OnlineNearbyDrivers>? availableNearbyOnlineDriverList;

  StreamSubscription<DatabaseEvent>? tripsStreamSubscription;
  bool requestingDirectionDetailsInfo = false;
  String? imageUrl;

  ///*****************************************************************************************************************************

  makeDriverNearbyCarIcon()
  {
    if(carIconNearbyDriver == null)
    {
      ImageConfiguration configuration = createLocalImageConfiguration(context, size: Size(0.7, 0.7));

      BitmapDescriptor.fromAssetImage(configuration, "assets/images/tracking.png").then((iconImage)
      {
        carIconNearbyDriver = iconImage;

      });
    }
  }

  //themeeeeeeeeeeeeeeeeeeeeeeee
  void updateMapTheme(GoogleMapController controller)
  {
    //which theme brit ndiro : dark retro ............ knpassi value l set fhad controller
    getJsonFileFromThemes("themes/standard_style.json").then((value) =>
        setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async
  {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer.asUint8List(
        byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller)
  {
    controller.setMapStyle(googleMapStyle);
  }

  //local locationnnnnn of user
  getCurrentLiveLocationOfUser() async
  {
    // Get current location
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    currentPositionOfUser = positionOfUser;
    userCurrentPosition = currentPositionOfUser;
    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition = CameraPosition(
        target: positionOfUserInLatLng, zoom: 13);

    controllerGoogleMap!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition));

    // Update the marker
    setState(() {
      currentLocationMarker = Marker(
        markerId: MarkerId('current_location'),
        position: positionOfUserInLatLng,
        infoWindow: InfoWindow(
          title: 'Current Location',
          snippet: 'You are here',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Optional: Change marker color
      );
    });

    // No need to call addMarker here

    await CommonMethods.convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
        currentPositionOfUser!, context);

    await getUserInfoAndCheckBlockStatus();

    await initializeGeoFireListener();

  }

  getUserInfoAndCheckBlockStatus() async
  {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) // if user directory exists
          {
        if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
            userPhoto= (snap.snapshot.value as Map)["photo"];
            print("${userPhoto} HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHPPPPPPPPPPPPPPPPPPPPPPPPPPPP");
          });
        }
        else //force to go to login screen
            {
          FirebaseAuth.instance.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => LoginScreen()));
          cMethods.displaySnackBar(
              "You are blocked. Contact admin: admin@gmail.com", context);
        }
      }
      else // directory does not exist
          {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }


  displayUserRideDetailsContainer() async
  {
    //draw route between pickup and dropoff

    ///Direcrtions Api
    await retrieveDirectionDetails();

    setState(() {
      searchContainerHeight = 0;
      bottomMapPadding = 240;
      rideDetailsContainerHeight = 242;
      isDrawerOpened = false;
    });
  }


  retrieveDirectionDetails() async
  {
    var pickUpLocation= Provider.of<AppInfo>(context,listen:false).pickUpLocation;
    var dropOffDestinationLocation= Provider.of<AppInfo>(context,listen:false).dropOffLocation;

    var pickUpGeoGraphicCoOrdinates =LatLng(pickUpLocation!.latitudePosition!, pickUpLocation!.longitudePosition!);
    var dropOffDestinationGeoGraphicCoOrdinates =LatLng(dropOffDestinationLocation!.latitudePosition!, dropOffDestinationLocation!.longitudePosition!);


    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => LoadingDialog(messageText: "Getting direction...")
    );

    ///57 send request to api and get direction details
    ///Directions API
    var detailsFromDirectionAPI = await CommonMethods.getDirectionDetailsFromAPI(pickUpGeoGraphicCoOrdinates, dropOffDestinationGeoGraphicCoOrdinates);
    setState(() {
      tripdirectionDetailsInfo = detailsFromDirectionAPI;

    });
    Navigator.pop(context);

    /// DROW ROUUUUUUUTE from pickup to dropOffDestination ************************************************
    ///60  ************** decode encoded polyline points and convert to long lat points
    PolylinePoints pointsPolyline =PolylinePoints();
    List<PointLatLng> latLngPointsFromPickUpToDestination = pointsPolyline.decodePolyline(tripdirectionDetailsInfo!.encodedPoints!);


    polylineCoOrdinates.clear();

    if(latLngPointsFromPickUpToDestination.isNotEmpty)
    {
      latLngPointsFromPickUpToDestination.forEach((PointLatLng latLngPoint)
      {
        polylineCoOrdinates.add(LatLng(latLngPoint!.latitude, latLngPoint!.longitude));

      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline=Polyline(
        polylineId: PolylineId("polylineID"),
        color: Colors.blue,
        points: polylineCoOrdinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    /// 61 Fit the polyline into the map
    LatLngBounds boundsLatLng;
    if(pickUpGeoGraphicCoOrdinates.latitude> dropOffDestinationGeoGraphicCoOrdinates.latitude
        && pickUpGeoGraphicCoOrdinates.longitude> dropOffDestinationGeoGraphicCoOrdinates.longitude)
    {
      boundsLatLng = LatLngBounds(
          southwest: dropOffDestinationGeoGraphicCoOrdinates,
          northeast: pickUpGeoGraphicCoOrdinates
      );
    }
    else if(pickUpGeoGraphicCoOrdinates.longitude > dropOffDestinationGeoGraphicCoOrdinates.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(pickUpGeoGraphicCoOrdinates.latitude,dropOffDestinationGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(dropOffDestinationGeoGraphicCoOrdinates.latitude,pickUpGeoGraphicCoOrdinates.longitude),
      );
    }
    else if(pickUpGeoGraphicCoOrdinates.latitude > dropOffDestinationGeoGraphicCoOrdinates.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(dropOffDestinationGeoGraphicCoOrdinates.latitude,pickUpGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(pickUpGeoGraphicCoOrdinates.latitude,dropOffDestinationGeoGraphicCoOrdinates.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(
        southwest: pickUpGeoGraphicCoOrdinates,
        northeast: dropOffDestinationGeoGraphicCoOrdinates,
      );
    }

    controllerGoogleMap!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));


    ///Add markers to pickUp and dropOffdestination points

    Marker pickUpPointMarker = Marker(
      markerId: MarkerId("pickUpPointMarkerID"),
      position: pickUpGeoGraphicCoOrdinates,
      /// COOLOOOOOOr *********************************************************
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickUpLocation.placeName, snippet: "Pickup Location"),
    );

    Marker dropOffDestinationPointMarker = Marker(
      markerId: const MarkerId("dropOffPointMarkerID"),
      position: dropOffDestinationGeoGraphicCoOrdinates,

      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: dropOffDestinationLocation.placeName, snippet: "destination Location"),
    );

    setState(() {
      markerSet.add(pickUpPointMarker);
      markerSet.add(dropOffDestinationPointMarker);
    });

    ///Add Circles to pickUp and dropOffdestination points

    Circle pickUpPointCircle = Circle(
        circleId: const CircleId('pickupCircleID'),
        strokeColor: Colors.blue,
        strokeWidth: 4,
        radius: 14,
        center: pickUpGeoGraphicCoOrdinates,
        fillColor: Colors.pink

    );

    Circle dropOffDestinationPointCircle = Circle(
      circleId: const CircleId('dropOffDestinationCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: dropOffDestinationGeoGraphicCoOrdinates,
      fillColor: Colors.pink,
    );

    setState(() {
      circleSet.add(pickUpPointCircle);
      circleSet.add(dropOffDestinationPointCircle);
    });
  }

  resetAppNow()
  {
    setState(() {
      polylineCoOrdinates.clear();
      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      searchContainerHeight =  276;
      bottomMapPadding = 300;
      isDrawerOpened = true;

      status = "";
      nameDriver = "";
      driverRatings="";
      photoDriver = "";
      phoneNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDisplay = 'Driver is Arriving';
    });

  }

  cancelRideRequest()
  {
    //remove ride request from database
    tripRequestRef!.remove();

    setState(() {
      stateOfApp="normal";
    });

  }

  void displayRequestContainer(OnlineNearbyDrivers selectedDriver)
  {
    setState(() {
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 220;
      bottomMapPadding = 200;
      isDrawerOpened = true;
    });

    // Print the properties of the selected driver
    print("Selected Driver Details: "
        "Name: ${selectedDriver.nameDriver}, "
        "UID: ${selectedDriver.uidDriver}, "
        "Phone: ${selectedDriver.phoneNumberDriver}, "
        "Ratings: ${selectedDriver.driverRatings}");

    // Pass the selectedDriver to the maketripRequest1 function
    print("CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
    maketripRequest1(selectedDriver);
  }

  ///74 events calling explained further
  updateAvailableNearbyOnlineDriversOnMap() {

    print("ANA FI updateAvailableNearbyOnlineDriversOnMap UUUUUUBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");

    setState(() {
      markerSet.clear();
    });

    Set<Marker> markersTempSet = Set<Marker>();
    print("Number of drivers in the list: ${ManageDriversMethods.nearbyOnlineDriversList.length}");

    for (OnlineNearbyDrivers eachOnlineNearbyDriver in ManageDriversMethods.nearbyOnlineDriversList) {
      LatLng driverCurrentPosition = LatLng(eachOnlineNearbyDriver.latDriver!, eachOnlineNearbyDriver.lngDriver!);
      print("Driver Name: ${eachOnlineNearbyDriver.nameDriver}DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPppppppppppppppppp");

      Marker driverMarker = Marker(
        markerId: MarkerId("driver ID = " + eachOnlineNearbyDriver.uidDriver.toString()),
        position: driverCurrentPosition,
        icon: carIconNearbyDriver!,
      );

      markersTempSet.add(driverMarker);
    }

    setState(() {
      markerSet = markersTempSet;
    });
  }


  ///71 query at location set radius around user current location
  initializeGeoFireListener() {
    print("ANA FI initializeGeoFireListener PBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");


    Geofire.initialize("onlineDrivers");

    StreamSubscription? geofireSubscription = Geofire.queryAtLocation(
        currentPositionOfUser!.latitude,
        currentPositionOfUser!.longitude,
        22)
        ?.listen((driverEvent) {
      if (driverEvent != null) {
        var onlineDriverChild = driverEvent["callBack"];
        print("Driver event callback type: $onlineDriverChild");

        switch (onlineDriverChild) {

          case Geofire.onKeyEntered:
            print("switch 464 PBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];

            // Print driver details for debugging
            print("Driver entered: ${onlineNearbyDrivers.uidDriver}, Latitude: ${onlineNearbyDrivers.latDriver}, Longitude: ${onlineNearbyDrivers.lngDriver}");

            // If the driver name is available, print it
            if (onlineNearbyDrivers.nameDriver != null) {
              print("Driver Name: ${onlineNearbyDrivers.nameDriver}PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP");
            }

            ManageDriversMethods.updateOnlineNearbyDriversLocation(onlineNearbyDrivers);

            if (nearbyOnlineDriverKeysLoaded == true) {
              // Update drivers on Google Map
              updateAvailableNearbyOnlineDriversOnMap();
            }
            _handleDriverEvent(driverEvent);
            break;

          case Geofire.onKeyExited:
            print("switch 488 PBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");

            ManageDriversMethods.removeDriverFromList(driverEvent["key"]);
            updateAvailableNearbyOnlineDriversOnMap();
            _handleDriverEvent(driverEvent, isExit: true);
            break;

          case Geofire.onKeyMoved:
            print("switch 496 PBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");

            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];

            // Print driver details for debugging
            print("Driver moved: ${onlineNearbyDrivers.uidDriver}, Latitude: ${onlineNearbyDrivers.latDriver}, Longitude: ${onlineNearbyDrivers.lngDriver}");

            // If the driver name is available, print it
            if (onlineNearbyDrivers.nameDriver != null) {
              print("Driver Name: ${onlineNearbyDrivers.nameDriver}");
            }

            ManageDriversMethods.updateOnlineNearbyDriversLocation(onlineNearbyDrivers);
            updateAvailableNearbyOnlineDriversOnMap();
            _handleDriverEvent(driverEvent);
            break;

          case Geofire.onGeoQueryReady:
            print("switch 517 PBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");

            nearbyOnlineDriverKeysLoaded = true;
            updateAvailableNearbyOnlineDriversOnMap();
            break;
        }
      }
    });

    // Reconnect the listener if it disconnects
    geofireSubscription?.onDone(() {
      print("Geofire listener done, reconnecting...");
      initializeGeoFireListener();
    });

    geofireSubscription?.onError((error) {
      print("Geofire listener error: $error");
      initializeGeoFireListener();
    });
  }


  _handleDriverEvent(driverEvent, {bool isExit = false})
  {
    if (isExit) {
      ManageDriversMethods.removeDriverFromList(driverEvent["key"]);
    } else {
      OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
      onlineNearbyDrivers.uidDriver = driverEvent["key"];
      onlineNearbyDrivers.latDriver = driverEvent["latitude"];
      onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
      ManageDriversMethods.updateOnlineNearbyDriversLocation(onlineNearbyDrivers);
    }
    updateAvailableNearbyOnlineDriversOnMap();
  }


  void maketripRequest1(OnlineNearbyDrivers selectedDriver)
  {
    print("maketripRequest1 is being called.");

    print("maketripRequest1 is being ${selectedDriver} MTRRRRRRRRRRRRRPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP.");
    // Vérifiez les coordonnées et autres informations
    var dropOffLocation = Provider.of<AppInfo>(context, listen: false).dropOffLocation;
    var pickUpLocation = Provider.of<AppInfo>(context, listen: false).pickUpLocation;

    if (pickUpLocation == null || dropOffLocation == null) {
      print("Location data is missing.");
      return;
    }

    print("PickUp Location: ${pickUpLocation.latitudePosition}, ${pickUpLocation.longitudePosition}");
    print("DropOff Location: ${dropOffLocation.latitudePosition}, ${dropOffLocation.longitudePosition}");

    // Création de la demande de trajet
    tripRequestRef = FirebaseDatabase.instance.ref().child("tripRequests").push();
    Map<String, String> pickUpCoOrdinatesMap = {
      "latitude": pickUpLocation.latitudePosition.toString(),
      "longitude": pickUpLocation.longitudePosition.toString(),
    };

    Map<String, String> dropOffCoOrdinatesMap = {
      "latitude": dropOffLocation.latitudePosition.toString(),
      "longitude": dropOffLocation.longitudePosition.toString(),
    };

    Map<String, dynamic> dataMap = {
      "tripID": tripRequestRef!.key,
      "publishDateTime": DateTime.now().toString(),
      "userName": userName,
      "userPhone": userPhone,
      "userPhoto":userPhoto,///rien

      "userID": userID,
      "pickUpLatLng": pickUpCoOrdinatesMap,
      "dropOffLatLng": dropOffCoOrdinatesMap,
      "pickUpAddress": pickUpLocation.humanReadableAdress,
      "dropOffAddress": dropOffLocation.placeName,
      "driverID":selectedDriver.uidDriver,  // Use the selected driver's UID
      ///selectedDriver.uidDriver,
      "carDetails": "", // Use the selected driver's car details
      "driverLocation": {
        "latitude": selectedDriver.latDriver.toString(), // Use the selected driver's location
        "longitude": selectedDriver.lngDriver.toString(),
      },
      "driverName": selectedDriver.nameDriver,  // Use the selected driver's name
      "driverPhone": selectedDriver.phoneNumberDriver, // Use the selected driver's phone number
      "driverPhoto": selectedDriver.photoDriver, // Use the selected driver's photo
      "fareAmount": "",
      "status": "new",
      "ratings": "", // Use the selected driver's ratings
    };

    tripRequestRef!.set(dataMap).then((_) {
      print("Trip request added successfully.");
    }).catchError((error) {
      print("Failed to add trip request: $error");
    });

    // Ecouter les mises à jour
    tripsStreamSubscription = tripRequestRef!.onValue.listen((eventSnapshot) async {
      if (eventSnapshot.snapshot.value == null) {
        return;
      }

      Map tripData = eventSnapshot.snapshot.value as Map;

      // Traitement des données du trajet
      print("Trip Data: $tripData");
      // Récupérer les informations du conducteur
      if (tripData["driverName"] != null) {
        nameDriver = tripData["driverName"];
      }

      if (tripData["ratings"] != null) {
        driverRatings = tripData["ratings"];
      }

      if (tripData["driverPhone"] != null) {
        phoneNumberDriver = tripData["driverPhone"];
      }

      if (tripData["carDetails"] != null) {
        carDetailsDriver = tripData["carDetails"];
      }

      if (tripData["status"] != null) {
        status = tripData["status"];
      }



      if (tripData["driverLocation"] != null) {
        double driverLatitude = double.parse(tripData["driverLocation"]["latitude"].toString());
        double driverLongitude = double.parse(tripData["driverLocation"]["longitude"].toString());

        LatLng driverCurrentLocationLatLng = LatLng(driverLatitude, driverLongitude);

        if (status == "accepted") {
          updateFromDriverCurrentLocationToPickUp(driverCurrentLocationLatLng);
        } else if (status == "arrived") {
          setState(() {
            tripStatusDisplay = 'Driver is Arrived';
          });
        } else if (status == "ontrip") {
          updateFromDriverCurrentLocationToDropOffDestination(driverCurrentLocationLatLng);
        }
      }

      if (status == "accepted") {
        displayTripDetailsContainer();
        Geofire.stopListener();

        // Remove driver's markers
        setState(() {
          markerSet.removeWhere((element) => element.markerId.value.contains("driver"));
        });
      }

      if (status == "ended") {
        if (tripData["fareAmount"] != null) {
          double fareAmount = double.parse(tripData["fareAmount"].toString());
          //double fareAmount = cMethods.calculateFareAmount(tripdirectionDetailsInfo!);

          var responseFromPaymentDialog = await showDialog(
            context: context,
            builder: (BuildContext context) => PaymentDialog(fareAmount: fareAmount.toString()),
          );

          if (responseFromPaymentDialog == "paid") {
            tripRequestRef!.onDisconnect();
            tripRequestRef = null;

            tripsStreamSubscription!.cancel();
            tripsStreamSubscription = null;

            // Assurez-vous que tripID et driverID sont récupérés
            String tripID = tripData["tripID"];  // Récupérer le tripID depuis Firebase
            String driverID = tripData["driverID"]; // Récupérer le driverID depuis Firebase

            // Afficher la boîte de dialogue de notation avec les identifiants récupérés
            showRatingDialog(context, tripID, driverID);

            resetAppNow();

            await Future.delayed(Duration(milliseconds: 500));
          }
        }
      }
    });
    print("Trip request processed successfully.");
  }

  displayTripDetailsContainer()
  {
    setState(() {
      requestContainerHeight = 0;
      tripContainerHeight = 291;
      bottomMapPadding = 281;
    });
  }


  updateFromDriverCurrentLocationToPickUp(driverCurrentLocationLatLng) async
  {
    if(!requestingDirectionDetailsInfo)
    {
      requestingDirectionDetailsInfo = true;
      var userPickUplocationLatLng = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

      var directionDetailsPickUp = await CommonMethods.getDirectionDetailsFromAPI(driverCurrentLocationLatLng, userPickUplocationLatLng);

      if(directionDetailsPickUp == null)
      {
        return;
      }

      setState(() {
        tripStatusDisplay = "Driver is Coming - ${directionDetailsPickUp.durationTextString}";
      });
      requestingDirectionDetailsInfo = false;
    }
  }

  updateFromDriverCurrentLocationToDropOffDestination(driverCurrentLocationLatLng) async
  {
    if(!requestingDirectionDetailsInfo)
    {
      requestingDirectionDetailsInfo = true;

      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).dropOffLocation;

      var userDropOffLocationLatLng = LatLng(dropOffLocation!.latitudePosition!, dropOffLocation!.longitudePosition!);

      var directionDetailsPickUp = await CommonMethods.getDirectionDetailsFromAPI(driverCurrentLocationLatLng, userDropOffLocationLatLng);

      if(directionDetailsPickUp == null)
      {
        return;
      }

      setState(() {
        tripStatusDisplay = "Driving to DropOff Location - ${directionDetailsPickUp.durationTextString}";
      });
      requestingDirectionDetailsInfo = false;
    }

  }

  noDriverAvaible()
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context)=> InfoDialog(
          title: "No Driver Available",
          description: "No driver found in the nearby location. Please try again shortly.",
        )
    );


  }

  searchDriver()
  {
    if (availableNearbyOnlineDriverList!.isEmpty) {
      cancelRideRequest();
      resetAppNow();
      noDriverAvaible();
      return;
    }
    // Driver selection will now be handled manually in the SelectNearestActiveDriversScreen
  }

  void sendNotificationToDriver(OnlineNearbyDrivers currentDriver)
  {
    print("Sending notification to driver: ${currentDriver.nameDriver} (UID: ${currentDriver.uidDriver})");

    if (tripRequestRef == null) {
      print("Error: tripRequestRef is null.");
      return;
    }

    if (currentDriver.uidDriver == null) {
      print("Error: Driver UID is null.");
      return;
    }

    if (currentDriver.token == null) {
      print("Error: Driver token is null.");
      return;
    }

    DatabaseReference currentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("newTripStatus");
    currentDriverRef.set(tripRequestRef!.key);

    DatabaseReference tokenOfCurrentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("deviceToken");

    tokenOfCurrentDriverRef.once().then((dataSnapshot) async {
      if (dataSnapshot.snapshot.value != null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();

        await retrieveDirectionDetails();

        PushNotificationService.sendNotificationToSelectedDriver(
          deviceToken,
          context,
          tripRequestRef!.key.toString(),
          currentDriver.uidDriver.toString(),
        );
      } else {
        return;
      }

      const oneTickPerSec = Duration(seconds: 1);

      var timerCountDown = Timer.periodic(oneTickPerSec, (timer) {
        requestTimeoutDriver = requestTimeoutDriver - 1;

        if (stateOfApp != "requesting") {
          timer.cancel();
          currentDriverRef.set("cancelled");
          currentDriverRef.onDisconnect();
          requestTimeoutDriver = 20;
        }

        currentDriverRef.onValue.listen((dataSnapshot) {
          if (dataSnapshot.snapshot.value.toString() == "accepted") {
            timer.cancel();
            currentDriverRef.onDisconnect();
            requestTimeoutDriver = 20;
          }
        });

        if (requestTimeoutDriver == 0) {
          currentDriverRef.set("timeout");
          timer.cancel();
          currentDriverRef.onDisconnect();
          requestTimeoutDriver = 20;

          //searchDriver();
        }
      });
    });
    print("Notification sent successfully.");
  }

  void testPickUpLocation()
  {
    var appInfo = Provider.of<AppInfo>(context, listen: false);
    if (appInfo.pickUpLocation == null) {
      print('Testing: pickUpLocation is null');
    } else {
      print('Testing: pickUpLocation is ${appInfo.pickUpLocation!.placeName}');
    }
  }

  retrieveCurrentDriverInfo() async {
    await FirebaseDatabase.instance.ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once().then((snap) async {
      var userData = snap.snapshot.value as Map;

      userName = userData["name"];
      userPhone = userData["phone"];
      userEmail = userData["email"];

      // Get the Firebase Storage image reference
      String userPhotoPath = userData["photo"];
      userPhoto = await FirebaseStorage.instance
          .refFromURL("gs://indriver-clone-amal.appspot.com/Images/$userPhotoPath")
          .getDownloadURL(); // Convert to URL

      // Set default if the userPhoto is not found
      if (userPhoto == null || userPhoto.isEmpty) {
        userPhoto = "assets/images/girl.jpg";  // Fallback to a local asset image
      }

      // After fetching the data, call setState to rebuild the UI
      setState(() {});
    });
  }

  @override
  void initState()
  {
    // TODO: implement initState
    super.initState();

    retrieveCurrentDriverInfo();

  }

  void showRatingDialog(BuildContext context, String tripId, String driverId)
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double rating = 0.0;

        return AlertDialog(
          title: const Text("Rate your driver"),
          content: SizedBox(
            width: 250, // Fixed width for the rating bar
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (ratingValue) {
                    rating = ratingValue;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Tap on a star to rate',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Submit"),
              onPressed: () {
                if (rating > 0) {
                  // Save the rating for the specified driver
                  saveDriverRating(tripId, driverId, rating);
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveDriverRating(String tripId, String driverId, double newRating) async
  {
    // Référence à la demande de trajet spécifique
    DatabaseReference tripRequestRef = FirebaseDatabase.instance.ref().child("tripRequests").child(tripId);

    // Sauvegarder la nouvelle note sous "ratings" dans la demande de trajet
    await tripRequestRef.child("ratings").set(newRating).then((_) {
      print("Rating saved successfully under tripRequests.");
    }).catchError((error) {
      print("Failed to save rating under tripRequests: $error");
    });

    // Référence aux notes du chauffeur
    DatabaseReference driverRatingsRef = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(driverId)
        .child("ratings");

    // Sauvegarder la nouvelle note sous "ratings" pour le chauffeur
    DatabaseReference newRatingRef = driverRatingsRef.push();
    await newRatingRef.set(newRating);

    // Recalculer la note moyenne
    await driverRatingsRef.once().then((snap) async {
      if (snap.snapshot.value != null) {
        Map<dynamic, dynamic> ratingsMap = snap.snapshot.value as Map<dynamic, dynamic>;
        double totalRatings = 0.0;
        int count = ratingsMap.length;

        ratingsMap.forEach((key, value) {
          totalRatings += double.parse(value.toString());
        });

        double averageRating = totalRatings / count;

        // Mettre à jour la note moyenne sous un nœud séparé
        DatabaseReference averageRatingRef = FirebaseDatabase.instance.ref()
            .child("drivers")
            .child(driverId)
            .child("averageRating");
        await averageRatingRef.set(averageRating);

        print("Average rating updated successfully.");
      } else {
        // S'il n'existe aucune note, définir la nouvelle note comme la moyenne
        DatabaseReference averageRatingRef = FirebaseDatabase.instance.ref()
            .child("drivers")
            .child(driverId)
            .child("averageRating");
        await averageRatingRef.set(newRating);

        print("Average rating set successfully.");
      }
    }).catchError((error) {
      print("Failed to update average rating: $error");
    });
  }

  ///******************************NEW LOGIC
  Future<void> fetchDriverDetails(BuildContext context, List<String> driverKeys) async {
    List<OnlineNearbyDrivers> availableDrivers = [];

    for (String key in driverKeys) {
      DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers").child(key);
      try {
        var snapshot = await driverRef.once();
        var driverData = snapshot.snapshot.value as Map;

        // Check if "averageRating" exists and is not null; otherwise, use 0.0
        double averageRating = 0.0;
        if (driverData.containsKey("averageRating") && driverData["averageRating"] != null) {
          averageRating = (driverData["averageRating"] as num).toDouble();
        }

        OnlineNearbyDrivers driver = OnlineNearbyDrivers(
          uidDriver: key,
          nameDriver: driverData["name"],
          photoDriver: driverData["photo"],
          phoneNumberDriver: driverData["phone"],
          driverRatings: averageRating.toStringAsFixed(1), // Set driverRatings
          token: driverData["deviceToken"],
          fareAmount: "${(cMethods.calculateFareAmount(tripdirectionDetailsInfo!)).toString()} DH",
          carModelDriver: driverData["car_details"]["carModel"], // Retrieve car model
          carColorDriver: driverData["car_details"]["carColor"], // Retrieve car color
          carNumberDriver: driverData["car_details"]["carNumber"],
        );

        // Print the driver's name after adding to the list
        print("Driver fetched: ${driver.nameDriver} FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");

        availableDrivers.add(driver);
      } catch (e) {
        print("Error fetching driver details: $e");
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectNearestActiveDriversScreen(
          availableDrivers: availableDrivers,
          onDriverSelected: (driver) async {
            if (driver != null) {
              print("Driver selected: ${driver.nameDriver} NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN");
              displayRequestContainer(driver);
              sendNotificationToDriver(driver);
              print("After maketripRequest1 call");
              Navigator.pop(context); // Go back to the home screen after selecting a driver
            }
          },
        ),
      ),
    );
  }


  ///***********************************************************************************
  ///***************************************      UI         *****************************
  ///***********************************************************************************

  @override
  Widget build(BuildContext context)
  {
    makeDriverNearbyCarIcon();
    testPickUpLocation();


    return Scaffold(
      key: sKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to ProfilePage when the profile image or text is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 80,  // Image width
                            height: 80, // Image height
                            child: userPhoto != null && userPhoto!.isNotEmpty
                                ? Image.network(
                              userPhoto!, // Ensure this is a valid URL
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to local asset image on error
                                return Image.asset(
                                  'assets/images/girl.jpg',
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                                : Image.asset(
                              'assets/images/girl.jpg', // Default image if no URL is found
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 20, // Increased font size for better readability
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Profile",
                              style: TextStyle(
                                fontSize: 16, // Smaller font size for secondary text
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Additional space at the bottom
                ],
              ),
            ),



            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text("My Rides"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => TripsHistoryPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: Row(
                children: [
                  const Text("Safety"),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "New",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (c) => SafetyScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Payment"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text("Redeem Coupon"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => RedeemCoupon()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text("Rapido Coins"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => SettingsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              onTap: () {},
            ),
            /*
            ListTile(
              leading: const Icon(Icons.star_border),
              title: const Text("Ratings"),
              onTap: () {
                //Navigator.push(context, MaterialPageRoute(builder: (c) => RatingsTabPage(driverId: driverId)));
              },
            ),
            */
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Refer and Earn"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => ReferAndEarn()));
              },
            ),/*
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => AboutPage()));
              },
            ),
            */
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
              },
            ),
          ],
        ),
      ),


      body: Stack(
        children: [

          ///Google map
          GoogleMap(
            padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            circles: circleSet,
            initialCameraPosition: googlePlexInitioalPosition,
            //markers: currentLocationMarker != null ? {currentLocationMarker!} : {},
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);
              setState(() {
                bottomMapPadding = 140;
              });
              getCurrentLiveLocationOfUser();
            },
          ),

          ///drawer button
          Positioned(
            top: 36,
            left: 19,
            child: GestureDetector(
              onTap: ()
              {
                if(isDrawerOpened==true)
                {
                  sKey.currentState!.openDrawer();
                }
                else
                { /// Cancel button *****************************************************
                  resetAppNow();
                }

              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child:  CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  child: Icon(///CLOSE OR ARROW_BACk
                    isDrawerOpened == true ? Icons.menu: Icons.close,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          ///search location icon button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // Adjust this to position the button at the bottom of the screen
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.white, // Background color of the button container
              child: ElevatedButton(
                onPressed: () async {
                  var responseFromSearchPage = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => SearchDestinationPage()),
                  );
                  if (responseFromSearchPage == "placeSelected") {
                    displayUserRideDetailsContainer();
                  } else {
                    print("Error: No place selected or something went wrong.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow, // Background color of the button
                  padding: const EdgeInsets.symmetric(vertical: 15), // Button height
                  elevation: 0, // Remove elevation to make it flat
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners for the button
                  ),
                ),
                child: const Text(
                  "Confirm Location",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black, // Text color
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
              ),
            ),
          ),


          ///ride details container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: rideDetailsContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white12,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(.7, .7),
                  ),
                ],
              ),
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 190,
                            child: Card(
                              elevation: 10,
                              child: Container(
                                width: MediaQuery.of(context).size.width * .70,
                                color: Colors.black45,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8,right: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              (tripdirectionDetailsInfo != null) ? tripdirectionDetailsInfo!.distanceTextString! : "0 km",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            Text(
                                              (tripdirectionDetailsInfo != null) ? tripdirectionDetailsInfo!.durationTextString! : "0 sec",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),



                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            stateOfApp = "requesting";
                                          });

                                          // Get the list of nearby driver keys
                                          List<String> driverKeys = ManageDriversMethods.nearbyOnlineDriversList!
                                              .map((driver) {
                                            // Print the driver UID for debugging
                                            print("Driver UID PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP: ${driver.uidDriver}");
                                            return driver.uidDriver ?? ""; // Replace null with an empty string or some default value
                                          })
                                              .toList();

                                          // Fetch driver details and navigate to the selection screen
                                          fetchDriverDetails(context, driverKeys);
                                        },
                                        child: Image.asset(
                                          "assets/images/uberexec.png",
                                          height: 122,
                                          width: 122,
                                        ),
                                      ),


                                      Text(
                                        (tripdirectionDetailsInfo != null) ? " ${(cMethods.calculateFareAmount(tripdirectionDetailsInfo!)).toString()} DH": "",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )

              ),
            ),
          ),

          ///request container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: requestContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                boxShadow:
                [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ///Animation flickr
                    SizedBox(
                      width: 200,
                      child: LoadingAnimationWidget.flickr(
                        leftDotColor: Colors.greenAccent,
                        rightDotColor : Colors.pinkAccent,
                        size : 50,
                      ),
                    ),

                    const SizedBox(height: 20,),

                    GestureDetector(
                      onTap: ()
                      {
                        resetAppNow();
                        cancelRideRequest();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 1.5,color: Colors.grey),
                        ),
                        child:const Icon(
                          Icons.close,
                          color:Colors.black,
                          size: 25,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          ///trip details container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: tripContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                boxShadow:
                [
                  BoxShadow(
                    color: Colors.white24,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 5,),

                    /// trip status display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tripStatusDisplay,
                          style: const TextStyle(fontSize: 19,color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 19,),

                    Divider(
                      height: 1,
                      color: Colors.white70,
                      thickness: 1,
                    ),

                    const SizedBox(height: 19,),

                    //image - driver name and driver car details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.network(
                            photoDriver == ''
                                ? "https://firebasestorage.googleapis.com/v0/b/indriver-clone-amal.appspot.com/o/Images%2Ftete.jpg?alt=media&token=cc0686c2-750c-4d4a-90b4-dbad1cf4b558"
                                : photoDriver,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 8,), // Adjusted to width instead of height

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameDriver,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              carDetailsDriver,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 19,),

                    Divider(
                      height: 1,
                      color: Colors.white70,
                      thickness: 1,
                    ),

                    const SizedBox(height: 19,),
                    //call driver btn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: ()
                          {
                            launchUrl(Uri.parse("tel://$phoneNumberDriver"));

                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 11,),

                              Text("Call", style: TextStyle(color: Colors.grey,),),

                            ],
                          ),
                        )
                      ],
                    )

                  ],
                ),
              ),

            ),
          ),

        ],
      ),
    );
  }
}
