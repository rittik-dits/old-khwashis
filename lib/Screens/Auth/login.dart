import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Auth/forgetPassword.dart';
import 'package:khwahish_provider/Screens/Auth/registration.dart';
import 'package:khwahish_provider/Screens/navigationScreen.dart';
import 'package:khwahish_provider/Services/emailController.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController number = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    getToken();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  String firebaseFCMToken = '';
  void getToken() async {
    firebaseFCMToken = (await FirebaseMessaging.instance.getToken())!;
  }

  bool buttonEnabled = false;
  bool textObscure = true;
  bool isLoading = false;

  Future<void> signInWithEmailAndPassword(context,
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        var collection = FirebaseFirestore.instance.collection('provider');
        var docSnapshot = await collection.doc(user.uid).get();
        if (docSnapshot.exists) {
          ServiceManager().setUser(user.uid);
          ServiceManager().getUserID();
          ServiceManager.userID = user.uid;
          toastMessage(message: 'Logged In');
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => NavigationScreen()),
              (route) => false);
        } else {
          toastMessage(message: 'Invalid email or password', colors: kRedColor);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        toastMessage(message: 'Invalid email or password', colors: kRedColor);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      toastMessage(message: 'Invalid email or password', colors: kRedColor);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBackgroundDesign(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Image.asset('images/app_logo.png'),
              ),
              SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    KTextField(
                      title: 'Email',
                      controller: email,
                    ),
                    KTextField(
                      title: 'Password',
                      controller: password,
                      obscureText: textObscure,
                      suffixButton: IconButton(
                        onPressed: () {
                          setState(() {
                            textObscure = !textObscure;
                          });
                        },
                        icon: Icon(textObscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                    ),
                    // SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgetPassword()));
                      },
                      child: Text(
                        'Forget Password?',
                        style: TextStyle(color: kRedColor),
                      ),
                    ),
                    // if(buttonEnabled)
                    isLoading != true
                        ? KButton(
                            title: 'Continue',
                            onClick: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                signInWithEmailAndPassword(
                                  context,
                                  email: email.text,
                                  password: password.text,
                                );
                              }
                            },
                          )
                        : LoadingButton(),
                    SizedBox(height: 20.0),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(color: Colors.black54),
                        children: <TextSpan>[
                          TextSpan(text: 'Not a registered user ? '),
                          TextSpan(
                            text: 'Sign up',
                            style: linkTextStyle(),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Registration()));
                              },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.grey.shade900),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    LoginButton(
                      title: 'Continue with Google',
                      image: 'images/icn_google.png',
                      onClick: () async {
                        final user = await _handleSignIn();
                        if (user != null) {
                          createOrLoginUser(context, user);
                        } else {
                          toastMessage(
                              message:
                                  'Sign in with Google canceled or failed.',
                              colors: kRedColor);
                        }
                      },
                    ),
                    kSpace(),
                    if (Platform.isIOS)
                      LoginButton(
                        title: 'Continue with Apple',
                        image: 'images/apple.png',
                        onClick: () async {
                          try {
                            final credential =
                                await SignInWithApple.getAppleIDCredential(
                              scopes: [
                                AppleIDAuthorizationScopes.email,
                                AppleIDAuthorizationScopes.fullName,
                              ],
                            );
                            final oauthProvider = OAuthProvider('apple.com');
                            final userCredential = await FirebaseAuth.instance
                                .signInWithCredential(
                              oauthProvider.credential(
                                idToken: credential.identityToken,
                                accessToken: credential.authorizationCode,
                              ),
                            );
                            createOrLoginUser(context, userCredential.user);
                          } catch (error) {
                            print(error);
                          }

                          // final AuthorizationCredentialAppleID appleIdCredential = await SignInWithApple.getAppleIDCredential(
                          //   scopes: [
                          //     AppleIDAuthorizationScopes.email,
                          //     AppleIDAuthorizationScopes.fullName,
                          //   ],
                          // );
                          // print(appleIdCredential);
                          // loginOrRegisterApple('${appleIdCredential.email}', '${appleIdCredential.givenName} ${appleIdCredential.familyName}');
                        },
                      ),
                    kBottomSpace(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(width: 1),
          ),
          child: MaterialButton(
            minWidth: 70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () {
              setState(() {
                ServiceManager.userID = '';
                ServiceManager.userName = '';
                ServiceManager.profileURL = '';
              });
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NavigationScreen()));
            },
            child: Text('Skip'),
          ),
        ),
      ),
    );
  }

  Future<User?> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = kIsWeb
          ? await (_googleSignIn.signInSilently())
          : await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the Google Sign In process
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      return user;
    } catch (error) {
      print("Error signing in with Google: $error");
      return null;
    }
  }

  Future<bool> doesDocumentExist(
      String collectionName, String documentId) async {
    final DocumentReference docRef =
        FirebaseFirestore.instance.collection(collectionName).doc(documentId);

    final DocumentSnapshot doc = await docRef.get();
    return doc.exists;
  }

  void createOrLoginUser(context, user) async {
    bool exists = await doesDocumentExist('provider', user.uid);

    if (exists) {
      ServiceManager().setUser(user.uid);
      ServiceManager().getUserID();
      toastMessage(message: 'Logged In');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => NavigationScreen()),
          (route) => false);
    } else {
      _firestore.collection('provider').doc(user.uid).set({
        'FCM': firebaseFCMToken,
        'aadhaar': '',
        'aadhaarBackImage': '',
        'aadhaarFrontImage': '',
        'acceptOnlyInWorkArea': false,
        'acceptPaymentInCash': true,
        'addon': [],
        'address': '',
        'articles': [],
        'artistAddress': '',
        'audioGallery': [],
        'available': true,
        'category': [],
        'cityID': '',
        'dateOfBirth': '',
        'desc': [
          {
            'code': '',
            'text': '',
          }
        ],
        'descTitle': [
          {
            'code': '',
            'text': '',
          }
        ],
        'email': user.email,
        'facebook': '',
        'firstName': ServiceManager().getFirstName('${user.displayName}'),
        'followers': [],
        'following': [],
        'gallery': [],
        'galleryVideos': [],
        'gender': '',
        'imageUpperLocalFile': '',
        'imageUpperServerPath': '',
        'instagram': '',
        'isSubscribed': false,
        'isVerified': false,
        'lastName': ServiceManager().getLastName('${user.displayName}'),
        'login': '${user.email}',
        'logoLocalFile': '',
        'logoServerPath': user.photoURL,
        'middleName': ServiceManager().getMiddleName('${user.displayName}'),
        'monthlyIncome': 0,
        'name': '${user.displayName}',
        'panCard': '',
        'panCardImage': '',
        'passport': '',
        'passportImage': '',
        'phone': '',
        'referral': '',
        'route': [],
        'selectedState': '',
        'subscriptionStartDate': '',
        'subscriptionEndDate': '',
        'tax': '',
        'testimonial': [],
        'telegram': '',
        'visible': true,
        'workTime': [],
        'www': '',
        'avgRating': 0,
        'totalRating': 0,
        'todayIncome': 0,
        'weeklyIncome': 0,
        'todaysBooking': 0,
        'weekBooking': 0,
        'totalCash': 0,
        'twitter': '',
      }).then((value) => {
            ServiceManager().setUser(user.uid),
            ServiceManager().getUserID(),
            toastMessage(message: 'Logged In'),
            EmailController().sendMail(
                recipientEmail: EmailController.adminEmail,
                mailMessage: 'I have registered to khwahish successfully as an '
                    'artist and would like to perform as an artist with your connection.'
                    '\n UserID: ${user.uid}'),
            EmailController().sendMail(
              recipientEmail: user.email.toString(),
              mailMessage: 'You have registered to khwahish successfully as an '
                  'artist and you are ready to perform as an artist.',
            ),
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => NavigationScreen()),
                (route) => false),
          });
    }
  }
}
