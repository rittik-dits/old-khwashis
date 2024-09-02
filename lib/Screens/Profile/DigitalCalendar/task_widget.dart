import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khwahish_provider/Components/DialogueBox/deletePopUp.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Profile/DigitalCalendar/digitalCalendar.dart';
import 'package:khwahish_provider/Screens/Profile/DigitalCalendar/editEvent.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/style.dart';

class TasksWidget extends StatefulWidget {

  DateTime initialDate;
  List<Meeting> bookings;
  TasksWidget({super.key, required this.initialDate, required this.bookings});

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  DateTime _startOfNextDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('user_calender')
            .where('userID', isEqualTo: ServiceManager.userID)
            .where('start_time', isGreaterThanOrEqualTo: _startOfDay(widget.initialDate))
            .where('start_time', isLessThan: _startOfNextDay(widget.initialDate))
            .snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            var data = snapshot.data!.docs;
            return data.isNotEmpty ? ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: data.length,
              itemBuilder: (context, index){
                return Container(
                  padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  decoration: roundedContainerDesign(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            kRowText('Event: ', '${data[index]['event_name']}'),
                            kRowText('Extra Charges: ', kAmount(data[index]['additionalCharge'])),
                            kRowText('Start Time: ', DateFormat('hh:mm a').format(DateTime.parse('${data[index]['start_time'].toDate()}'))),
                            kRowText('End Time: ', DateFormat('hh:mm a').format(DateTime.parse('${data[index]['end_time'].toDate()}'))),
                            kRowText('Available: ', data[index]['isAvailable'] != true ? 'No' : 'Yes'),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => EditEvent(
                                initialDate: widget.initialDate,
                                  eventID: data[index].reference.id)));
                        },
                        icon: Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: (){
                          deletePopUp(context, onClickYes: (){
                            _firestore.collection('user_calender').doc(data[index].reference.id).delete();
                            Navigator.pop(context);
                          });
                        },
                        icon: Icon(Icons.delete_forever_outlined),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10);
              },
            ) : EmptyScreen(message: 'No Events Added');
          }
          return LoadingIcon();
        }
      ),
    );
  }
}
