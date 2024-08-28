import 'package:flutter/material.dart';
import '../models/online_nearby_drivers.dart';

class SelectNearestActiveDriversScreen extends StatelessWidget {
  final List<OnlineNearbyDrivers> availableDrivers;
  final Function(OnlineNearbyDrivers) onDriverSelected;

  SelectNearestActiveDriversScreen({
    required this.availableDrivers,
    required this.onDriverSelected,
  });

  // Convert color name to Flutter color
  Color _getColorFromName(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
        return Colors.grey;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey; // Default color if color name is unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Select a Driver',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: availableDrivers.length,
        itemBuilder: (context, index) {
          OnlineNearbyDrivers driver = availableDrivers[index];

          // Print the driver's name
          print("Driver Name: ${driver.nameDriver}");

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(driver.photoDriver ?? ''),
                        radius: 30,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.nameDriver ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  '${driver.driverRatings ?? '0.00'}',
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  '${driver.fareAmount ?? '0.00'}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          onDriverSelected(driver);
                        },
                        child: const Icon(Icons.check, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.directions_car, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        driver.carModelDriver ?? 'N/A',
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.color_lens,
                        color: _getColorFromName(driver.carColorDriver),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        driver.carColorDriver ?? 'N/A',
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.confirmation_number, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        driver.carNumberDriver ?? 'N/A',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
