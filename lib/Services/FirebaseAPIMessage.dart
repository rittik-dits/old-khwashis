import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:khwahish_provider/Screens/Booking/bookings.dart';
import 'package:khwahish_provider/main.dart';

class NotificationCloud {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String deviceToken = '';
  initMethode() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.data}");
      // Handle notification when the app is in the foreground
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      _handleNotificationClick(message);
      // Navigator.push(context, MaterialPageRoute(builder: (context) => Bookings()));
      // Handle notification when the app is in the background and opened via notification
    });

    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((value) => print(value));

    FirebaseMessaging.instance.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    Navigator.of(navigatorKey.currentContext!).push(
      MaterialPageRoute(builder: (context) => Bookings()),
    );
  }

  // Background message handler
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  Future<void> sendNotification(String title, String msgData,String fcmToken) async {
    // Replace 'your_device_token' with the device token of the device you want to receive the notification
    // You can get the device token after registering the device with Firebase Cloud Messaging
    // Or you can send notifications to topics instead of specific devices

    deviceToken = (await FirebaseMessaging.instance.getToken())!;
    print(deviceToken);
    // Send notification
    // Here you can use your preferred method to send notifications
    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAxtavygA:APA91bGj4TZNcNm7kn3G8ILUj7RF6CPfdL4jz6tzw4IO6n6F8-oH0xytZsH14Tt7VChr1BxU96LTlBgl5hUU99f0eO8hv1sAH-qdDEIeDdiTn-gYgpXuyEEEtJFxfC1UvQ6Fi9JbHVE5', // Replace 'your_server_key' with your Firebase project's server key
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': msgData,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'full_screen_intent': true,
            },
            'to': fcmToken,
          },
        ),
        // ignore: invalid_return_type_for_catch_error
      );
      if (response.statusCode == 200) {
        //  print(response.toString());
        // Notification sent successfully
        print("Notification sent successfully");
        print(response.body);
      } else {
        // Notification failed to send
        print("Failed to send notification. Status code: ${response.body}");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
