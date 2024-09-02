import 'package:flutter/material.dart';
import 'package:khwahish_provider/Screens/Notification/notificationApi.dart';
import 'package:khwahish_provider/Screens/Notification/secondPage.dart';
import 'package:khwahish_provider/Theme/colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  @override
  void initState() {
    super.initState();
    NotificationApi.init(initScheduled: true);
    listenNotification();
  }

  void listenNotification () => NotificationApi.onNotifications.stream.listen(onClickNotification);

  void onClickNotification (String? payload) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecondPage(payload: payload)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildButton(
              title: 'Simple Notification',
              iconData: Icons.notifications,
              onClicked: (){
                NotificationApi.showNotification(
                  title: 'Hello User',
                  body: "Hey ! This is a test notification",
                  payload: 'this is payload',
                );
              },
            ),
            buildButton(
              title: 'Scheduled Notification',
              iconData: Icons.notifications_active,
              onClicked: (){
                NotificationApi.showScheduleNotification(
                  title: 'Scheduled Notification',
                  body: 'this is a test notification',
                  payload: 'Scheduled notification',
                  scheduledDate: DateTime.now().add(Duration(seconds: 5)),
                );

                final snackBar = SnackBar(
                  content: Text('Scheduled after 5 sec', style: TextStyle(fontSize: 16)),
                  backgroundColor: Colors.green,
                );
                ScaffoldMessenger.of(context)..removeCurrentSnackBar()
                ..showSnackBar(snackBar);
              },
            ),
            buildButton(
              title: 'Remove Notification',
              iconData: Icons.delete_outline,
              onClicked: (){
                NotificationApi.cancelAll();
              },
            ),
          ],
        ),
      ),
    );
  }


  Padding buildButton({required String title, required IconData iconData, required Function() onClicked}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
      child: MaterialButton(
        height: 45.0,
        color: kMainColor,
        textColor: kBTextColor,
        onPressed: onClicked,
        child: Row(
          children: [
            Icon(iconData),
            SizedBox(width: 10.0),
            Text(title, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
