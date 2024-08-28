import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:users_app/global/global_var.dart';

import '../authenfication/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController photoTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();

  setDriverInfo() {
    setState(() {
      nameTextEditingController.text = userName; // Example Name
      phoneTextEditingController.text = userPhone; // Example Phone
      photoTextEditingController.text = userPhoto;
      emailTextEditingController.text = userEmail; // Example Email
    });
  }

  @override
  void initState() {
    super.initState();
    setDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {
              // Help button logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Image Placeholder
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(userPhoto ?? 'assets/images/girl.png'),
                backgroundColor: Colors.grey.shade300,
                child: userPhoto == null
                    ? Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),

              const SizedBox(height: 10),
              Text(
                userPhone, // Example Phone
                style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),

              const SizedBox(height: 30),

              // Full Name Field
              buildProfileInfoTile("Full Name", nameTextEditingController.text),

              // Email Field
              buildProfileInfoTile("Email", emailTextEditingController.text),

              // Gender Field
              buildProfileInfoTile("Gender", "Male"),

              // Date of Birth Field
             // buildProfileInfoTile("Date Of Birth", ""),

              const SizedBox(height: 30),

              // Log Out Button
              buildProfileButton("Log out", Colors.red, () {
                FirebaseAuth.instance.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                // Log out logic
              }),

              const SizedBox(height: 10),

              // Delete Account Button
              buildProfileButton("Delete Account", Colors.red, () {
                Navigator.pop(context);
                // Delete account logic
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileInfoTile(String title, String value) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          trailing: Text(value, style: const TextStyle(fontSize: 16)),
          onTap: () {
            // Navigation logic to edit the value
          },
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget buildProfileButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: color, backgroundColor: Colors.transparent,
        elevation: 0,
        side: BorderSide(color: color),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ),
    );
  }
}
