import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/appinfo/app_info.dart';
import 'package:users_app/authenfication/login_screen.dart';
import 'package:users_app/authenfication/signup_screen.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/authenfication/opt.dart';
import 'package:users_app/authenfication/phone.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
      Permission.locationWhenInUse.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Flutter USER APP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null ? 'login' : 'home',
        routes: {
          'phone': (context) => MyPhone(),
          //'otp': (context) => MyVerify(),
          'home': (context) => HomePage(),
          'login': (context) => LoginScreen(),
          'signup':(context) => SignupScreen(),
        },
      ),
    );
  }
}
