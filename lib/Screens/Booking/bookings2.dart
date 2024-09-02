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
import 'dart:math';

class Bookings2 extends StatefulWidget {
  const Bookings2({super.key});

  @override
  State<Bookings2> createState() => _Bookings2State();
}

class _Bookings2State extends State<Bookings2> with TickerProviderStateMixin {
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

  String changeOrderId(String currentBookingId) {
    // Extract the first 6 characters of the booking ID
    String firstPart = currentBookingId.substring(0, 6);

    // Generate a random number between 100 and 999
    Random random = Random();
    int randomNumber = 100 + random.nextInt(900);

    // Get the current year
    String currentYear = DateTime.now().year.toString();

    // Combine all parts to form the new order ID
    String newOrderId = 'KH-$firstPart-$randomNumber-$currentYear';

    return newOrderId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Bookings'),
      ),
      body: ServiceManager.userID != ''
          ? ServiceManager.isSubscribed != false
              ? StreamBuilder(
                  stream: _firestore
                      .collection('booking')
                      .where('providerId', isEqualTo: ServiceManager.userID)
                      .orderBy('timeModify', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var bookings = snapshot.data!.docs;

                      // Group bookings by the same day
                      var bookingsByDay = <String, List<DocumentSnapshot>>{};
                      for (var booking in bookings) {
                        String bookingDay = (booking['selectTime'] as Timestamp)
                            .toDate()
                            .toIso8601String()
                            .substring(0, 10);
                        if (bookingsByDay.containsKey(bookingDay)) {
                          bookingsByDay[bookingDay]!.add(booking);
                        } else {
                          bookingsByDay[bookingDay] = [booking];
                        }
                      }

                      return bookings.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              physics: BouncingScrollPhysics(),
                              itemCount: bookings.length,
                              itemBuilder: (context, index) {
                                var currentBooking = bookings[index];
                                var bookingDay =
                                    (currentBooking['selectTime'] as Timestamp)
                                        .toDate()
                                        .toIso8601String()
                                        .substring(0, 10);
                                var dayBookings = bookingsByDay[bookingDay]!;

                                String distanceText = '';
                                if (index > 0 &&
                                    dayBookings.length > 1 &&
                                    currentBooking != dayBookings.first) {
                                  var previousBooking = dayBookings[
                                      dayBookings.indexOf(currentBooking) - 1];
                                  double distance = calculateDistance(
                                      previousBooking['products'][0]
                                          ['vanueLatLang'],
                                      currentBooking['products'][0]
                                          ['vanueLatLang']);
                                  distanceText =
                                      'Distance from previous booking: ${distance.toStringAsFixed(2)} km';
                                }

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      //print(currentBooking.reference.id);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BookingDetails(
                                                    bookingID: currentBooking
                                                        .reference.id,
                                                  )));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: roundedShadedDesign(context),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text('Order ID: ',
                                                            style:
                                                                kBoldStyle()),
                                                        Expanded(
                                                            child: Text(
                                                          changeOrderId(
                                                              currentBooking
                                                                  .reference
                                                                  .id),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        )),
                                                      ],
                                                    ),
                                                    kRowText('Status: ',
                                                        '${currentBooking['status']}'),
                                                    Text(
                                                        timeago.format(
                                                            currentBooking[
                                                                    'timeModify']
                                                                .toDate()),
                                                        style: kSmallText()),
                                                    Text(distanceText,
                                                        style: kSmallText()),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Container(
                                                height: 80.0,
                                                width: 80.0,
                                                padding: EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                  color:
                                                      k4Color.withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        currentBooking[
                                                            'serviceImage']),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (currentBooking['status'] !=
                                                  'Cancelled' &&
                                              currentBooking['status'] !=
                                                  'Accepted' &&
                                              currentBooking['status'] !=
                                                  'Completed')
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: K2Button(
                                                    color: kLightGreen,
                                                    title: 'Accept',
                                                    onClick: () {
                                                      print(currentBooking
                                                          .reference.id
                                                          .toString());
                                                      _firestore
                                                          .collection('booking')
                                                          .doc(currentBooking
                                                              .reference.id)
                                                          .update({
                                                        'status': 'Accepted',
                                                      });
                                                      updateCalender(
                                                        startTime:
                                                            currentBooking[
                                                                    'selectTime']
                                                                .toDate(),
                                                        endTime: currentBooking[
                                                                'selectEndTime']
                                                            .toDate(),
                                                      );

                                                      sendAcceptNotification(
                                                          userID:
                                                              '${currentBooking['customerId']}');

                                                      ///to Admin
                                                      EmailController()
                                                          .sendMail(
                                                        recipientEmail:
                                                            EmailController
                                                                .adminEmail,
                                                        mailMessage:
                                                            'I have accepted the booking successfully '
                                                            'and would like to perform as an artist in your event.\n'
                                                            'Booking ID: ${currentBooking.reference.id}',
                                                      );

                                                      ///to User
                                                      EmailController()
                                                          .sendMailOnAcceptanceWithDoc(
                                                        recipientEmail:
                                                            '${currentBooking['customerEmail']}',
                                                        mailMessage:
                                                            'I have accepted the booking successfully '
                                                            'and would like to perform as an artist in your event.\n'
                                                            'Booking ID: ${currentBooking.reference.id}',
                                                      );

                                                      ///To Artist
                                                      EmailController()
                                                          .sendMailOnAcceptanceWithDoc(
                                                        recipientEmail:
                                                            ServiceManager
                                                                .userEmail,
                                                        mailMessage:
                                                            'You have accepted the booking successfully\n'
                                                            'Booking ID: ${currentBooking.reference.id}',
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: K2Button(
                                                    title: 'Cancel',
                                                    onClick: () {
                                                      cancelPopUp(context,
                                                          onClickYes: () {
                                                        Navigator.pop(context);
                                                        _firestore
                                                            .collection(
                                                                'booking')
                                                            .doc(currentBooking
                                                                .reference.id)
                                                            .update({
                                                          'status': 'Cancelled',
                                                        });

                                                        sendCancelNotification(
                                                            userID:
                                                                '${currentBooking['customerId']}');

                                                        ///to User
                                                        EmailController()
                                                            .sendMail(
                                                          recipientEmail:
                                                              '${currentBooking['customerEmail']}',
                                                          mailMessage:
                                                              "You booking was cancelled \n Booking ID: "
                                                              "${currentBooking.reference.id}",
                                                        );

                                                        ///to Admin
                                                        EmailController()
                                                            .sendMail(
                                                          recipientEmail:
                                                              EmailController
                                                                  .adminEmail,
                                                          mailMessage:
                                                              'Artist : ${ServiceManager.userName} have cancelled the booking.\n'
                                                              'Booking ID: ${currentBooking.reference.id}',
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
                            )
                          : EmptyScreen(message: 'No Booking Yet');
                    }
                    return LoadingIcon();
                  })
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/app_logo.png', height: 180),
                      kSpace(),
                      Text('You did not Subscribe yet', style: kLargeStyle()),
                      kSpace(),
                      KButton(
                        title: 'Subscribe',
                        onClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SubscriptionPage()));
                        },
                      ),
                    ],
                  ),
                )
          : NotLoggedInScreen(),
    );
  }

  // Function to calculate the distance between two GeoPoints
  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const earthRadiusKm = 6371.0;

    double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    double dLon = _degreesToRadians(point2.longitude - point1.longitude);

    double lat1 = _degreesToRadians(point1.latitude);
    double lat2 = _degreesToRadians(point2.latitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void updateCalender(
      {required DateTime startTime, required DateTime endTime}) {
    print(startTime);
    print(endTime);
    try {
      _firestore.collection('user_calender').add({
        'additionalCharge': 0,
        'end_time': endTime,
        'event_name': 'Booking',
        'isAvailable': false,
        'start_time': startTime,
        'userID': ServiceManager.userID,

        ///artistID
      });
    } catch (e) {
      print(e);
    }
  }

  void sendAcceptNotification({required String userID}) async {
    var collection = _firestore.collection('listusers');
    var docs = await collection.doc(userID).get();
    if (docs.exists) {
      NotificationCloud().sendNotification(
          'Hey ${docs['name']}', 'Your booking has been accepted', docs['FCM']);
    }
  }

  void sendCancelNotification({required String userID}) async {
    var collection = _firestore.collection('listusers');
    var docs = await collection.doc(userID).get();
    if (docs.exists) {
      NotificationCloud().sendNotification('Hey ${docs['name']}',
          'Sorry Your booking has been cancelled', docs['FCM']);
    }
  }
}
