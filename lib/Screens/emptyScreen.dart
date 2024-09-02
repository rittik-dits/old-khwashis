import 'package:flutter/material.dart';
import 'package:khwahish_provider/Theme/style.dart';

class EmptyScreen extends StatelessWidget {

  String message;
  EmptyScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/notfound.png', height: 200),
          Text(message, style: kHeaderStyle()),
        ],
      ),
    );
  }
}
