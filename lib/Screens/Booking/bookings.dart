import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/DialogueBox/cancelPopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Booking/bookingDetails.dart';
import 'package:khwahish_provider/Screens/Profile/subscriptionPage.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Screens/notLogedInScreen.dart';
import 'package:khwahish_provider/Services/FirebaseAPIMessage.dart';
import 'package:khwahish_provider/Services/emailController.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:timeago/timeago.dart' as timeago;

class Bookings extends StatefulWidget {
  const Bookings({super.key});

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> with TickerProviderStateMixin {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Bookings'),
      ),
      body: ServiceManager.userID != '' ? ServiceManager.isSubscribed != false ? StreamBuilder(
        stream: _firestore.collection('booking')
            .where('providerId', isEqualTo: ServiceManager.userID)
            .orderBy('timeModify', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            var bookings = snapshot.data!.docs;
            return bookings.isNotEmpty ? ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              physics: BouncingScrollPhysics(),
              itemCount: bookings.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => BookingDetails(
                            bookingID: bookings[index].reference.id,
                          )));
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: roundedShadedDesign(context),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Order ID: ', style: kBoldStyle()),
                                        Expanded(
                                          child: Text(bookings[index].reference.id,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          )
                                        ),
                                      ],
                                    ),
                                    kRowText('Status: ', '${bookings[index]['status']}'),
                                    Text(timeago.format(bookings[index]['timeModify'].toDate()), style: kSmallText()),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                height: 80.0,
                                width: 80.0,
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: k4Color.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                    image: NetworkImage(bookings[index]['serviceImage']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if(bookings[index]['status'] != 'Cancelled' && bookings[index]['status'] != 'Accepted' && bookings[index]['status'] != 'Completed')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // if(bookings[index]['status'] != 'Cancelled')
                              Expanded(
                                child: K2Button(
                                  color: kLightGreen,
                                  title: 'Accept',
                                  onClick: (){
                                    print(bookings[index].reference.id.toString());
                                    _firestore.collection('booking').doc(bookings[index].reference.id).update({
                                      'status': 'Accepted',
                                    });
                                    updateCalender(
                                      startTime: bookings[index]['selectTime'].toDate(),
                                      endTime: bookings[index]['selectEndTime'].toDate(),
                                    );

                                    sendAcceptNotification(userID: '${bookings[index]['customerId']}');
                                    ///to Admin
                                    EmailController().sendMail(
                                      recipientEmail: EmailController.adminEmail,
                                      mailMessage: 'I have accepted the booking successfully '
                                          'and would like to perform as an artist in your event.\n'
                                          'Booking ID: ${bookings[index].reference.id}',
                                    );
                                    ///to User
                                    EmailController().sendMailOnAcceptanceWithDoc(
                                      recipientEmail: '${bookings[index]['customerEmail']}',
                                      mailMessage: 'I have accepted the booking successfully '
                                          'and would like to perform as an artist in your event.\n'
                                          'Booking ID: ${bookings[index].reference.id}',
                                    );
                                    ///To Artist
                                    EmailController().sendMailOnAcceptanceWithDoc(
                                      recipientEmail: ServiceManager.userEmail,
                                      mailMessage: 'You have accepted the booking successfully\n'
                                          'Booking ID: ${bookings[index].reference.id}',
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              // if(bookings[index]['status'] != 'Cancelled')
                              Expanded(
                                child: K2Button(
                                  title: 'Cancel',
                                  onClick: (){
                                    cancelPopUp(context, onClickYes: (){
                                      Navigator.pop(context);
                                      _firestore.collection('booking').doc(bookings[index].reference.id).update({
                                        'status': 'Cancelled',
                                      });

                                      sendCancelNotification(userID: '${bookings[index]['customerId']}');
                                      ///to User
                                      EmailController().sendMail(
                                        recipientEmail: '${bookings[index]['customerEmail']}',
                                        mailMessage: "You booking was cancelled \n Booking ID: "
                                            "${bookings[index].reference.id}",
                                      );
                                      ///to Admin
                                      EmailController().sendMail(
                                        recipientEmail: EmailController.adminEmail,
                                        mailMessage: 'Artist : ${ServiceManager.userName} have cancelled the booking.\n'
                                            'Booking ID: ${bookings[index].reference.id}',
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ) : EmptyScreen(message: 'No Booking Yet');
          }
          return LoadingIcon();
        }
      ) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/app_logo.png', height: 180),
            kSpace(),
            Text('You did not Subscribe yet', style: kLargeStyle()),
            kSpace(),
            KButton(
              title: 'Subscribe',
              onClick: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPage()));
              },
            ),
          ],
        ),
      ) : NotLoggedInScreen(),
    );
  }

  void updateCalender({required DateTime startTime, required DateTime endTime}){
    print(startTime);
    print(endTime);
    try{
      _firestore.collection('user_calender').add({
        'additionalCharge': 0,
        'end_time': endTime,
        'event_name': 'Booking',
        'isAvailable': false,
        'start_time': startTime,
        'userID': ServiceManager.userID, ///artistID
      });
    } catch (e) {
      print(e);
    }
  }

  void sendAcceptNotification({required String userID}) async {
    var collection = _firestore.collection('listusers');
    var docs = await collection.doc(userID).get();
    if(docs.exists){
      NotificationCloud().sendNotification('Hey ${docs['name']}', 'Your booking has been accepted', docs['FCM']);
    }
  }

  void sendCancelNotification({required String userID}) async {
    var collection = _firestore.collection('listusers');
    var docs = await collection.doc(userID).get();
    if(docs.exists){
      NotificationCloud().sendNotification('Hey ${docs['name']}', 'Sorry Your booking has been cancelled', docs['FCM']);
    }
  }
  
}
