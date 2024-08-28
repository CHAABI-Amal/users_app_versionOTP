import 'package:users_app/models/online_nearby_drivers.dart';

class ManageDriversMethods
{

  static List<OnlineNearbyDrivers> nearbyOnlineDriversList = [];

  static void addDriverToList(OnlineNearbyDrivers driver) {
    nearbyOnlineDriversList.add(driver);
    print('Driver added: ${driver.uidDriver}');
  }

  static void removeDriverFromList(String driverID) {
    int index = nearbyOnlineDriversList.indexWhere((driver) => driver.uidDriver == driverID);

    if (index != -1) {
      nearbyOnlineDriversList.removeAt(index);
      print('Driver removed: $driverID');
    } else {
      print('Attempted to remove a non-existent driver: $driverID');
    }
  }


  /// add nearest onlinedrivers and remove drivers from list
  static void updateOnlineNearbyDriversLocation(OnlineNearbyDrivers nearbyOnlineDriverInformation) {
    print("Updating driver location: ${nearbyOnlineDriverInformation.uidDriver}");
    int index = nearbyOnlineDriversList.indexWhere((driver) => driver.uidDriver == nearbyOnlineDriverInformation.uidDriver);

    // Check if the driver exists in the list
    if (index != -1) {
      nearbyOnlineDriversList[index].latDriver = nearbyOnlineDriverInformation.latDriver;
      nearbyOnlineDriversList[index].lngDriver = nearbyOnlineDriverInformation.lngDriver;
    } else {
      // If the driver does not exist, add it to the list
      nearbyOnlineDriversList.add(nearbyOnlineDriverInformation);
    }
  }


}