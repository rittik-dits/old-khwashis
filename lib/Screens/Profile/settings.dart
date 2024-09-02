import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/style.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool minimumOrder = false;
  bool maximumOrder = false;
  bool acceptOnlyInWorkArea = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    var collection = _firestore.collection('provider');
    var docs = await collection.doc(ServiceManager.userID).get();
    if(docs.exists){
      acceptOnlyInWorkArea = docs['acceptOnlyInWorkArea'];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Text('Minimum order amount', style: kSmallText()),
            //       ),
            //       CupertinoSwitch(
            //         value: minimumOrder,
            //         onChanged: (value){
            //           setState(() {
            //             minimumOrder = value;
            //           });
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            // KTextField(
            //   title: 'Minimum order amount',
            //   textInputType: TextInputType.number,
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Text('Maximum order amount', style: kSmallText()),
            //       ),
            //       CupertinoSwitch(
            //         value: maximumOrder,
            //         onChanged: (value){
            //           setState(() {
            //             maximumOrder = value;
            //           });
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            // KTextField(
            //   title: 'Maximum order amount',
            //   textInputType: TextInputType.number,
            // ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Allow booking only if customer located in my work area', style: kSmallText()),
                  ),
                  CupertinoSwitch(
                    value: acceptOnlyInWorkArea,
                    onChanged: (value){
                      setState(() {
                        acceptOnlyInWorkArea = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: KButton(
        title: 'Save',
        onClick: (){
          Navigator.pop(context);
          setState(() {
            isLoading = true;
          });
          updateUserData();
        },
      ),
    );
  }

  void updateUserData(){
    _firestore.collection('provider').doc(ServiceManager.userID).update({
      'acceptOnlyInWorkArea': acceptOnlyInWorkArea,
    }).then((value) => {
      toastMessage(message: 'Data Updated'),
      Navigator.pop(context),
    });
  }
}
