import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/style.dart';

class NotificationPage2 extends StatefulWidget {
  const NotificationPage2({super.key});

  @override
  State<NotificationPage2> createState() => _NotificationPage2State();
}

class _NotificationPage2State extends State<NotificationPage2> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('notification')
            .where('sendTo', isEqualTo: ServiceManager.userID)
            .orderBy('time', descending: true).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            var notification = snapshot.data!.docs;
            return notification.isNotEmpty ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              itemCount: notification.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: roundedShadedDesign(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${notification[index]['title']}', style: kBoldStyle()),
                        Text('${notification[index]['body']}'),
                        Text('Date: ${(notification[index]['time']).toDate()}', style: kSmallText()),
                      ],
                    ),
                  ),
                );
              },
            ) : EmptyScreen(message: 'No Notification');
          }
          return LoadingIcon();
        }
      ),
    );
  }
}
