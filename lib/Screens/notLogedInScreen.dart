import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Screens/Auth/login.dart';
import 'package:khwahish_provider/Theme/style.dart';

class NotLoggedInScreen extends StatelessWidget {
  const NotLoggedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/notfound.png', height: 200),
          Text('You are not logged in', style: kHeaderStyle()),
          kSpace(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: KButton(
              title: 'Login Now',
              onClick: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
