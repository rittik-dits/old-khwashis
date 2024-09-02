import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/DialogueBox/deletePopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/videoPlayerScreen.dart';
import 'package:khwahish_provider/Screens/Profile/Reel/addReels.dart';
import 'package:khwahish_provider/Screens/Profile/subscriptionPage.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class Reels extends StatefulWidget {
  const Reels({super.key});

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reels'),
        actions: [
          // if(ServiceManager.isSubscribed != false)
          TextButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddReels()));
            },
            child: Text('Add +'),
          ),
        ],
      ),
      // body: ServiceManager.isSubscribed != false ? StreamBuilder(
      body: StreamBuilder(
        stream: _firestore.collection('reels').orderBy('time', descending: true).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            var docs = snapshot.data!.docs;
            List reels = [];
            for(var item in docs){
              if(item['userID'] == ServiceManager.userID){
                reels.add(item);
              }
            }
            return reels.isNotEmpty ? GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 9/12,
              ),
              itemCount: reels.length,
              itemBuilder: (context, index){
                return GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          videoUrl: '${reels[index]['videoUrl']}',
                        )));
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: kMainColor.withOpacity(0.4),
                          image: DecorationImage(
                            image: NetworkImage(reels[index]['thumbnail']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: kBottomShadedShadow(),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        child: Row(
                          children: [
                            // Icon(Icons.play_arrow_outlined, color: kWhiteColor,),
                            // Text('', style: k12Text().copyWith(
                            //   color: kWhiteColor,
                            // ),),
                            IconButton(
                              onPressed: (){
                                deletePopUp(context, onClickYes: (){
                                  _firestore.collection('reels')
                                      .doc(reels[index].reference.id).delete();
                                  Navigator.pop(context);
                                });
                              },
                              icon: Icon(Icons.delete_forever_outlined,
                                color: kWhiteColor,),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ) : EmptyScreen(message: 'No Reels uploaded');
          }
          return LoadingIcon();
        }
      ),
      // ) : Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Image.asset('images/app_logo.png', height: 180),
      //       kSpace(),
      //       Text('You did not Subscribe yet', style: kLargeStyle()),
      //       kSpace(),
      //       KButton(
      //         title: 'Subscribe',
      //         onClick: (){
      //           Navigator.push(context, MaterialPageRoute(builder: (context) => Subscription()));
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
