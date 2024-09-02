import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:khwahish_provider/Components/DialogueBox/logoutPopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Auth/login.dart';
import 'package:khwahish_provider/Screens/Profile/Account/bankAccount.dart';
import 'package:khwahish_provider/Screens/Profile/DigitalCalendar/digitalCalendar.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/galleryViewer.dart';
import 'package:khwahish_provider/Screens/Profile/Reel/reels.dart';
import 'package:khwahish_provider/Screens/Profile/Share/shareApp.dart';
import 'package:khwahish_provider/Screens/Profile/WorkArea/myWorkArea.dart';
import 'package:khwahish_provider/Screens/Profile/aboutUS.dart';
import 'package:khwahish_provider/Screens/Profile/coupons.dart';
import 'package:khwahish_provider/Screens/Profile/editProfile.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/myGallery.dart';
import 'package:khwahish_provider/Screens/Profile/MyPage/myPage.dart';
import 'package:khwahish_provider/Screens/Profile/myWallet.dart';
import 'package:khwahish_provider/Screens/Profile/privacyPolicy.dart';
import 'package:khwahish_provider/Screens/Profile/settings.dart';
import 'package:khwahish_provider/Screens/Profile/subscriptionPage.dart';
import 'package:khwahish_provider/Screens/Profile/termAndCondition.dart';
import 'package:khwahish_provider/Screens/Profile/verifyAccount.dart';
import 'package:khwahish_provider/Screens/notLogedInScreen.dart';
import 'package:khwahish_provider/Services/emailController.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if(ServiceManager.userID != ''){
      ServiceManager().getUserData();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.minScrollExtent) {
          yourFunctionToExecuteOnScroll();
        }
      });
      updateData();
    }
  }

  void yourFunctionToExecuteOnScroll() {
    ServiceManager().getUserData();
    setState(() {});
  }

  void updateData() async {
    String? currentToken = await FirebaseMessaging.instance.getToken();

    var collection = _firestore.collection('provider');
    var docs = await collection.doc(ServiceManager.userID).get();
    if(docs.exists){
      if(docs['FCM'] != currentToken){
        _firestore.collection('provider').doc(ServiceManager.userID).update({
          'FCM': '$currentToken',
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ServiceManager.userID != '' ? Container(
      decoration: kBackgroundDesign(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: shadedTopGradient(),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: Container(
              height: 150,
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 0),
              child: Image.asset('images/khwahish_name.png'),
            ),
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    height: 110.0,
                    padding: EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width,
                    // decoration: containerDesign(context),
                    decoration: blurCurveDecor(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 41,
                                backgroundColor: kMainColor,
                                child: ServiceManager.profileURL == '' ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: AssetImage('images/img_blank_profile.png'),
                                ) : GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => ImageViewer(
                                            imageURL: ServiceManager.profileURL)));
                                  },
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(ServiceManager.profileURL),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('${ServiceManager.userName} ', style: kHeaderStyle()),
                              if(ServiceManager.isVerified != false)
                              Icon(Icons.verified, color: kMainColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              kSpace(),
              Container(
                decoration: blurCurveDecor(context),
                child: Column(
                  children: [
                    profileButton(Icons.person_outline, 'Edit Profile', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
                    }),
                    if(ServiceManager.isVerified != true)
                    profileButton(Icons.person_outline, 'Verify Account', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyAccount()));
                    }),
                    profileButton(Icons.pages_outlined, 'My Page', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
                    }),
                    profileButton(Icons.photo_library_outlined, 'My Gallery', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyGallery()));
                    }),
                    profileButton(Icons.map_outlined, 'My Work Area', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyWorkArea()));
                    }),
                    profileButton(Icons.home_repair_service_outlined, 'My Coupons', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Coupons()));
                    }),
                    profileButton(Icons.share_sharp, 'Refer and Earn', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ReferScreen()));
                    }),
                    profileButton(Icons.account_balance_wallet_outlined, 'My Wallet', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyWallet()));
                    }),
                    profileButton(Icons.account_balance_outlined, 'Bank Account', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BankAccount()));
                    }),
                    profileButton(Icons.calendar_month_outlined, 'Digital Calendar', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DigitalCalendar()));
                    }),
                    profileButton(Icons.movie_filter_outlined, 'Reels', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Reels()));
                    }),
                    // profileButton(Icons.settings_outlined, 'Settings', (){
                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
                    // }),
                  ],
                ),
              ),
              kSpace(),
              Container(
                decoration: blurCurveDecor(context),
                child: Column(
                  children: [
                    profileButton(Icons.policy_outlined, 'Privacy Policy', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicy()));
                    }),
                    profileButton(Icons.info_outline, 'About Us', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUS()));
                    }),
                    profileButton(Icons.report_gmailerrorred, 'Terms and condition', (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TermAndCondition()));
                    }),
                  ],
                ),
              ),
              kSpace(),
              ServiceManager.isSubscribed==false?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    side: MaterialStateProperty.all(BorderSide(color: kRedColor)),
                    foregroundColor: MaterialStateProperty.all(kRedColor),
                  ),
                  onPressed: (){
                     Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPage()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Subscribe'.toUpperCase()),
                    ],
                  ),
                ),
              ):Container(),
              
              kSpace(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    side: MaterialStateProperty.all(BorderSide(color: kRedColor)),
                    foregroundColor: MaterialStateProperty.all(kRedColor),
                  ),
                  onPressed: (){
                    logoutBuilder(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Log Out'.toUpperCase()),
                    ],
                  ),
                ),
              ),
              kSpace(),
              Text('version 1.0.7', style: kSmallText()),
              TextButton(
                onPressed: (){
                  deleteAccountPopUp(context);
                },
                child: Text('Delete Account'),
              ),
              kSpace(),
            ],
          ),
        ),
      ),
    ) : NotLoggedInScreen();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<String?> deleteAccountPopUp(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        title: Text('Delete Account', style: kHeaderStyle()),
        content: Text('Are you sure you want to delete your account?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              ServiceManager().removeUser();
              toastMessage(message: 'Account Deleted');
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (context) => Login()), (route) => false);
              try {
                _googleSignIn.disconnect();
              } catch (e) {
                print("Error signing out: $e");
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
