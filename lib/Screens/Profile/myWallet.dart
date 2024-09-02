import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class MyWallet extends StatefulWidget {
  const MyWallet({super.key});

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBackgroundDesign(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('My Wallet'),
          // actions: [
          //   TextButton(
          //     onPressed: (){
          //       ServiceManager().updateAll();
          //     },
          //     child: Text('update'),
          //   ),
          // ],
        ),
        body: StreamBuilder(
          stream: _firestore.collection('provider').doc(ServiceManager.userID).snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              var data = snapshot.data;
              return SingleChildScrollView(
                padding: kResponsive(context),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.width-30,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/stage.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(15),
                            color: k4Color.withOpacity(0.8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Wallet'.toUpperCase(), style: kLargeStyle().copyWith(
                                        color: kWhiteColor
                                    )),
                                    Text(data!['wallet'] != null ? kAmount(data['wallet']) : kAmount(0),
                                      style: kLargeStyle().copyWith(
                                          color: kWhiteColor
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text('Refer & Earn amount to wallet'.toUpperCase(),
                                  style: kWhiteTextStyle(),
                                ),
                                // SizedBox(height: 5),
                                // Text('Watch reels to earn more coins'.toUpperCase(),
                                //   style: kWhiteTextStyle(),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return LoadingIcon();
          }
        ),
      ),
    );
  }
}
