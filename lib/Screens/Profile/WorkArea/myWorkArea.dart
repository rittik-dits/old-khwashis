import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/DialogueBox/deletePopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Profile/WorkArea/mapWorkArea.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class MyWorkArea extends StatefulWidget {
  const MyWorkArea({super.key});

  @override
  State<MyWorkArea> createState() => _MyWorkAreaState();
}

class _MyWorkAreaState extends State<MyWorkArea> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Work Area'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('provider').doc(ServiceManager.userID).collection('workArea').snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            var data = snapshot.data!.docs;
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  data.isNotEmpty ?
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemCount: data.length,
                    itemBuilder: (context, index){
                      return Container(
                        padding: EdgeInsets.only(left: 10),
                        decoration: roundedContainerDesign(context),
                        child: Row(
                          children: [
                            Expanded(child: Text('${data[index]['cityName']}')),
                            IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => MapWorkArea(
                                      workAreaID: data[index].reference.id,
                                    )));
                              },
                              icon: Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              onPressed: (){
                                deletePopUp(context, onClickYes: (){
                                  _firestore.collection('provider').doc(ServiceManager.userID)
                                      .collection('workArea').doc(data[index].reference.id).delete();
                                  Navigator.pop(context);
                                });
                              },
                              icon: Icon(Icons.delete_forever_outlined, color: kRedColor),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 10);
                    },
                  ) : EmptyScreen(message: 'No Work Area Found'),
                  kSpace(),
                  kBottomSpace(),
                ],
              ),
            );
          }
          return LoadingIcon();
        }
      ),
      floatingActionButton: KButton(
        title: 'Add Work Area',
        onClick: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => MapWorkArea()));
        },
      ),
    );
  }
}
