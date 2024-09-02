import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/util.dart';

class TermAndCondition extends StatefulWidget {
  const TermAndCondition({super.key});

  @override
  State<TermAndCondition> createState() => _TermAndConditionState();
}

class _TermAndConditionState extends State<TermAndCondition> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and condition'),
      ),
      body: StreamBuilder(
          stream: _firestore.collection('settings').doc('main').snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              var data = snapshot.data!.data();
              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                physics: BouncingScrollPhysics(),
                itemCount: data!['terms'].length,
                itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text('${data['terms'][index]}'),
                  );
                },
              );
            }
            return LoadingIcon();
          }
      ),
    );
  }
}
