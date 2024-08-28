import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // For clipboard functionality

class RedeemCoupon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color changed to white
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar background color changed to white
        elevation: 0,
        title: Text(
          "Redeem Coupon",
          style: GoogleFonts.poppins(
            color: Colors.black, // Title color changed to black
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Icon color changed to black
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Offers",
                style: GoogleFonts.poppins(
                  color: Colors.black, // Text color changed to black
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            couponCard(
              context: context, // Passing context to the method
              discount: "Get 20% off for you",
              code: "GET15OFF",
              validUntil: "Valid til 31 May, 2023",
            ),
            couponCard(
              context: context, // Passing context to the method
              discount: "Get 10% off on your 10th order",
              code: "FD520K02",
              validUntil: "Valid til 31 May, 2023",
            ),
            couponCard(
              context: context, // Passing context to the method
              discount: "Get 15% off on your first order",
              code: "NEW15OFF",
              validUntil: "Valid til 31 May, 2023",
            ),
            SizedBox(height: 20),
            TextField(
              style: GoogleFonts.poppins(color: Colors.black), // TextField text color changed to black
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200], // TextField background color changed to light grey
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: "Write coupon code",
                hintStyle: GoogleFonts.poppins(color: Colors.grey[600]), // Hint text color changed to darker grey
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle apply coupon logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                "APPLY",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Button text color changed to white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget couponCard({
    required BuildContext context, // Adding BuildContext as a parameter
    required String discount,
    required String code,
    required String validUntil,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Card background color remains white
          borderRadius: BorderRadius.circular(12),
          boxShadow: [ // Optional: Add shadow for better visibility
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              discount,
              style: GoogleFonts.poppins(
                color: Colors.black, // Discount text color changed to black
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              validUntil,
              style: GoogleFonts.poppins(
                color: Colors.black54, // Valid Until text color changed to dark grey
                fontSize: 12,
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  code,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black, // Coupon code text color changed to black
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Coupon code copied to clipboard')),
                    );
                  },
                  child: Text(
                    "Tap to Copy",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blueAccent, // "Tap to Copy" text color remains the same
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
