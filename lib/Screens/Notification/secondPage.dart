import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {

  final String? payload;
  SecondPage({required this.payload, Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.payload ?? '', style: TextStyle(fontSize: 48),),
            SizedBox(height: 24),
            Text('Payload'),
          ],
        ),
      ),
    );
  }
}
