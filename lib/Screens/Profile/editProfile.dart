import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khwahish_provider/Components/DialogueBox/imagePickerPopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/kDatabase.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Profile/subscriptionPage.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController correspondingEmail = TextEditingController();
  TextEditingController mobile = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String genderValue = '';

  final ImagePicker _picker = ImagePicker();
  File? _image;
  void pickImageFromGallery() async {
    var pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: kMainColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
      }
    }
  }

  void pickImageFromCamera() async {
    var pickedImage = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(pickedImage!.path);
    });
  }

  @override
  void initState() {
    super.initState();
    print(ServiceManager.userID);
    getUserData();
  }

  String uploadedImage = '';
  void getUserData() async {
    var collection = _firestore.collection('provider');
    var docs = await collection.doc(ServiceManager.userID).get();
    if (docs.exists) {
      uploadedImage = '${docs['logoServerPath']}';
      String middleName =
          docs['middleName'] != '' ? '${docs['middleName']} ' : '';
      name.text = '${docs['firstName']} $middleName${docs['lastName']}';
      email.text = '${docs['login']}';
      correspondingEmail.text = '${docs['email']}';
      mobile.text = '${docs['phone']}';
      genderValue = '${docs['gender']}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundColor:
                      Theme.of(context).scaffoldBackgroundColor != Colors.black
                          ? Colors.white
                          : kDarkColor,
                  child: _image != null
                      ? CircleAvatar(
                          radius: 70,
                          backgroundImage: FileImage(File(_image!.path)),
                        )
                      : uploadedImage == ''
                          ? CircleAvatar(
                              radius: 70,
                              backgroundImage:
                                  AssetImage('images/img_blank_profile.png'),
                            )
                          : CircleAvatar(
                              radius: 70,
                              backgroundImage: NetworkImage(uploadedImage),
                            ),
                ),
                Positioned(
                  right: 0.0,
                  bottom: 0.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    radius: 20,
                    child: IconButton(
                      icon: Icon(Icons.edit_outlined),
                      color: Colors.white,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return ImagePickerPopUp(
                              onCameraClick: () {
                                Navigator.pop(context);
                                pickImageFromCamera();
                              },
                              onGalleryClick: () {
                                Navigator.pop(context);
                                pickImageFromGallery();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            kSpace(),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  KTextField(title: 'Name', controller: name),
                  KTextField(
                    title: 'Mobile',
                    controller: mobile,
                    textInputType: TextInputType.number,
                    textLimit: 10,
                  ),
                ],
              ),
            ),
            KTextField(
              title: 'Email',
              controller: email,
              readOnly: true,
            ),
            KTextField(
              title: 'Corresponding Email',
              controller: correspondingEmail,
              suffixButton: IconButton(
                onPressed: () {
                  toastMessage(
                      message: 'Corresponding email is an alternative'
                          ' email in case you get any trouble using your primary'
                          ' email');
                },
                icon: Icon(Icons.info_outline, color: kMainColor),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Gender', style: k10Text()),
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
                          hint: Text(
                            'Select Gender',
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
            kSpace(),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10.0),
                decoration: roundedContainerDesign(context),
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    Image.asset('images/app_logo.png', height: 100),
                    SizedBox(height: 10.0),
                    Text(ServiceManager.supportEmail, style: k14Style()),
                    Text(ServiceManager.companyNumber, style: k14Style()),
                    SizedBox(height: 10.0),
                    ServiceManager.isSubscribed != false
                        ? Column(
                            children: [
                              Text(
                                  'Subscription Start Date: ${ServiceManager.subscriptionStartDate}'),
                              Text(
                                  'Subscription End Date: ${ServiceManager.subscriptionEndDate}'),
                              SizedBox(height: 10.0),
                              Text(
                                "Thank you for being such a valuable member.",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Text(
                                'You are not a Subscribed Member',
                                textAlign: TextAlign.center,
                              ),
                              kSpace(),
                              KButton(
                                title: 'Subscribe Now',
                                onClick: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SubscriptionPage()));
                                },
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            kSpace(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            'Forget password? A password verification link will be send to your email address '),
                    TextSpan(
                      text: 'Reset Password',
                      style: linkTextStyle(),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          resetPassword();
                        },
                    ),
                  ],
                ),
              ),
            ),
            kSpace(),
            kBottomSpace(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoading != true
          ? KButton(
              title: 'Save',
              onClick: () {
                //ServiceManager().updateAll();
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isLoading = true;
                  });
                  updateProfile(context);
                }
              },
            )
          : LoadingButton(),
    );
  }

  void updateProfile(context) async {
    if (_image != null) {
      String imagePath =
          await ServiceManager().uploadImage(_image!.path, 'provider');
      setState(() {
        uploadedImage = imagePath;
      });
    }

    try {
      _firestore.collection('provider').doc(ServiceManager.userID).update({
        'email': correspondingEmail.text,
        'firstName': ServiceManager().getFirstName(name.text),
        'middleName': ServiceManager().getMiddleName(name.text),
        'lastName': ServiceManager().getLastName(name.text),
        'phone': mobile.text,
        'gender': genderValue,
        'logoServerPath': uploadedImage,
      });
      Navigator.pop(context);
      ServiceManager().getUserData();
      toastMessage(message: 'Profile Updated');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: ServiceManager.userEmail);
      toastMessage(
          message: 'Password reset link was sent to your email',
          colors: kMainColor);
    } catch (e) {
      print(e.toString());
    }
  }
}
