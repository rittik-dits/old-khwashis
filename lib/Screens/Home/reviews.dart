import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Reviews extends StatefulWidget {
  const Reviews({super.key});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Review'),
      ),
      body: StreamBuilder(
          stream: _firestore.collection('provider').doc(ServiceManager.userID)
              .collection('reviews').orderBy('time').snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              var reviews = snapshot.data!.docs;
              return ListView.separated(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: reviews.length,
                itemBuilder: (context, index){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${reviews[index]['name']}', style: k8Text()),
                      Text('${reviews[index]['review']}', style: k10Text()),
                      RatingBarIndicator(
                        rating: double.parse('${reviews[index]['rating']}'),
                        itemBuilder: (context, index) => Icon(
                            Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 16.0,
                        direction: Axis.horizontal,
                      ),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return dashLines();
                },
              );
            }
            return LoadingIcon();
          }
      ),
    );
  }
}
