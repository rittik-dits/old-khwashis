import 'package:flutter/material.dart';
import 'package:khwahish_provider/Screens/navigationScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:pinput/pinput.dart';

class Verification extends StatefulWidget {

  String phoneNumber;
  Verification({super.key, required this.phoneNumber});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {

  @override
  void initState() {
    super.initState();
    // ServiceManager().verifyPhoneNumber('phoneNumber');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text('Enter verification code', style: kLargeStyle()),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('We have sent you a 4 digit verification code on the given mobile number', textAlign: TextAlign.center,),
          ),
          Pinput(
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            // validator: (s) {
            //   return s == '2222' ? null : 'Pin is incorrect';
            // },
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
            onCompleted: (pin){
              print(pin);
              ServiceManager().getUserData().then((value) => {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (context) => NavigationScreen()), (route) => false),
              });
            },
          ),
        ],
      ),
    );
  }
}

final defaultPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
  decoration: BoxDecoration(
    border: Border.all(color: Color.fromRGBO(40, 79, 108, 1.0)),
    borderRadius: BorderRadius.circular(20),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
  borderRadius: BorderRadius.circular(8),
);

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration!.copyWith(
    color: Color.fromRGBO(234, 239, 243, 1),
  ),
);
