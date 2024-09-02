import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:khwahish_provider/Screens/Auth/login.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/style.dart';

Future<String?> logoutBuilder(BuildContext context) {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      title: Text('Logout', style: kHeaderStyle()),
      content: Text('Are you sure you want to logout?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            FirebaseAuth.instance.signOut();
            ServiceManager().removeUser();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) => Login()), (route) => false);
            try {
              await _auth.signOut();
              _googleSignIn.disconnect();
            } catch (e) {
              print("Error signing out: $e");
            }
          },
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}
