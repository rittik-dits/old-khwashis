import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/DialogueBox/deletePopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/MyServices/addService.dart';
import 'package:khwahish_provider/Screens/MyServices/editService.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Screens/notLogedInScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class MyServices extends StatefulWidget {
  const MyServices({super.key});

  @override
  State<MyServices> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Services'),
      ),
      body: ServiceManager.userID != '' ? StreamBuilder(
        stream: _firestore.collection('service').orderBy('timeModify').snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            var data = snapshot.data!.docs;
            List items = [];
            for(var item in data){
              if(item['providers'].contains(ServiceManager.userID)){
                items.add(item);
              }
            }
            return items.isNotEmpty ? ListView.separated(
              shrinkWrap: true,
              reverse: true,
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 80),
              physics: BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index){
                return Container(
                  padding: EdgeInsets.all(6.0),
                  decoration: roundedShadedDesign(context),
                  child: Column(
                    children: [
                      StreamBuilder(
                        stream: _firestore.collection('category').doc(items[index]['category'][0]).snapshots(),
                        builder: (context, snapshot2) {
                          if(snapshot2.hasData){
                            var category = snapshot2.data!.data();
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${category!['name']}',
                                        style: kBoldStyle(),
                                      ),
                                      SizedBox(height: 5),
                                      Text('Available for: ', style: k12BoldStyle()),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: items[index]['eventPrice'].length,
                                        itemBuilder: (context, inx) {
                                          var event = items[index]['eventPrice'][inx];
                                          return Text('${event['eventName']}');
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: kMainColor.withOpacity(0.2),
                                    image: DecorationImage(
                                      image: NetworkImage('${category['serverPath']}'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.0),
                              ],
                            );
                          }
                          return Container();
                        }
                      ),
                      SizedBox(height: 5.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: K2Button(
                                title: 'Edit',
                                color: kLightGreen,
                                onClick: (){
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => EditService(
                                          serviceID: items[index].reference.id
                                      )));
                                },
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: K2Button(
                                title: 'Delete',
                                onClick: (){
                                  deletePopUp(context, onClickYes: (){
                                    Navigator.pop(context);
                                    _firestore.collection('service').doc(items[index].reference.id).delete();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10);
              },
            ) : EmptyScreen(message: 'No Service Found');
          }
          return LoadingIcon();
        }
      ) : NotLoggedInScreen(),
      floatingActionButton: ServiceManager.userID != '' ? KButton(
        title: 'Add Service',
        onClick: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddService()));
        },
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
