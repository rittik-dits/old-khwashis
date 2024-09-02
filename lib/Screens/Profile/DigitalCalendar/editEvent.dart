import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EditEvent extends StatefulWidget {

  DateTime initialDate;
  String eventID;
  EditEvent({super.key, required this.initialDate, required this.eventID});

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController event = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController startTime = TextEditingController();
  TextEditingController endTime = TextEditingController();
  TextEditingController additionalCharge = TextEditingController();

  // List<DateTime> recurringDates = [];
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
    getCalenderData();
  }

  void getCalenderData() async {
    var collection = _firestore.collection('user_calender');
    var docs = await collection.doc(widget.eventID).get();
    if(docs.exists){
      event.text = '${docs['event_name']}';
      date.text = DateFormat('dd/MM/yyyy').format(DateTime.parse('${widget.initialDate}'));
      startTime.text = DateFormat('hh:mm a').format(DateTime.parse('${docs['start_time'].toDate()}'));
      endTime.text = DateFormat('hh:mm a').format(DateTime.parse('${docs['end_time'].toDate()}'));
      selectedStartTime = TimeOfDay.fromDateTime(DateTime.parse('${docs['start_time'].toDate()}'));
      selectedEndTime = TimeOfDay.fromDateTime(DateTime.parse('${docs['end_time'].toDate()}'));
      isAvailable = docs['isAvailable'];
      additionalCharge.text = '${docs['additionalCharge']}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
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
                  // SfDateRangePicker(
                  //   view: DateRangePickerView.month,
                  //   monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: 6),
                  //   selectionMode: DateRangePickerSelectionMode.single,
                  //   showActionButtons: false,
                  //   minDate: DateTime.now(),
                  //   // initialSelectedDate: DateTime.now(),
                  //   onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  //
                  //     setState(() {
                  //       recurringDates = args.value.cast<DateTime>();
                  //     });
                  //   },
                  // ),
                  KTextField(
                    title: 'Date',
                    controller: date,
                    readOnly: true,
                  ),
                  SizedBox(height: 5),
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
            KTextField(
              title: 'Additional Charge',
              controller: additionalCharge,
              textInputType: TextInputType.number,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('Additional Charge if you want to charge more in some special occasion', style: k10Text(),),
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

    DateTime date = widget.initialDate;
    setState(() {});
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

    _firestore.collection('user_calender').doc(widget.eventID).update({
      'additionalCharge': additionalCharge.text != '' ? int.parse(additionalCharge.text) : 0,
      'end_time': endTime,
      'event_name': event.text,
      'isAvailable': isAvailable,
      'start_time': startTime,
      // 'userID': ServiceManager.userID,
    });

    Navigator.pop(context);
  }

}
