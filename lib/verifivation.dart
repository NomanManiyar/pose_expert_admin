import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pose_expert_admin/home.dart';

class Verification extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  String phoneNo;
  String veificationID;
  String smsCode;
  bool _visibility = false;
  String error = "";
  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        ConnectivityResult connectivity,
        Widget child,
      ) {
        if (connectivity == ConnectivityResult.none) {
          return Scaffold(
            body: Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  "Oops, \n\nNow we are Offline!\nPlease connect to Internet",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          );
        } else {
          return child;
        }
      },
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Login"),
          ),
          backgroundColor: Colors.tealAccent[300],
          body: SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                      prefixText: "+91", hintText: "Enter Phone Number"),
                  onChanged: (value) {
                    this.phoneNo = "+91" + value;
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                elevation: 10,
                color: Colors.black,
                textColor: Colors.white,
                onPressed: verifyPhone,
                child: Text("Send Otp"),
              )
            ],
          )),
        );
      },
    );
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verID) {
      this.veificationID = verID;
    };

    final PhoneCodeSent phoneCodeSent = (String verId, [int forceCodeResend]) {
      this.veificationID = verId;
      smsCodeDialog(context).then((onValue) {
        print("signIn");
      });
    };

    final PhoneVerificationCompleted phoneVerificationCompleted =
        (AuthCredential authCredential) {
      print("authcredential: $authCredential");
    };

    final PhoneVerificationFailed phoneVerificationFailed =
        (AuthException authException) {
      print("authException: ${authException.message}");
    };

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: this.phoneNo,
          timeout: Duration(minutes: 2),
          verificationCompleted: phoneVerificationCompleted,
          verificationFailed: phoneVerificationFailed,
          codeSent: phoneCodeSent,
          codeAutoRetrievalTimeout: autoRetrievalTimeout);
    } catch (e) {
      print("Error: " + e.toString());
      handleError(e);
    }
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Sms Code"),
            content: Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PinEntryTextField(
                    fields: 6,
                    fieldWidth: 30.0,
                    onSubmit: (String pin) {
                      this.smsCode = pin;
                      FirebaseAuth.instance.currentUser().then((user) {
                        if (user != null) {
                          setState(() {
                            _visibility = true;
                          });
                          print("Got $user");
                          Navigator.pop(context);
                          setState(() {
                            _visibility = false;
                          });
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return Home(
                              phoneNO: user.phoneNumber.toString(),
                            );
                          }));
                        } else {
                          setState(() {
                            _visibility = true;
                          });

                          signIn();
                        }
                      });
                    }, // end onSubmit
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  error != ""
                      ? Text(
                          error,
                          style: TextStyle(color: Colors.red),
                        )
                      : Container(),
                  Visibility(
                    visible: _visibility,
                    child: SpinKitDoubleBounce(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            contentPadding: const EdgeInsets.all(10),
          );
        });
  }

  void signIn() async {
    AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: veificationID, smsCode: smsCode);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential).then((user) {
        print("new User Created");
        setState(() {
          _visibility = false;
        });
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return Home(
            phoneNO: user.user.phoneNumber.toString(),
          );
        }));
      }).catchError((e) {
        setState(() {
          _visibility = false;
        });
        print("SignIn ERROR: ${e.toString()}");
      });
    } catch (e) {
      handleError(e);
      // if (!mounted) return;
      print("SignIn ERROR: ${e.toString()}");
    }
  }

  handleError(PlatformException peError) {
    setState(() {
      _visibility = false;
    });
    print(error);
    switch (peError.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          error = "Invalid Code";
        });
        Navigator.of(context).pop();
        smsCodeDialog(context).then((value) {
          print('sign in');
        });
        break;
      default:
        break;
    }
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:flutter/material.dart';
// import 'package:pose_expert_admin/home.dart';

// enum PhoneAuthState {
//   Started,
//   CodeSent,
//   CodeResent,
//   Verified,
//   Failed,
//   Error,
//   AutoRetrievalTimeOut
// }

// class Verification extends StatefulWidget {
//   @override
//   _VerificationState createState() => _VerificationState();
// }

// class _VerificationState extends State<Verification> {
//   TextEditingController phoneNoController = TextEditingController();
//   FirebaseAuth _auth = FirebaseAuth.instance;
//   bool isChecking = false;
//   String verificationId;
//   var phoneNo;
//   String smsOTP;
//   bool _visibility = false;

//   String errorMessage = "";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.deepPurple[400],
//       body: SafeArea(
//         child: Stack(children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Center(
//               child: TextFormField(
//                 controller: phoneNoController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.grey.withOpacity(0.5),
//                     hintText: "Enter Phone Number"),
//               ),
//             ),
//           ),
//           Align(
//               alignment: Alignment.bottomCenter,
//               child: FlatButton(
//                   color: Colors.deepPurple,
//                   onPressed: () {
//                     setState(() {
//                       phoneNo = phoneNoController.text;
//                     });
//                     verifyPhone();
//                   },
//                   child: Text("Send Otp")))
//         ]),
//       ),
//     );
//   }

//   Future<void> verifyPhone() async {
//     setState(() {
//       isChecking = true;
//     });
//     final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
//       this.verificationId = verId;
//       smsOTPDialog(context).then((value) {
//         print('sign in');
//       });
//     };
//     try {
//       await _auth.verifyPhoneNumber(
//           phoneNumber: this.phoneNo, // PHONE NUMBER TO SEND OTP
//           codeAutoRetrievalTimeout: (String verId) {
//             //Starts the phone number verification process for the given phone number.
//             //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
//             this.verificationId = verId;
//           },
//           codeSent:
//               smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
//           timeout: const Duration(seconds: 120),
//           verificationCompleted: (AuthCredential phoneAuthCredential) {
//             print(phoneAuthCredential);
//           },
//           verificationFailed: (AuthException exceptio) {
//             print('${exceptio.message}');
//             setState(() {
//               isChecking = false;
//             });
//           });
//     } catch (e) {
//       handleError(e);
//       setState(() {
//         isChecking = false;
//       });
//     }
//   }

//   Future<bool> smsOTPDialog(BuildContext context) {
//     return showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             content: Container(
//               alignment: Alignment.center,
//               width: MediaQuery.of(context).size.width,
//               height: 200,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Enter SMS Code',
//                       style: TextStyle(
//                         fontFamily: 'muli',
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
// SizedBox(
//   height: 10,
// ),
//                     (errorMessage != ''
//                         ? Text(
//                             errorMessage,
//                             style: TextStyle(color: Colors.red),
//                           )
//                         : Container()),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Visibility(
//                       visible: _visibility,
//                       child: SpinKitDoubleBounce(
//                         color: Colors.black,
//                       ),
//                     ),
//                   ]),
//             ),
//             contentPadding: EdgeInsets.all(10),
//           );
//         });
//   }

//   void handleError(e) {
//     setState(() {
//       errorMessage = "somthing went worng";
//     });
//     print("Error: $e ");
//   }
// signOut()async{
// FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//     FirebaseUser user = await firebaseAuth.currentUser();
//   if(user!=null)
//   {

//   }
// }
//   signIn() async {
//     FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//     FirebaseUser user = await firebaseAuth.currentUser();

//     try {
//       if (user != null) {
//         print("got user");
//         Navigator.of(context).pop();
//         Firestore.instance
//             .collection("user")
//             .document(user.phoneNumber.toString())
//             .setData({'phoneNo': user.phoneNumber.toString()});
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => Home()));
//       } else if (user == null) {
//         print("Null user");
//       }
//     } catch (e) {
//       handleError(e);
//     }
//   }
// }
