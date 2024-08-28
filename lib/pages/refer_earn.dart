import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReferAndEarn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background to white
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Refer and Earn",
          style: GoogleFonts.poppins(
            color: Colors.black, // Title color changed to black
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Set arrow icon color to black
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 10),
            Image.asset(
              'assets/images/money_bag.png', // Add your image in assets and name it correctly
              height: 100,
            ),
            SizedBox(height: 10),
            // Change text color to black for visibility
            Text(
              "Refer your friends and",
              style: GoogleFonts.poppins(
                color: Colors.black, // Changed to black
                fontSize: 18,
              ),
            ),
            Text(
              "Earn \$10 each",
              style: GoogleFonts.poppins(
                color: Colors.black, // Changed to black
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Invite Friend & Businesses",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Invite GoRide to sign up using your link and you'll get \$10",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "FD520K02", // Referral code
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle copy functionality
                          },
                          child: Text(
                            "Tap to Copy",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  referStep(icon: Icons.person_add, label: "Invite a Friend"),
                  referStep(icon: Icons.app_registration, label: "They register"),
                  referStep(icon: Icons.card_giftcard, label: "Get Reward"),
                ],
              ),
            ),
            Spacer(),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle referral action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    "REFER FRIEND",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget referStep({required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.black), // Icons with black color
          ),
          SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black, // Text in black
            ),
          ),
        ],
      ),
    );
  }
}
