import 'package:flutter/material.dart';
import 'package:users_app/authenfication/login_screen.dart' as auth;
import 'package:google_fonts/google_fonts.dart'; // Prefix for the login screen from the authentication file

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light Mode';

  void _changeLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  void _changeTheme(String theme) {
    setState(() {
      _selectedTheme = theme;
    });
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Delete Account',
            style: GoogleFonts.poppins(
              color: Colors.black, // Title color set to black
            ),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: GoogleFonts.poppins(
              color: Colors.grey, // Content color set to black
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.blueAccent, // Button text color set to black
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Logic to delete the account and navigate to the login screen
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => auth.LoginScreen(), // Use prefix here
                ));
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: Colors.red, // Button text color set to black
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            color: Colors.black, // Title color set to black
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingOption(
              icon: Icons.language,
              iconColor: Colors.purple,
              title: 'Language',
              value: _selectedLanguage,
              onTap: () => _showLanguagePicker(),
            ),
            _buildSettingOption(
              icon: Icons.brightness_6,
              iconColor: Colors.grey,
              title: 'Light/dark mode',
              value: _selectedTheme,
              onTap: () => _showThemePicker(),
            ),
            SizedBox(height: 20),
            _buildDeleteAccountOption(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.black, // Set the color to black
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.black, // Set the color to black
            ),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.black), // Set the color to black
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDeleteAccountOption() {
    return ListTile(
      leading: Icon(Icons.delete, color: Colors.red),
      title: Text(
        'Delete Account',
        style: GoogleFonts.poppins(
          color: Colors.black, // Set the color to black
        ),
      ),
      onTap: _deleteAccount,
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black, // Background color of the picker
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  'English',
                  style: GoogleFonts.poppins(
                    color: Colors.white, // Text color set to white
                  ),
                ),
                onTap: () => _changeLanguage('English'),
              ),
              ListTile(
                title: Text(
                  'Français',
                  style: GoogleFonts.poppins(
                    color: Colors.white, // Text color set to white
                  ),
                ),
                onTap: () => _changeLanguage('Français'),
              ),
              ListTile(
                title: Text(
                  'العربية',
                  style: GoogleFonts.poppins(
                    color: Colors.white, // Text color set to white
                  ),
                ),
                onTap: () => _changeLanguage('العربية'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black, // Background color of the picker
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Light Mode',
                  style: GoogleFonts.poppins(
                    color: Colors.white, // Text color set to white
                  ),
                ),
                onTap: () => _changeTheme('Light Mode'),
              ),
              ListTile(
                title: Text(
                  'Dark Mode',
                  style: GoogleFonts.poppins(
                    color: Colors.white, // Text color set to white
                  ),
                ),
                onTap: () => _changeTheme('Dark Mode'),
              ),
            ],
          ),
        );
      },
    );
  }
}
