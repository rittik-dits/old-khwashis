import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();

  Future resetPassword(context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      Navigator.pop(context);
      toastMessage(message: 'Password reset link was sent to your email', colors: kMainColor);
    } catch (e) {
      toastMessage(message: removeSquareBrackets(e.toString()), colors: kRedColor);
    }
  }

  String removeSquareBrackets(String input) {
    return input.replaceAll(RegExp(r'\[.*?\]'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forget Password'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: KTextField(
                title: 'Email',
                controller: email,
              ),
            ),
            SizedBox(height: 5),
            KButton(
              title: 'Continue',
              onClick: (){
                if(_formKey.currentState!.validate()){
                  resetPassword(context);
                }
              },
            ),
            Text('Password reset link will be send to your email ID',
              style: kSmallText(),
            ),
          ],
        ),
      ),
    );
  }
}
