
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/models/prediction_model.dart';
import 'package:users_app/widgets/prediction_place_ui.dart';

import '../appinfo/app_info.dart';
import 'dart:convert';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;

class SearchDestinationPage extends StatefulWidget {
  const SearchDestinationPage({super.key});

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {

  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();

  List<PredictionModel> dropOffPredictionsPlacesList = [];


  List<AutocompletePrediction> predictions = [];

  ///Google Places API- Place AutoComplete************************************************
  /// Nominatim API - Place Search
  Future<void> searchLocation(String locationName) async {
    if (locationName.length > 1) {
      String apiPlacesUrl = "https://nominatim.openstreetmap.org/search?q=$locationName&format=json&addressdetails=1";

      // Requête HTTP vers Nominatim
      var response = await http.get(Uri.parse(apiPlacesUrl));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Vérifiez si les données existent et mappez-les à la liste de prédictions
        if (responseData != null) {
          setState(() {
            dropOffPredictionsPlacesList = (responseData as List)
                .map((data) => PredictionModel.fromJsonNominatim(data))
                .toList();

            // Sorting logic to prioritize Moroccan locations
            dropOffPredictionsPlacesList.sort((a, b) {
              if (a.country == "Morocco" && b.country != "Morocco") {
                return -1; // Moroccan locations should come first
              } else if (a.country != "Morocco" && b.country == "Morocco") {
                return 1; // Non-Moroccan locations should come later
              } else {
                return a.displayName.compareTo(b.displayName); // Sort alphabetically otherwise
              }
            });
          });
        }
      } else {
        print("Erreur lors de la récupération des données de Nominatim");
      }
    }
  }


  ///************************************************************************************
  ///*****************************************        UI        *******************************
  ///************************************************************************************


  @override
  Widget build(BuildContext context) {
    String userAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation?.humanReadableAdress ?? "";

    // Schedule update of the controller after the widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pickUpTextEditingController.text = userAddress;
    });

    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                height: 230,
                decoration: BoxDecoration(
                  color: Colors.white, // Set the background color to white
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: const Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back, color: Colors.black),
                          ),
                          const Center(
                            child: Text(
                              "Search Destination",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Text color
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/initial.png",
                            height: 16,
                            width: 16,
                            // Apply grey color to icon
                          ),
                          const SizedBox(width: 18), // Fix spacing
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: TextField(
                                  controller: pickUpTextEditingController,
                                  decoration: const InputDecoration(
                                    hintText: "Pickup Address",
                                    fillColor: Colors.white70,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9),
                                  ),
                                  style: const TextStyle(color: Colors.black), // Text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),


                      const SizedBox(height: 11),


                      Row(
                        children: [
                          Image.asset(
                            "assets/images/final.png",
                            height: 16,
                            width: 16,

                          ),
                          const SizedBox(width: 18), // Fix spacing
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: destinationTextEditingController,
                                  onChanged: (inputText) {
                                    searchLocation(inputText);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Destination Address",
                                    hintStyle: const TextStyle(color: Colors.grey),

                                    fillColor: Colors.white70,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9),
                                  ),
                                  style: const TextStyle(color: Colors.black), // Text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (dropOffPredictionsPlacesList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    return PredictionPlaceUi(
                      predictedPlaceData: dropOffPredictionsPlacesList[index],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                      thickness: 1,
                    );
                  },
                  itemCount: dropOffPredictionsPlacesList.length,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                ),
              )

            else
              Container(),
          ],
        ),
      ),
    );
  }
}
