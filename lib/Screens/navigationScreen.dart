import 'package:flutter/material.dart';
import 'package:khwahish_provider/Screens/Booking/bookings.dart';
import 'package:khwahish_provider/Screens/Booking/bookings2.dart';
import 'package:khwahish_provider/Screens/Chat/messagePage.dart';
import 'package:khwahish_provider/Screens/Home/homePage.dart';
import 'package:khwahish_provider/Screens/MyServices/myServices.dart';
import 'package:khwahish_provider/Screens/Profile/profilePage.dart';
import 'package:khwahish_provider/Services/location.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MyServices(),
    Bookings2(),
    MessagePage(),
    // ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    ServiceManager().getUserID();
    if(ServiceManager.userID != ''){
      LocationService().fetchLocation();
      ServiceManager().getUserData();
      ServiceManager().getSettings();
    }
  }

  Future<bool> _onBackPressed() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: <BottomNavigationBarItem>[
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.cottage_outlined),
            //   activeIcon: Icon(Icons.cottage),
            //   label: 'Home',
            // ),
            BottomNavigationBarItem(
              icon: Image.asset('images/icon.png', height: 25),
              activeIcon: Image.asset('images/icon.png', height: 25, color: kMainColor),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_repair_service_outlined),
              activeIcon: Icon(Icons.home_repair_service),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border_outlined),
              activeIcon: Icon(Icons.bookmark),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              activeIcon: Icon(Icons.message_outlined),
              label: 'Chat',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.person_outline),
            //   activeIcon: Icon(Icons.person),
            //   label: 'Profile',
            // ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: kMainColor,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
