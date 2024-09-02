import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:khwahish_provider/Screens/Notification/utils.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future notificationDetails() async {

    final largeIconPath = await Utils.downloadFile(
      'https://i1.sndcdn.com/avatars-000145515687-oihvyk-t500x500.jpg',
      'largeIcon',
    );

    final bigPicturePath = await Utils.downloadFile(
      'https://w0.peakpx.com/wallpaper/485/866/HD-wallpaper-artistic-painting-and-background-sad-paintings.jpg',
      'bigPicture',
    );

    final styleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
    );

    // final sound = 'notification_sound.wav';
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id 2',
        'channel name',
        channelDescription: 'channel description',
        // sound: RawResourceAndroidNotificationSound(sound.split('.').first),
        playSound: true,
        importance: Importance.max,
        styleInformation: styleInformation,
        priority: Priority.high,
      ),
      // iOS: IOSNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher_foreground');
    // final iOS = IOSInitializationSettings();
    final iOS = DarwinInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    //when app is closed
    final details = await _notifications.getNotificationAppLaunchDetails();
    if(details != null && details.didNotificationLaunchApp){
      onNotifications.add('This is payload');
    }

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) async {
        onNotifications.add(payload.payload);
      }
    );

    if(initScheduled) {
      tz.initializeTimeZones();
      final locationName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));

      // var locations = tz.timeZoneDatabase.locations;
      // final locationName = tz.getLocation(locations.keys.first); //Asia/Calcutta /wrong / africa
      // tz.setLocalLocation(locationName);
      // print(locationName);
    }
 }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async => _notifications.show(
    id,
    title,
    body,
    await notificationDetails(),
    payload: payload,
  );

  static void showScheduleNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async => _notifications.zonedSchedule(
    id,
    title,
    body,
    // _scheduleDaily(Time(ServiceManager.notificationHour, ServiceManager.notificationMinute, 0)),
    // _scheduleDaily(Time(14, 16, 0)),
    tz.TZDateTime.from(scheduledDate, tz.local), ///for a timing
    await notificationDetails(),
    payload: payload,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );

  // static tz.TZDateTime _scheduleDaily(Time time) {
  //   final now = tz.TZDateTime.now(tz.local);
  //   final scheduleDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
  //       time.hour, time.minute, time.second);
  //
  //   return scheduleDate.isBefore(now) ?
  //     scheduleDate.add(Duration(days: 1)) : scheduleDate;
  // }

  static void cancel(int id) => _notifications.cancel(id);

  static void cancelAll() => _notifications.cancelAll();
}