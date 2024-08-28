import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  final DatabaseReference completedTripRequestsRef = FirebaseDatabase.instance.ref().child("tripRequests");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Trips History',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'CuteFont', // Apply custom cute font
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor: Colors.white, // App bar background color
        elevation: 0, // Remove app bar shadow for a cleaner look
      ),
      body: StreamBuilder(
        stream: completedTripRequestsRef
            .orderByChild("publishDateTime") // Order by publishDateTime
            .onValue,
        builder: (BuildContext context, snapshotData) {
          if (snapshotData.hasError) {
            return const Center(
              child: Text(
                "Error Occurred.",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!(snapshotData.hasData) || snapshotData.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                "No record found.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          Map dataTrips = snapshotData.data!.snapshot.value as Map;
          List tripsList = [];
          dataTrips.forEach((key, value) {
            if (value["status"] == "ended" && value["userID"] == FirebaseAuth.instance.currentUser!.uid) {
              tripsList.add({"key": key, ...value});
            }
          });

          // Sort the list by publishDateTime
          tripsList.sort((a, b) {
            DateTime dateTimeA = DateTime.parse(a["publishDateTime"]);
            DateTime dateTimeB = DateTime.parse(b["publishDateTime"]);
            return dateTimeB.compareTo(dateTimeA); // Descending order
          });

          return ListView.builder(
            shrinkWrap: true,
            itemCount: tripsList.length,
            itemBuilder: ((context, index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white, // Card background color
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup - fare amount
                      Row(
                        children: [
                          Image.asset('assets/images/initial.png', height: 16, width: 16),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              tripsList[index]["pickUpAddress"].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black, // Updated text color
                                fontFamily: 'CuteFont', // Apply custom cute font
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${tripsList[index]["fareAmount"].toString()} MAD",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green, // Bold green color for money
                              fontFamily: 'CuteFont', // Apply custom cute font
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Dropoff
                      Row(
                        children: [
                          Image.asset('assets/images/final.png', height: 16, width: 16),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              tripsList[index]["dropOffAddress"].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black, // Updated text color
                                fontFamily: 'CuteFont', // Apply custom cute font
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
