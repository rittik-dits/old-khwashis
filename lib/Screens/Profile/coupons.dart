import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class Coupons extends StatefulWidget {
  const Coupons({Key? key}) : super(key: key);

  @override
  State<Coupons> createState() => _CouponsState();
}

class _CouponsState extends State<Coupons> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController _streamController = StreamController();

  @override
  void initState() {
    super.initState();
    print(ServiceManager.userID);
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coupons'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 30),
            child: Text('Tap to copy', style: kBoldStyle()),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.collection('coupons').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var docs = snapshot.data!.docs;
            List couponList = [];
            for(var item in docs){
              // if(!item['usedUser'].contains(ServiceManager.userID) && item['allotted'].contains(ServiceManager.userID)){
              //   if(item['count'] > 0){
                  couponList.add(item);
              //   }
              // }
            }
            return couponList.isNotEmpty ? ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: couponList.length,
              itemBuilder: (context, index){
                return ClipPath(
                  clipper: DolDurmaClipper(right: 120, holeRadius: 40),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                        border: Border.all(width: 0.5),
                        color: Colors.white,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(15.0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    // mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${couponList[index]['title']}', style: kHeaderStyle().copyWith(color: kWhiteColor)),
                                      Text('${couponList[index]['description']}', style: kWhiteTextStyle()),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    children: List.generate(70~/10, (index) => Expanded(
                                      child: Container(
                                        color: index%2==0 ? Colors.transparent
                                            : Colors.white, width: 3,
                                      ),
                                    )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(text: '${couponList[index]['couponCode']}'));
                              toastMessage(message: 'Coupon Copied');
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.3,
                              padding: EdgeInsets.all(10.0),
                              child: Text('${couponList[index]['couponCode']}', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ) : EmptyScreen(message: 'No Coupons Available');
          }
          return Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
}

class DolDurmaClipper extends CustomClipper<Path> {
  DolDurmaClipper({required this.right, required this.holeRadius});

  final double right;
  final double holeRadius;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - right - holeRadius, 0.0)
      ..arcToPoint(
        Offset(size.width - right, 0),
        clockwise: false,
        radius: Radius.circular(1),
      )
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - right, size.height)
      ..arcToPoint(
        Offset(size.width - right - holeRadius, size.height),
        clockwise: false,
        radius: Radius.circular(1),
      );

    path.lineTo(0.0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(DolDurmaClipper oldClipper) => true;
}
