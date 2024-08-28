import 'package:flutter/material.dart';

class SafetyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top buttons: Support and Emergency contacts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTopButton('Support', Icons.support),
                _buildTopButton('Emergency contacts', Icons.contact_phone),
              ],
            ),
            SizedBox(height: 16.0),

            // Call emergency button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () {},
              icon: Icon(Icons.warning),
              label: Text('Call emergency'),
            ),
            SizedBox(height: 16.0),

            // How you're protected section
            Text(
              'How you\'re protected',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),

            // Safety features grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildSafetyFeature('Before the ride', Icons.timer),
                  _buildSafetyFeature(
                      'Driver identity and selfie verification',
                      Icons.verified_user),
                  _buildSafetyFeature('Safety features', Icons.security),
                  _buildSafetyFeature('24/7 emergency chat', Icons.chat),
                  _buildSafetyFeature('How we check cars', Icons.car_repair),
                  _buildSafetyFeature(
                      'Safe communications', Icons.sms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopButton(String label, IconData icon) {
    return Expanded(
      child: Container(
        height: 100.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
          ),
          onPressed: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36.0, color: Colors.black),
              SizedBox(height: 8.0),
              Text(
                label,
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyFeature(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40.0, color: Colors.green),
          SizedBox(height: 16.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
