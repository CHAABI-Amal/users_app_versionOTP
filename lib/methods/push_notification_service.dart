import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../appinfo/app_info.dart';
import '../global/global_var.dart';

class PushNotificationService {
  // Fonction pour envoyer une notification à un conducteur sélectionné
  static Future<void> sendNotificationToSelectedDriver(
      String deviceToken, BuildContext context, String tripID, String driverId) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'sendPushNotification',
      );

      await callable.call(<String, dynamic>{
        'deviceToken': deviceToken,
        'tripID': tripID,
      });

      print('Notification sent successfully.');
    } catch (e) {
      print('Failed to send notification: $e');
    }

    final appInfo = Provider.of<AppInfo>(context, listen: false);

    String pickUpLocation = Provider.of<AppInfo>(context, listen: false).pickUpLocation?.humanReadableAdress ?? "";

    // Attendre que pickUpLocation soit défini
    if (appInfo.pickUpLocation == null) {
      print('pickUpLocation is null! Waiting for update...');
      await Future.delayed(Duration(milliseconds: 500));
    }

    if (appInfo.pickUpLocation == null) {
      print('pickUpLocation is null!');  // Ajoutez un log pour voir si pickUpLocation est null
    } else {
      print('pickUpLocation: ${appInfo.pickUpLocation?.placeName}');
    }


    // Continuer une fois que pickUpLocation est défini
    String dropOffDestinationAddress = appInfo.dropOffLocation?.placeName ?? 'Unknown drop-off location';

    print('PickUpLocation: $pickUpLocation');

    DatabaseReference notificationRef = FirebaseDatabase.instance.ref()
        .child("notifications")
        .child("drivers")
        .child(driverId);

    Map<String, String> notificationData = {
      "tripID": tripID,
      "message": "You have a new trip request! from $userName \nPick-Up Location: $pickUpLocation \nDrop-Off Location: $dropOffDestinationAddress",
    };

    notificationRef.set(notificationData);
  }

  // Fonction pour envoyer une notification après la mise à jour de la localisation
  Future<void> sendNotificationAfterLocationUpdate(BuildContext context, String deviceToken, String tripID, String driverId) async {
    final appInfo = Provider.of<AppInfo>(context, listen: false);

    // Attendre activement que pickUpLocation soit défini
    while (appInfo.pickUpLocation == null) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Maintenant, vous pouvez appeler la fonction de notification en toute sécurité
    await sendNotificationToSelectedDriver(deviceToken, context, tripID, driverId);
  }


}
