import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Screens/splashScreen.dart';
import 'package:khwahish_provider/Services/FirebaseAPIMessage.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp();
  await NotificationCloud().initMethode();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: Constants.lightTheme,
      darkTheme: Constants.darkTheme,
      themeMode: ThemeMode.system,
      home: SplashScreen(),
    );
  }
}
