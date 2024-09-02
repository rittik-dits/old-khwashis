import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Screens/Auth/login.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/intro/intro.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      floatingActionButton: KButton(
        title: 'Continue',
        onClick: (){
          _onIntroEnd(context);
        },
      ),
    );
  }
}
