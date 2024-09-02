import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:intl/intl.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Booking/bookings.dart';
import 'package:khwahish_provider/Screens/Home/reviews.dart';
import 'package:khwahish_provider/Screens/MyServices/addService.dart';
import 'package:khwahish_provider/Screens/Notification/notificationPage.dart';
import 'package:khwahish_provider/Screens/Profile/MyPage/myPage.dart';
import 'package:khwahish_provider/Screens/Profile/profilePage.dart';
import 'package:khwahish_provider/Screens/Profile/subscriptionPage.dart';
import 'package:khwahish_provider/Screens/Profile/verifyAccount.dart';
import 'package:khwahish_provider/Screens/notLogedInScreen.dart';
import 'package:khwahish_provider/Screens/notificationPage2.dart';
import 'package:khwahish_provider/Services/calculation.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
// import 'package:khwahish_provider/Screens/Profile/subscriptionPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print(ServiceManager.userID);
    if (ServiceManager.userID != '') {
      getBookingData();
      ServiceManager().updateSubscriptionData();
      // getAllNotification();
      _calculateProfileCompletion();
    }
  }

  List bookings = [];
  List totalPendingBooking = [];
  List totalAcceptBooking = [];
  List totalCancelBooking = [];
  List totalCompleteBooking = [];
  List totalTodayBooking = [];
  List totalMonthlyBooking = [];
  num totalIncome = 0;
  num monthlyIncome = 0;
  num quarterlyIncome = 0;
  num yearlyIncome = 0;
  void getBookingData() async {
    var collection = _firestore.collection('booking');
    QuerySnapshot querySnapshot = await collection.get();
    List<Map<String, dynamic>> pending = [];
    List<Map<String, dynamic>> accepted = [];
    List<Map<String, dynamic>> cancelled = [];
    List<Map<String, dynamic>> completed = [];
    List<Map<String, dynamic>> today = [];
    List<Map<String, dynamic>> monthly = [];

    double Q1Income = 0.0;
    double Q2Income = 0.0;
    double Q3Income = 0.0;
    double Q4Income = 0.0;

    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      if (data['providerId'] == ServiceManager.userID) {
        bookings.add(data);

        switch (data['status']) {
          case 'Pending':
            pending.add(data);
            break;
          case 'Accepted':
            accepted.add(data);
            break;
          case 'Cancelled':
            cancelled.add(data);
            break;
          case 'Completed':
            completed.add(data);
            double income = (data['total'] * 0.9).toDouble(); // 90% of total
            totalIncome += income;

            DateTime bookingDate =
                DateFormat('dd/MM/yyyy').parse(data['selectedDate']);
            if (bookingDate.month == DateTime.now().month &&
                bookingDate.year == DateTime.now().year) {
              monthlyIncome += income;
            }
            if (bookingDate.year == DateTime.now().year) {
              yearlyIncome += income;
            }
            if (isInQuarter(bookingDate, DateTime.now())) {
              quarterlyIncome += income;

              // Determine the quarter and add income accordingly
              int quarter =
                  (bookingDate.month - 1) ~/ 3; // 0 for Q1, 1 for Q2, etc.
              switch (quarter) {
                case 0:
                  Q1Income += income;
                  break;
                case 1:
                  Q2Income += income;
                  break;
                case 2:
                  Q3Income += income;
                  break;
                case 3:
                  Q4Income += income;
                  break;
              }
            }
            break;
        }

        DateTime bookingDate =
            DateFormat('dd/MM/yyyy').parse(data['selectedDate']);
        if (bookingDate.isAtSameMomentAs(DateTime.now())) {
          today.add(data);
        }

        if (bookingDate.month == DateTime.now().month &&
            bookingDate.year == DateTime.now().year) {
          monthly.add(data);
        }
      }
    }

    setState(() {
      totalPendingBooking = pending;
      totalAcceptBooking = accepted;
      totalCancelBooking = cancelled;
      totalCompleteBooking = completed;
      totalTodayBooking = today;
      totalMonthlyBooking = monthly;
      // Set quarterly incomes in state as well if needed
      // For example: setTotalQuarterlyIncome(Q1Income, Q2Income, Q3Income, Q4Income);
    });
  }

  void getBookingData2() async {
    var collection = _firestore.collection('booking');
    QuerySnapshot querySnapshot = await collection.get();
    List<Map<String, dynamic>> pending = [];
    List<Map<String, dynamic>> accepted = [];
    List<Map<String, dynamic>> cancelled = [];
    List<Map<String, dynamic>> completed = [];
    List<Map<String, dynamic>> today = [];
    List<Map<String, dynamic>> monthly = [];

    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      if (data['providerId'] == ServiceManager.userID) {
        bookings.add(data);

        switch (data['status']) {
          case 'Pending':
            pending.add(data);
            break;
          case 'Accepted':
            accepted.add(data);
            break;
          case 'Cancelled':
            cancelled.add(data);
            break;
          case 'Completed':
            completed.add(data);
            double income = (data['total'] * 0.9).toDouble(); // 90% of total
            totalIncome += income;
            DateTime bookingDate =
                DateFormat('dd/MM/yyyy').parse(data['selectedDate']);
            if (bookingDate.month == DateTime.now().month &&
                bookingDate.year == DateTime.now().year) {
              monthlyIncome +=
                  income; // Add to monthly income if booking is in current month
            }
            if (bookingDate.year == DateTime.now().year) {
              yearlyIncome +=
                  income; // Add to yearly income if booking is in current year
            }
            if (isInQuarter(bookingDate, DateTime.now())) {
              quarterlyIncome +=
                  income; // Add to quarterly income if booking is in current quarter
            }
            break;
        }

        DateTime bookingDate =
            DateFormat('dd/MM/yyyy').parse(data['selectedDate']);
        if (bookingDate.isAtSameMomentAs(DateTime.now())) {
          today.add(data);
        }

        if (bookingDate.month == DateTime.now().month &&
            bookingDate.year == DateTime.now().year) {
          monthly.add(data);
        }
      }
    }

    setState(() {
      totalPendingBooking = pending;
      totalAcceptBooking = accepted;
      totalCancelBooking = cancelled;
      totalCompleteBooking = completed;
      totalTodayBooking = today;
      totalMonthlyBooking = monthly;
    });
  }

  // Function to check if a date is in the same quarter as the current date
  bool isInQuarter(DateTime date, DateTime now) {
    return date.year == now.year &&
        (date.month - 1) ~/ 3 == (now.month - 1) ~/ 3;
  }

  int totalNotification = 0;
  Future<void> getAllNotification() async {
    CollectionReference collection = _firestore.collection('notification');
    QuerySnapshot querySnapshot = await collection.get();
    List<DocumentSnapshot> documents = querySnapshot.docs;
    for (DocumentSnapshot document in documents) {
      if (document['sendTo'] == ServiceManager.userID &&
          document['read'] != true) {
        setState(() {
          totalNotification += 1;
        });
      }
    }
  }

  double profileCompletion = 0.0;
  void _calculateProfileCompletion() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('provider')
          .doc(ServiceManager.userID)
          .get();
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
      int totalFields = userData.keys.length;
      int filledFields =
          userData.values.where((value) => value != null && value != '').length;
      setState(() {
        profileCompletion = filledFields / totalFields;
      });
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  //*********************************************************** */
  

  //*********************************************************** */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: shadedTopGradient(),
          ),
        ),
        title: Image.asset('images/app_logo.png', height: 55),
        actions: [
          GestureDetector(
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              _scaffoldKey.currentState!.openEndDrawer();
            },
            child: ServiceManager.profileURL == ''
                ? CircleAvatar(
                    backgroundImage: AssetImage('images/img_blank_profile.png'),
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(ServiceManager.profileURL),
                  ),
          ),
          SizedBox(width: 15),
        ],
      ),
      endDrawer: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: ProfilePage(),
      ),
      body: ServiceManager.userID != ''
          ? StreamBuilder(
              stream: _firestore
                  .collection('provider')
                  .doc(ServiceManager.userID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var docs = snapshot.data!.data();

                  // print(docs!['isSubscribed']);

                  // if(docs!['aadhaar'] == '' && docs['panCard'] == '')
                  // if(docs['address'] == '')
                  // int totalField = 3;
                  // int filledFields = userData.values.where((value) => value != null && value != '').length;

                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(ServiceManager.isSubscribed.toString()),
                        Column(
                          children: [
                            // Text(ServiceManager.userID),
                            if ((docs!['aadhaar'] == '' &&
                                    docs['panCard'] == '') ||
                                (docs['passport'] == '' &&
                                    docs['panCard'] == ''))
                              Column(
                                children: [
                                  Row(),
                                  kBottomSpace(),
                                  Text('Welcome to',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontFamily: 'Fasthand',
                                        fontWeight: FontWeight.w400,
                                      )),
                                  Image.asset('images/khwahish_name.png',
                                      height: 40),
                                  kBottomSpace(),
                                ],
                              ),
                            if (profileCompletion <= 0.8)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 25),
                                  decoration: blurCurveDecor(context).copyWith(
                                    color: kMainColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(width: 0.5),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Profile Not Completed',
                                                style: kHeaderStyle()),
                                            Text('Complete your profile',
                                                style: kSmallText()),
                                          ],
                                        ),
                                      ),
                                      // BorderButton(title: 'buttonText', onClick: (){},),
                                      SizedBox(
                                        height: 80,
                                        child: CircularPercentIndicator(
                                          radius: 40.0,
                                          lineWidth: 4.0,
                                          // percent: accountCompleted,
                                          percent: profileCompletion,
                                          center: Text(
                                              "${(profileCompletion * 100).toStringAsFixed(0)}%"),
                                          progressColor: Colors.green,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            if (docs['address'] == '')
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: startingContainer(
                                  context,
                                  title: "Base Location Not set",
                                  desc: 'You have not set your base location',
                                  buttonText: 'Complete',
                                  color: kMainColor,
                                  onClick: () {
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage2()));

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyPage()));
                                  },
                                ),
                              ),
                            if (docs['aadhaar'] == '' && docs['panCard'] == '')
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: startingContainer(
                                  context,
                                  title: 'You Are Not Verified',
                                  desc: 'Verify Your Account',
                                  buttonText: 'Verify',
                                  color: k4Color,
                                  onClick: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VerifyAccount()));
                                  },
                                ),
                              ),
                            if (docs['isSubscribed'] != true)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: startingContainer(
                                  context,
                                  title: "You are not subscribed",
                                  desc: 'Subscribed to get full app access',
                                  buttonText: 'Subscribe',
                                  color: kMainColor,
                                  onClick: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SubscriptionPage()));
                                  },
                                ),
                              ),
                            StreamBuilder(
                                stream: _firestore
                                    .collection('service')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var data = snapshot.data!.docs;
                                    List items = [];
                                    for (var item in data) {
                                      if (item['providers']
                                          .contains(ServiceManager.userID)) {
                                        items.add(item);
                                      }
                                    }
                                    return items.isEmpty
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                            child: startingContainer(
                                              context,
                                              title: 'No Service Added',
                                              desc:
                                                  'Add Some Service To Get Bookings',
                                              buttonText: 'Add',
                                              color: k2MainColor,
                                              onClick: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddService()));
                                              },
                                            ),
                                          )
                                        : SizedBox.shrink();
                                  }
                                  return SizedBox.shrink();
                                }),
                          ],
                        ),
//------------------------------------------
                        if (docs['aadhaar'] != '' && docs['panCard'] != '')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Bookings', style: kBoldStyle()),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Bookings()));
                                      },
                                      child: Text('See All'),
                                    ),
                                  ],
                                ),
                              ),
                             

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  totalPendingBooking.isNotEmpty
                                      ? 'Total Pending Bookings : ${totalPendingBooking.length}'
                                      : 'No Pending Booking',
                                  style: kLargeStyle(),
                                ),
                              ),

                              Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                children: [
                                  Container(
                                    height: 250,
                                    width: MediaQuery.of(context).size.width,
                                    child:pie_chart. PieChart(
                                      dataMap: {
                                        "Pending": totalPendingBooking.length.toDouble(),
                                        "Accepted": totalAcceptBooking.length.toDouble(),
                                        "Successful": totalCompleteBooking.length.toDouble(),
                                      },
                                      animationDuration: Duration(milliseconds: 800),
                                      chartLegendSpacing: 32,
                                      chartRadius: MediaQuery.of(context).size.width / 2.2,
                                      colorList: [Colors.orange, Colors.blue, Colors.green],
                                      initialAngleInDegree: 0,
                                      chartType: pie_chart.ChartType.ring,
                                      ringStrokeWidth: 32,
                                      centerText: "Bookings",
                                      legendOptions: pie_chart.LegendOptions(
                                        showLegendsInRow: false,
                                        legendPosition: pie_chart.LegendPosition.right,
                                        showLegends: true,
                                        legendShape: BoxShape.circle,
                                        legendTextStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      chartValuesOptions: pie_chart.ChartValuesOptions(
                                        showChartValueBackground: true,
                                        showChartValues: true,
                                        showChartValuesInPercentage: true,
                                        showChartValuesOutside: false,
                                        decimalPlaces: 1,
                                      ),
                                      // gradientList: ---To add gradient colors---
                                      // emptyColorGradient: ---Empty Color gradient---
                                    ),
                                  ),
                                ],
                              ),
                            ),


                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              //   child: Container(
                              //     height: 100,
                              //     width: MediaQuery.of(context).size.width,
                              //     padding: EdgeInsets.all(10.0),
                              //     decoration: roundedContainerDesign(context).copyWith(
                              //       color: k4Color.withOpacity(0.4),
                              //     ),
                              //     child: Column(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       children: [
                              //         Text(totalPendingBooking.isNotEmpty ?
                              //         'Total Pending Bookings : ${totalPendingBooking.length}' :
                              //         'No Pending Booking', style: kLargeStyle(),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Row(
                                  children: [
                                    k2Design(context,
                                        title: '${totalTodayBooking.length}',
                                        desc: "Today's\nBooking"),
                                    k2Design(context,
                                        title: '${totalMonthlyBooking.length}',
                                        desc: "Total Monthly\nBookings"),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(10.0),
                                  decoration:
                                      roundedContainerDesign(context).copyWith(
                                    // color: k4Color.withOpacity(0.4),
                                    color: Color.fromARGB(255, 149, 166,
                                        107), //Color.fromARGB(255, 168, 198, 158),// Color(0XFFD0DECB),
                                  ),
                                  child: Column(
                                    children: [
                                      kWhiteRowText('Pending Booking: ',
                                          '${totalPendingBooking.length}'),
                                      kWhiteRowText('Accepted Booking: ',
                                          '${totalAcceptBooking.length}'),
                                      kWhiteRowText('Successful Booking: ',
                                          '${totalCompleteBooking.length}'),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Total Bookings: ',
                                              style: kLargeStyle()),
                                          Text(
                                              '${bookings.length - totalCancelBooking.length}',
                                              style: kLargeStyle()),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              kSpace(),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Earning', style: k12BoldStyle()),
                                    Text(kAmount(totalIncome),
                                        style: kLargeStyle()),
                                  ],
                                ),
                              ),
                              
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(10.0),
                                  decoration:
                                      roundedContainerDesign(context).copyWith(
                                    // color: k5Color.withOpacity(0.4),
                                    color: Color.fromARGB(255, 35, 173,
                                        223), // Color(0XFFD0DECB),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          kContainerWhiteText(
                                            title: 'Monthly',
                                            desc: kAmount(monthlyIncome),
                                          ),
                                          kContainerWhiteText(
                                            title: 'Quarterly',
                                            desc: kAmount(quarterlyIncome),
                                          ),
                                          kContainerWhiteText(
                                            title: 'Yearly',
                                            desc: kAmount(yearlyIncome),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              StreamBuilder(
                                  stream: _firestore
                                      .collection('provider')
                                      .doc(ServiceManager.userID)
                                      .collection('reviews')
                                      .snapshots(),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      var review = snapshot2.data!.docs;
                                      List<num> allRatings = [];
                                      List oneStar = [];
                                      List twoStar = [];
                                      List threeStar = [];
                                      List fourStar = [];
                                      List fiveStar = [];
                                      for (var item in review) {
                                        allRatings.add(item['rating']);
                                        if (item['rating'] == 5) {
                                          fiveStar.add(item['rating']);
                                        }
                                        if (item['rating'] == 4) {
                                          fourStar.add(item['rating']);
                                        }
                                        if (item['rating'] == 3) {
                                          threeStar.add(item['rating']);
                                        }
                                        if (item['rating'] == 2) {
                                          twoStar.add(item['rating']);
                                        }
                                        if (item['rating'] == 1) {
                                          oneStar.add(item['rating']);
                                        }
                                      }
                                      return allRatings.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0),
                                              child: Container(
                                                padding: EdgeInsets.all(15.0),
                                                decoration:
                                                    blurCurveDecor(context)
                                                        .copyWith(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        children: [
                                                          kRating(
                                                              title: '5',
                                                              kValue: allRatings
                                                                      .isNotEmpty
                                                                  ? fiveStar
                                                                          .length /
                                                                      allRatings
                                                                          .length
                                                                  : 0,
                                                              percent:
                                                                  '${(fiveStar.length / allRatings.length) * 100}%'),
                                                          kRating(
                                                              title: '4',
                                                              kValue: allRatings
                                                                      .isNotEmpty
                                                                  ? fourStar
                                                                          .length /
                                                                      allRatings
                                                                          .length
                                                                  : 0,
                                                              percent:
                                                                  '${(fourStar.length / allRatings.length) * 100}%'),
                                                          kRating(
                                                              title: '3',
                                                              kValue: allRatings
                                                                      .isNotEmpty
                                                                  ? threeStar
                                                                          .length /
                                                                      allRatings
                                                                          .length
                                                                  : 0,
                                                              percent:
                                                                  '${(threeStar.length / allRatings.length) * 100}%'),
                                                          kRating(
                                                              title: '2',
                                                              kValue: allRatings
                                                                      .isNotEmpty
                                                                  ? twoStar
                                                                          .length /
                                                                      allRatings
                                                                          .length
                                                                  : 0,
                                                              percent:
                                                                  '${(twoStar.length / allRatings.length) * 100}%'),
                                                          kRating(
                                                              title: '1',
                                                              kValue: allRatings
                                                                      .isNotEmpty
                                                                  ? oneStar
                                                                          .length /
                                                                      allRatings
                                                                          .length
                                                                  : 0,
                                                              percent:
                                                                  '${(oneStar.length / allRatings.length) * 100}%'),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 15.0),
                                                    Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            // Text('${docs['avgRating']}', style: kLargeStyle()),
                                                            Text(
                                                                '${getAvgRating(allRatings)}',
                                                                style:
                                                                    kLargeStyle()),
                                                            Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.orange,
                                                              size: 30,
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                            '${review.length} Reviews',
                                                            style:
                                                                kBoldStyle()),
                                                        MaterialButton(
                                                          shape:
                                                              materialButtonDesign(),
                                                          color: kButtonColor,
                                                          textColor:
                                                              kBTextColor,
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Reviews()));
                                                          },
                                                          child:
                                                              Text('Read all'),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink();
                                    }
                                    return Container();
                                  }),
                              kSpace(),
                              SizedBox(height: 10),
                            ],
                          ), //------------------------
                      ],
                    ),
                  );
                }
                return LoadingIcon();
              })
          : NotLoggedInScreen(),
    );
  }

  Container startingContainer(
    BuildContext context, {
    required String title,
    required String desc,
    required String buttonText,
    required Color color,
    required Function() onClick,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      decoration: blurCurveDecor(context).copyWith(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: kHeaderStyle()),
                Text(desc, style: kSmallText()),
              ],
            ),
          ),
          BorderButton(
            title: buttonText,
            onClick: onClick,
          ),
          // MaterialButton(
          //   shape: materialButtonDesign(),
          //   color: kMainColor,
          //   textColor: kBTextColor,
          //   onPressed: onClick,
          //   child: Text(buttonText),
          // )
        ],
      ),
    );
  }
}

Widget kContainerWhiteText({
  required String title,
  required String desc,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: kLargeStyle()),
              Text('Earning', style: kSmallText()),
            ],
          ),
          Expanded(
            child: Text(
              desc,
              textAlign: TextAlign.end,
              style: kLargeStyle(),
            ),
          ),
        ],
      ),
    ),
  );
}
