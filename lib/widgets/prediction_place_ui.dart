import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/models/prediction_model.dart';
import '../appinfo/app_info.dart';
import '../models/address_model.dart';

class PredictionPlaceUi extends StatelessWidget {
  final PredictionModel? predictedPlaceData;

  const PredictionPlaceUi({Key? key, this.predictedPlaceData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      leading: Icon(Icons.location_on, color: Colors.grey.shade600), // Match the icon style from the image
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: predictedPlaceData?.mainText ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: " ${predictedPlaceData?.secondaryText ?? ''}",
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        AddressModel dropOffLocation = AddressModel()
          ..latitudePosition = predictedPlaceData?.latitude
          ..longitudePosition = predictedPlaceData?.longitude
          ..placeName = predictedPlaceData?.displayName;

        Provider.of<AppInfo>(context, listen: false).updateDropOffLocation(dropOffLocation);
        Navigator.pop(context, "placeSelected");
      },
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/models/prediction_model.dart';
import '../appinfo/app_info.dart';
import '../models/address_model.dart';

class PredictionPlaceUi extends StatefulWidget {
  final PredictionModel? predictedPlaceData;

  const PredictionPlaceUi({Key? key, this.predictedPlaceData}) : super(key: key);

  @override
  State<PredictionPlaceUi> createState() => _PredictionPlaceUiState();
}

class _PredictionPlaceUiState extends State<PredictionPlaceUi> {
  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: Colors.white, // Set card background color to white
      child: ListTile(
        leading: Icon(Icons.location_on_outlined, color: Colors.black),
        title: Text(
          widget.predictedPlaceData?.displayName ?? 'No address',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black, // Set text color to black
          ),
        ),
        onTap: () {
          AddressModel dropOffLocation = AddressModel()
            ..latitudePosition = widget.predictedPlaceData?.latitude
            ..longitudePosition = widget.predictedPlaceData?.longitude
            ..placeName = widget.predictedPlaceData?.displayName;

          Provider.of<AppInfo>(context, listen: false).updateDropOffLocation(dropOffLocation);
          Navigator.pop(context, "placeSelected");
        },
      ),
    );
  }
}

 */