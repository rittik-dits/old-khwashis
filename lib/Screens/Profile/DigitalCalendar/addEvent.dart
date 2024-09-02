import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Notification/notificationApi.dart';
import 'package:khwahish_provider/Screens/Profile/DigitalCalendar/digitalCalendar.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController event = TextEditingController();
  TextEditingController startTime = TextEditingController();
  TextEditingController endTime = TextEditingController();
  TextEditingController additionalCharge = TextEditingController();

  List<DateTime> recurringDates = [];
  bool isAvailable = false;
  bool isLoading = false;

  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();
  Future<void> _selectTime(BuildContext context, int type) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      if(type == 1){
        selectedStartTime = pickedTime;
        startTime.text = selectedStartTime.format(context);
      } else if(type == 2) {
        selectedEndTime = pickedTime;
        endTime.text = selectedEndTime.format(context);
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    // getUserCalenderData();
  }

  DateTime _startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  DateTime _startOfNextDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 1);
  }

  bool alreadyAddedPrice = false;
  void getUserCalenderData(DateTime eventDate) async {
    DateTime startOfDay = _startOfDay(eventDate);
    DateTime endOfNextDay = _startOfNextDay(eventDate);
    QuerySnapshot snapshot = await _firestore.collection('user_calender')
        .where('userID', isEqualTo: ServiceManager.userID)
        .where('start_time', isGreaterThanOrEqualTo: startOfDay)
        .where('start_time', isLessThan: endOfNextDay)
        .where('additionalCharge', isGreaterThan: 0)
        .get();

    setState(() {
      alreadyAddedPrice = snapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  KTextField(
                    title: 'Event',
                    controller: event,
                  ),
                  SizedBox(height: 5),
                  SfDateRangePicker(
                    view: DateRangePickerView.month,
                    monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: 6),
                    selectionMode: DateRangePickerSelectionMode.multiple,
                    showActionButtons: false,
                    minDate: DateTime.now(),
                    // initialSelectedDate: DateTime.now(),
                    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                      // print(args.value);
                      setState(() {
                        recurringDates = args.value.cast<DateTime>();
                      });

                      for (int i = 0; i < args.value.length; i++) {
                        getUserCalenderData(args.value[i]);
                      }
                      if(args.value.isEmpty){
                        setState(() {
                          alreadyAddedPrice = false;
                        });
                      }
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: KTextField(
                          title: 'Start Time',
                          controller: startTime,
                          readOnly: true,
                          onClick: (){
                            _selectTime(context, 1);
                          },
                          suffixButton: Icon(Icons.schedule_outlined,
                            color: kMainColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: KTextField(
                          title: 'End Time',
                          controller: endTime,
                          readOnly: true,
                          onClick: (){
                            _selectTime(context, 2);
                          },
                          suffixButton: Icon(Icons.schedule_outlined,
                            color: kMainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            alreadyAddedPrice != true ?
            KTextField(
              title: 'Additional Charge',
              controller: additionalCharge,
              textInputType: TextInputType.number,
            ) : Text('Additional Price is already added in these dates',
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('Additional Charge if you want to charge more in some special occasion the additional charge will be applicable for whole day',
                style: k10Text(), textAlign: TextAlign.center,),
            ),
            ListTile(
              onTap: (){
                setState(() {
                  isAvailable = !isAvailable;
                });
              },
              leading: Icon(isAvailable ? Icons.check_box : Icons.check_box_outline_blank),
              title: Text('Are you available?'),
            ),
            kSpace(),
            isLoading != true ? KButton(
              title: 'Save',
              onClick: (){
                if(_formKey.currentState!.validate()){
                  addEventData();
                } else {
                  toastMessage(message: 'Fill the required field', colors: kRedColor);
                }
              },
            ) : LoadingButton(),
            kSpace(),
          ],
        ),
      ),
    );
  }

  void addEventData(){

    for(var date in recurringDates){

      DateTime startTime = DateTime(
        date.year,
        date.month,
        date.day,
        selectedStartTime.hour,
        selectedStartTime.minute,
      );

      DateTime endTime = DateTime(
        date.year,
        date.month,
        date.day,
        selectedEndTime.hour,
        selectedEndTime.minute,
      );

      _firestore.collection('user_calender').add({
        'additionalCharge': additionalCharge.text != '' ? int.parse(additionalCharge.text) : 0,
        'end_time': endTime,
        'event_name': event.text,
        'isAvailable': isAvailable,
        'start_time': startTime,
        'userID': ServiceManager.userID,
      });

      NotificationApi.showScheduleNotification(
        title: 'Khwahish',
        body: 'You have got a event: ${event.text}',
        payload: 'Scheduled notification',
        scheduledDate: startTime,
      );
    }
    Navigator.pop(context);
  }

}
