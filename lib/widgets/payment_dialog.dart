import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

import '../methods/common_methods.dart';

class PaymentDialog extends StatefulWidget {
  final String fareAmount;

  PaymentDialog({super.key, required this.fareAmount});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),

                const Text(
                  "PAY CASH",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                Divider(
                  height: 1.5,
                  color: Colors.grey.shade300,
                  thickness: 1.0,
                ),

                const SizedBox(height: 16),

                Text(
                  widget.fareAmount + " DH",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "This is the fare amount ( ${widget.fareAmount} DH ) you have to pay to the driver.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                 // Navigator.pop(context);
                //  Navigator.pop(context);
                  Navigator.pop(context, "paid");
                  cMethods.turnOnLocationUpdatesHomePage();
                  Restart.restartApp();
                  // Supprimez temporairement cette ligne pour tester
                 // Restart.restartApp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "PAY CASH",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),


              const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
