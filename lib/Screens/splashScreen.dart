import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Screens/navigationScreen.dart';
import 'package:khwahish_provider/Screens/onBoardingPage.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/style.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    ServiceManager().getUserID();
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if(ServiceManager.userID != ''){
        ServiceManager().getUserData();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) => NavigationScreen()), (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) => OnBoardingPage()), (route) => false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if(_timer!.isActive) _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kBackgroundDesign(context),
        // child: Center(child: Image.asset('images/app_logo.png', height: 150)),
        child: Center(child: Image.asset('images/khwahish_gif.gif')),
      ),
    );
  }
}
