import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khwahish_provider/Components/DialogueBox/imagePickerPopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/kDatabase.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Auth/login.dart';
import 'package:khwahish_provider/Screens/Profile/privacyPolicy.dart';
import 'package:khwahish_provider/Screens/Profile/termAndCondition.dart';
import 'package:khwahish_provider/Screens/navigationScreen.dart';
import 'package:khwahish_provider/Screens/setLocation.dart';
import 'package:khwahish_provider/Services/emailController.dart';
import 'package:khwahish_provider/Services/location.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController desc = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController referral = TextEditingController();

  String categoryID = '';
  // String subCategoryID = '';
  // List selectedSubCategories = [];
  bool agreeWithTerms = false;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String stateValue = '';
  String genderValue = '';

  final ImagePicker _picker = ImagePicker();
  File? _image;
  void pickImageFromGallery() async {
    var pickedImage = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = File(pickedImage!.path);
    });
  }

  void pickImageFromCamera() async {
    var pickedImage = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = File(pickedImage!.path);
    });
  }

  DateTime selectedDate = DateTime.now();

  String selectedValue = '';

  @override
  void initState() {
    super.initState();
    getToken();
  }

  String firebaseFCMToken = '';
  void getToken() async {
    firebaseFCMToken = (await FirebaseMessaging.instance.getToken())!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBackgroundDesign(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Sign Up'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          // actions: [
          //   TextButton(
          //     onPressed: (){
          //       ServiceManager().updateAll();
          //     },
          //     child: Text('Update'),
          //   ),
          // ],
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  decoration: roundedShadedDesign(context),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text("Information needed to fulfill your Khwahish",
                                style: TextStyle(fontSize: 12), textAlign: TextAlign.center,
                              ),
                            ),
                            Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: CircleAvatar(
                                    radius: 56,
                                    backgroundColor: kMainColor,
                                    child: _image == null ? CircleAvatar(
                                      radius: 55,
                                      backgroundImage: AssetImage('images/img_blank_profile.png'),
                                    ) : CircleAvatar(
                                      radius: 55,
                                      backgroundImage: FileImage(File(_image!.path)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: IconButton(
                                      onPressed: (){
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context){
                                            return ImagePickerPopUp(
                                              onCameraClick: (){
                                                Navigator.pop(context);
                                                pickImageFromCamera();
                                              },
                                              onGalleryClick: (){
                                                Navigator.pop(context);
                                                pickImageFromGallery();
                                              },
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.0),
                            KTextField(
                              title: 'Name',
                              controller: name,
                              onChanged: (value){
                                _formKey.currentState!.validate();
                              },
                            ),
                            KTextField(
                              title: 'Mobile',
                              controller: mobile,
                              textLimit: 10,
                              textInputType: TextInputType.phone,
                              onChanged: (value){
                                _formKey.currentState!.validate();
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: email,
                                onChanged: (value){
                                  _formKey.currentState!.validate();
                                },
                                style: TextStyle(fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  border: outlineBorderStyle(),
                                  focusedBorder: focusBorderStyle(),
                                  enabledBorder: enableBorderStyle(),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                  // filled: true,
                                  // fillColor: Theme.of(context).scaffoldBackgroundColor,
                                  hintText: 'Email',
                                  hintStyle: hintTextStyle(context),
                                  labelText: 'Email',
                                  suffixIconColor: Colors.grey,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty || !value.contains('@') || !value.contains('.')) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            StreamBuilder(
                                stream: _firestore.collection('states').orderBy('name').snapshots(),
                                builder: (context, snapshot) {
                                  if(snapshot.hasData){
                                    var data = snapshot.data!.docs;
                                    List stateList = [];
                                    for(var item in data){
                                      stateList.add(item);
                                    }
                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                      child: Container(
                                        height: 45,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: dropTextFieldDesign(context),
                                        child: DropdownButtonHideUnderline(
                                          child: ButtonTheme(
                                            alignedDropdown: true,
                                            child: DropdownButton(
                                              isExpanded: true,
                                              borderRadius: BorderRadius.circular(10.0),
                                              value: stateValue != '' ? stateValue : null,
                                              hint: Text('Select State', style: hintTextStyle(context)),
                                              items: stateList
                                                  .map<DropdownMenuItem>((value) {
                                                return DropdownMenuItem(
                                                  value: value.reference.id,
                                                  child: Text('${value['name']}'),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                _formKey.currentState!.validate();
                                                setState(() {
                                                  stateValue = newValue;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return SizedBox.shrink();
                                }
                            ),
                            KTextField(
                              title: 'Select City',
                              controller: city,
                              readOnly: true,
                              onClick: (){
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context){
                                    return SetLocation();
                                  },
                                ).then((value) => setState((){
                                  city.text = LocationService.pickedCity;
                                  _formKey.currentState!.validate();
                                }));
                              },
                            ),
                            KTextField(
                              title: 'Address',
                              controller: address,
                              onChanged: (value){
                                _formKey.currentState!.validate();
                              },
                            ),
                            KTextField(
                              title: 'Pin Code',
                              controller: pincode,
                              onChanged: (value){
                                _formKey.currentState!.validate();
                              },
                            ),
                            KTextField(
                              title: 'Date of birth',
                              controller: dob,
                              readOnly: true,
                              onClick: (){
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context){
                                    return SizedBox(
                                      height: 270,
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.date,
                                        onDateTimeChanged: (DateTime value) {
                                          dob.text = '${value.day}/${value.month}/${value.year}';
                                          _formKey.currentState!.validate();
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Select Gender', style: kSmallText().copyWith(
                                  fontWeight: FontWeight.bold)),
                                  Container(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: dropTextFieldDesign(context),
                                    child: DropdownButtonHideUnderline(
                                      child: ButtonTheme(
                                        alignedDropdown: true,
                                        child: DropdownButton(
                                          borderRadius: BorderRadius.circular(10.0),
                                          value: genderValue != '' ? genderValue : null,
                                          hint: Text('Select Gender',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          items: genderList
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              genderValue = newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StreamBuilder(
                                stream: _firestore.collection('category').orderBy('name').snapshots(),
                                builder: (context, snapshot) {
                                  if(snapshot.hasData){
                                    List categoryList = [];
                                    var mainCategory = snapshot.data!.docs;
                                    for(var category in mainCategory){
                                      categoryList.add(category);
                                    }
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 5.0, left: 10.0),
                                          child: Text('Select Category',
                                              style: k12BoldStyle()),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                          child: Container(
                                            height: 45,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: dropTextFieldDesign(context),
                                            child: DropdownButtonHideUnderline(
                                              child: ButtonTheme(
                                                alignedDropdown: true,
                                                child: DropdownButton(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  value: categoryID != '' ? categoryID : null,
                                                  hint: Text('Category', style: hintTextStyle(context)),
                                                  items: categoryList
                                                      .map<DropdownMenuItem>((value) {
                                                    return DropdownMenuItem(
                                                      value: value.reference.id,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height: 50,
                                                              width: 50,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(5),
                                                                image: DecorationImage(
                                                                  image: NetworkImage(value['serverPath']),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 5),
                                                            Text(value['name']),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      categoryID = newValue;
                                                      // subCategoryID = '';
                                                      // selectedSubCategories = [];
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return Container();
                                }
                            ),
                            SizedBox(height: 5),
                            KTextField(
                              title: 'Password',
                              controller: password,
                              obscureText: obscurePassword,
                              suffixButton: IconButton(
                                onPressed: (){
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon: Icon(obscurePassword ?
                                Icons.visibility_outlined : Icons.visibility_off_outlined),
                              ),
                              validate: (value){
                                if (value!.isEmpty || value.length < 6) {
                                  return 'Please enter 6 digit password';
                                }
                                return null;
                              },
                              onChanged: (value){
                                _formKey.currentState!.validate();
                              },
                            ),
                            KTextField(
                              title: 'Confirm Password',
                              controller: confirmPassword,
                              obscureText: obscureConfirmPassword,
                              suffixButton: IconButton(
                                onPressed: (){
                                  setState(() {
                                    obscureConfirmPassword = !obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(obscureConfirmPassword ?
                                Icons.visibility_outlined : Icons.visibility_off_outlined),
                              ),
                              validate: (value){
                                if (value!.isEmpty || value.length < 6 || value != password.text) {
                                  return  value.length < 6 ?
                                  'Please enter 6 digit password' : "Password does not match";
                                }
                                return null;
                              },
                              onChanged: (value){
                                _formKey.currentState!.validate();
                              },
                            ),
                          ],
                        ),
                      ),
                      KTextField(
                        title: 'Referral Code',
                        controller: referral,
                      ),
                    ],
                  ),
                ),
              ),
              kSpace(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoSwitch(
                      value: agreeWithTerms,
                      onChanged: (value){
                        setState(() {
                          agreeWithTerms = value;
                        });
                      },
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(color: Colors.black54),
                          children: <TextSpan>[
                            TextSpan(text: 'I agree with '),
                            TextSpan(
                              text: 'Term & condition',
                              style: linkTextStyle(),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => TermAndCondition()));
                              },
                            ),
                            TextSpan(text: ' and that you have read our '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: linkTextStyle(),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicy()));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if(agreeWithTerms != false && isLoading != true)
              KButton(
                title: "Sign Up",
                onClick: (){
                  if(_formKey.currentState!.validate()){
                    if(stateValue != ''){
                      if(categoryID != ''){
                        if(_image != null){
                          if(password.text == confirmPassword.text){
                            setState(() {
                              isLoading = true;
                            });
                            registerWithEmailAndPassword(
                              email: email.text,
                              password: password.text,
                            );
                          } else {
                            toastMessage(message: "Password doesn't match", colors: kRedColor);
                          }
                        } else {
                          toastMessage(message: "Upload image", colors: kRedColor);
                        }
                      } else {
                        toastMessage(message: "Select Category", colors: kRedColor);
                      }
                    } else {
                      toastMessage(message: 'Select State', colors: kRedColor);
                    }
                  } else {
                    toastMessage(message: "Enter required fields", colors: kRedColor);
                  }
                },
              ),
              if(agreeWithTerms == false && isLoading == false)
              KButton(
                title: "Sign Up",
                color: Colors.grey.shade400,
                onClick: (){},
              ),
              if(isLoading != false)
                LoadingButton(),
              kSpace(),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.black54),
                  children: <TextSpan>[
                    TextSpan(text: 'Already a registered user ? '),
                    TextSpan(
                      text: 'Sign In',
                      style: linkTextStyle(),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                      },
                    ),
                  ],
                ),
              ),
              kBottomSpace(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> registerWithEmailAndPassword({
    required String email, required String password
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        setState(() {
          ServiceManager.userID = user.uid;
        });
        createUser(user.uid);
        // print(ServiceManager.userID);
        //  EmailController().sendMail(
        //     recipientEmail: ServiceManager.userEmail,
        //     mailMessage: 'Welcome to Khwahish! '
        //         'artist and would like to perform as an artist with your connection.'
        //         '\n UserID: ${user.uid}'
        // );
        EmailController().sendMail(
            recipientEmail: EmailController.adminEmail,
            mailMessage: 'I have registered to khwahish successfully as an '
                'artist and would like to perform as an artist with your connection.'
                '\n UserID: ${user.uid}'
        );
      } else {
        toastMessage(message: 'Registration Failed', colors: kRedColor);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // toastMessage(message: 'Invalid Email', colors: kRedColor);
      toastMessage(message: removeSquareBrackets('$e'), colors: kRedColor);
      setState(() {
        isLoading = false;
      });
    }
  }

  String removeSquareBrackets(String input) {
    return input.replaceAll(RegExp(r'\[.*?\]'), '');
  }

  void createUser(String userID) async {

    String imagePath = await ServiceManager().uploadImage(_image!.path, 'provider');

    _firestore.collection('provider').doc(userID).set({
      'FCM': firebaseFCMToken,
      'aadhaar': '',
      'aadhaarBackImage': '',
      'aadhaarFrontImage': '',
      'acceptOnlyInWorkArea': false,
      'acceptPaymentInCash': true,
      'addon': [],
      'address': city.text,
      'articles': [],
      'artistAddress': address.text,
      'audioGallery': [],
      'available': true,
      'pincode':pincode.text,
      'category': categoryID != '' ? [categoryID] : [],
      'cityID': LocationService.pickedCityID,
      'dateOfBirth': dob.text,
      'desc': [{
        'code': '',
        'text': '',
      }],
      'descTitle': [{
        'code': '',
        'text': '',
      }],
      'email': email.text,
      'facebook': '',
      'firstName': ServiceManager().getFirstName(name.text),
      'followers': [],
      'following': [],
      'gallery': [],
      'galleryVideos': [],
      'gender': genderValue,
      'imageUpperLocalFile': '',
      'imageUpperServerPath': '',
      'instagram': '',
      'isSubscribed': false,
      'isVerified': false,
      'lastName': ServiceManager().getLastName(name.text),
      'login': email.text,
      'logoLocalFile': '',
      'logoServerPath': imagePath,
      'middleName': ServiceManager().getMiddleName(name.text),
      'monthlyIncome': 0,
      'name': name.text,
      'panCard': '',
      'panCardImage': '',
      'passport':'',
      'passportImage':'',
      'phone': mobile.text,
      'referral': referral.text,
      'route': [],
      'selectedState': stateValue,
      'subscriptionStartDate': '',
      'subscriptionEndDate': '',
      'tax': '',
      'testimonial': [],
      'telegram': '',
      'visible': true,
      'workTime': [],
      'www': '',
      'avgRating': 0,
      'totalRating': 0,
      'todayIncome': 0,
      'weeklyIncome': 0,
      'todaysBooking': 0,
      'weekBooking': 0,
      'totalCash': 0,
      'twitter': '',
    }).then((value) => {
      setState(() {
        ServiceManager.userID = userID;
      }),
      ServiceManager().setUser(userID),
      ServiceManager().getUserID(),
      toastMessage(message: 'Registration Successful'),
      EmailController().sendMail(
        recipientEmail: email.text, //to user
        mailMessage: 'You have registered to khwahish successfully as an '
            'artist and you are ready to perform as an artist.',
      ),
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) => NavigationScreen()), (route) => false),
    });
    updateReferrerAccont(userID);
    updateReferrerAccontForUser(userID);
  }
  
  updateReferrerAccont(userID) async {
    var userDoc = await _firestore.collection('provider').doc(userID).get();
    String? referral = userDoc.data()?['referral'];
    if (referral != null && referral.isNotEmpty) {
      QuerySnapshot allDocs = await _firestore.collection('listusers').get();

      for (var doc in allDocs.docs) {
        if (doc.id.contains(referral)) {
          // Step 5: Update the 'wallet' field by incrementing it by 1
          await _firestore.collection('listusers').doc(doc.id).update({
            'wallet': FieldValue.increment(1),
          });
          break; // Assuming only one match is needed, break after the first match
        }
      }
    }
  }
  updateReferrerAccontForUser(userID) async {
    var userDoc = await _firestore.collection('provider').doc(userID).get();
    String? referral = userDoc.data()?['referral'];
    if (referral != null && referral.isNotEmpty) {
      QuerySnapshot allDocs = await _firestore.collection('provider').get();

      for (var doc in allDocs.docs) {
        if (doc.id.contains(referral)) {
          // Step 5: Update the 'wallet' field by incrementing it by 1
          await _firestore.collection('provider').doc(doc.id).update({
            'wallet': FieldValue.increment(1),
          });
          break; // Assuming only one match is needed, break after the first match
        }
      }
    }
  }

}
