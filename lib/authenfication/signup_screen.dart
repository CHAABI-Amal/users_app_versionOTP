import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:users_app/authenfication/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController userNametextEditingController = TextEditingController();
  TextEditingController userPhonetextEditingController = TextEditingController();
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();

  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String urlOfUploadedImage = "";
  String verificationId = "";
  String smsCode = "";

  bool isOtpSent = false;

  // Check Internet Connection
  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);

    if (imageFile != null) {
      signUpFromValidation();
    } else {
      cMethods.displaySnackBar("Please choose image first.", context);
    }
  }

  signUpFromValidation() {
    if (userNametextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar("Your name must be at least 4 or more characters", context);
    } else if (userPhonetextEditingController.text.trim().length < 7) {
      cMethods.displaySnackBar("Your phone number must be at least 8 or more characters", context);
    } else if (!emailtextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Please write a valid email", context);
    } else if (passwordtextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar("Your password must be at least 6 or more characters", context);
    } else {
      verifyPhoneNumber();
    }
  }

  verifyPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: userPhonetextEditingController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification
        await FirebaseAuth.instance.signInWithCredential(credential);
        uploadImageToStorage();
      },
      verificationFailed: (FirebaseAuthException e) {
        cMethods.displaySnackBar("Verification Failed. Try again.", context);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
          isOtpSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
      },
    );
  }

  uploadImageToStorage() async {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);
    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });

    registerNewUser();
  }

  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Registering your account..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailtextEditingController.text.trim(),
          password: passwordtextEditingController.text.trim(),
        ).catchError((errorMsg) {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);

      Map userDataMap = {
        "photo": urlOfUploadedImage,
        "name": userNametextEditingController.text.trim(),
        "email": emailtextEditingController.text.trim(),
        "phone": userPhonetextEditingController.text.trim(),
        "id": userFirebase.uid,
        "blockStatus": "no",
      };

      usersRef.set(userDataMap);

      Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));
    } else {
      Navigator.pop(context);
      cMethods.displaySnackBar("Account registration failed.", context);
    }
  }

  chooseImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                "",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              imageFile == null
                  ? const CircleAvatar(
                radius: 86,
                backgroundImage: AssetImage("assets/images/avatarnor.png"),
              )
                  : Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: FileImage(File(imageFile!.path)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  chooseImageFromGallery();
                },
                child: const Text(
                  "Choose Image",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: userNametextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Name",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: userPhonetextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "User Phone",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: emailtextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "User Email",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: passwordtextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Password",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    const SizedBox(height: 32),
                    if (isOtpSent)
                      Column(
                        children: [
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Enter OTP",
                              labelStyle: TextStyle(fontSize: 14),
                            ),
                            onChanged: (value) {
                              smsCode = value;
                            },
                            style: const TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          const SizedBox(height: 22),
                          ElevatedButton(
                            onPressed: () async {
                              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                                verificationId: verificationId,
                                smsCode: smsCode,
                              );
                              await FirebaseAuth.instance.signInWithCredential(credential);
                              uploadImageToStorage();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                            ),
                            child: const Text("Verify OTP"),
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          checkIfNetworkIsAvailable();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                        ),
                        child: const Text("Sign Up"),
                      ),
                  ],
                ),
              ),


              const SizedBox(height: 12,),

              //Text Button
              TextButton(
                onPressed:(){
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));

                },
                child: Text(
                  "Already have an Account? Login Here",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


}
