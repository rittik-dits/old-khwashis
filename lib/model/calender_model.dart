import 'package:cloud_firestore/cloud_firestore.dart';

class CalenderModel {
  int additionalCharge;
  Timestamp endTime;
  String eventName;
  bool isAvailable;
  Timestamp startTime;
  String userID;
  CalenderModel({
    required this.additionalCharge,
    required this.endTime,
    required this.eventName,
    required this.isAvailable,
    required this.startTime,
    required this.userID,
  });
}

// artistEventList.add(
// CalenderModel(
// additionalCharge: document['additionalCharge'],
// endTime: document['end_time'],
// eventName: document['event_name'],
// isAvailable: document['isAvailable'],
// startTime: document['start_time'],
// userID: document['userID'],
// ),
// );
