import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:intl/intl.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Profile/DigitalCalendar/addEvent.dart';
import 'package:khwahish_provider/Screens/Profile/DigitalCalendar/task_widget.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DigitalCalendar extends StatefulWidget {
  const DigitalCalendar({super.key});

  @override
  State<DigitalCalendar> createState() => _DigitalCalendarState();
}

class _DigitalCalendarState extends State<DigitalCalendar> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController event = TextEditingController();

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/calendar',
    ],
  );

  late GoogleSignInAccount _currentUser;
  late AuthClient _googleAuthClient;
  final CalendarController _calendarController = CalendarController();
  List<calendar.Event> _calendarEvents = [];

  @override
  void initState() {
    super.initState();
    // authenticateWithGoogle();
    // _handleSignIn();
    // getBookingData();
    getUserCalenderData();
  }

  void getUserCalenderData() async {
    meetings.clear();
    QuerySnapshot snapshot = await _firestore.collection('user_calender').get();
    for (QueryDocumentSnapshot document in snapshot.docs) {
      if(document['userID'] == ServiceManager.userID){
        setState(() {
          meetings.add(Meeting(
              '${document['event_name']}',
              (document['start_time'] as Timestamp).toDate(),
              (document['end_time'] as Timestamp).toDate(),
              document['isAvailable'] != true ? Colors.red : Color(0xFF0F8644),
              false));
        });
      }
    }
  }

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser  = await googleSignIn.signIn();
      if(googleUser != null){
        _fetchCalendarEvents();
      }
    } catch (error) {
      toastMessage(message: 'Google Sign-In error: $error');
    }
  }

  Future<void> _fetchCalendarEvents() async {
    final calendarApi = calendar.CalendarApi(_googleAuthClient);

    final events = await calendarApi.events.list('primary');
    if (events.items != null) {
      setState(() {
        _calendarEvents = events.items!;
      });
    }
    print(_calendarEvents);
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          // TextButton(
          //   onPressed: (){
          //     // googleSignIn.signOut();
          //   },
          //   child: Text('Logout'),
          // ),
          // TextButton(
          //   onPressed: () async {
          //     QuerySnapshot snapshot = await _firestore.collection('user_calender').get();
          //     for (QueryDocumentSnapshot document in snapshot.docs) {
          //       try {
          //         await _firestore.collection('user_calender').doc(document.id).update({
          //           'isAvailable': false,
          //         });
          //       } catch (e) {
          //         print(e);
          //       }
          //     }
          //   },
          //   child: Text('Update'),
          // ),
          MaterialButton(
            shape: materialButtonDesign(),
            color: kMainColor,
            textColor: kBTextColor,
            onPressed: (){

              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => AddEvent()))
                  .then((value) => {
                setState((){}),
                getUserCalenderData(),
              });
            },
            child: Text('Add Event'),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SfCalendar(
        view: calenderTypeMonth != false ? CalendarView.month : CalendarView.day,
        initialSelectedDate: DateTime.now(),
        showDatePickerButton: true,
        showNavigationArrow: true,
        showTodayButton: true,
        controller: _calendarController,
        dataSource: EventDataSource(_getDataSource()),
        // dataSource: _getDataSource(),
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        onTap: (value){
          showModalBottomSheet(
            context: context,
            builder: (context) => TasksWidget(
              initialDate: value.date!.toLocal(),
              bookings: meetings,
            ),
          ).then((value) => {
            setState((){}),
            getUserCalenderData(),
          });
          // setState(() {
          //   calenderTypeMonth = false;
          // });
        },
      ),
    );// Display loading indicator while authenticating.
  }

  bool calenderTypeMonth = true;

  final List<Meeting> meetings = <Meeting>[];
  List<Meeting> _getDataSource() {
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2, minutes: 30));
    // meetings.add(Meeting(
    //     'Stage Show', startTime, endTime, const Color(0xFF0F8644), false));
    return meetings;
  }
}


class EventDataSource extends CalendarDataSource {

  EventDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

class Meeting {
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);
}