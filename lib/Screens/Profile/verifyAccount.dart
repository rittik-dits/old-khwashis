import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khwahish_provider/Components/DialogueBox/imagePickerPopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:image_cropper/image_cropper.dart';

class VerifyAccount extends StatefulWidget {
  const VerifyAccount({super.key});

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController panCard = TextEditingController();
  final TextEditingController aadhaar = TextEditingController();
  final TextEditingController passport = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _aadhaarFrontImage;
  File? _aadhaarBackImage;
  File? _panCardImage;
  File? _passportImage;
  bool isLoading = false;

  bool panCardVerified = false;
  bool documentUploaded = false;

  void pickImageFromGallery(int num) async {
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
        if (num == 1) {
          setState(() {
            _aadhaarFrontImage = File(croppedFile.path);
          });
        } else if (num == 2) {
          setState(() {
            _aadhaarBackImage = File(croppedFile.path);
          });
        } else if (num == 3) {
          setState(() {
            _panCardImage = File(croppedFile.path);
          });
        } else if (num == 4) {
          setState(() {
            _passportImage = File(croppedFile.path);
          });
        }
      }
    }
  }

  void pickImageFromCamera(int num) async {
    var pickedImage = await _picker.pickImage(source: ImageSource.camera);

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
        if (num == 1) {
          setState(() {
            _aadhaarFrontImage = File(croppedFile.path);
          });
        } else if (num == 2) {
          setState(() {
            _aadhaarBackImage = File(croppedFile.path);
          });
        } else if (num == 3) {
          setState(() {
            _panCardImage = File(croppedFile.path);
          });
        } else if (num == 4) {
          setState(() {
            _passportImage = File(croppedFile.path);
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    var collection = _firestore.collection('provider');
    var docs = await collection.doc(ServiceManager.userID).get();
    print(ServiceManager.userID);
    if (docs.exists) {
      aadhaar.text = '${docs['aadhaar']}';
      panCard.text = '${docs['panCard']}';
      passport.text = '${docs['passport']}';
      if (docs['aadhaar'] != '' && docs['panCard'] != '') {
        documentUploaded = true;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Account'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                if (documentUploaded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                      decoration: BoxDecoration(
                        color: kMainColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Your document is under process',
                        style: kLargeStyle(),
                      ),
                    ),
                  ),
                if (!documentUploaded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'To verify your account submit your document.',
                          style: k10Text(),
                        ),
                      ],
                    ),
                  ),
                if (!documentUploaded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '*You can upload either Aadhar card or Passport details along with Pan card details',
                            style: k10Text(),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 5),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      KTextField(
                        readOnly: documentUploaded,
                        title: 'Aadhaar Card Number',
                        controller: aadhaar,
                        textInputType: TextInputType.number,
                        textLimit: 12,
                        onChanged: (value) {
                          if (_formKey.currentState != null) {
                            _formKey.currentState!.validate();
                          }
                        },
                        validate: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 12) {
                            return 'Please Enter Proper Aadhaar Card Number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      _aadhaarFrontImage == null
                          ? SizedBox.shrink()
                          : Image.file(_aadhaarFrontImage!, height: 200.0),
                      !documentUploaded
                          ? KButton(
                              title: _aadhaarFrontImage == null
                                  ? 'Upload Aadhaar Front Image'
                                  : 'Change Aadhaar Front Image',
                              onClick: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ImagePickerPopUp(
                                      onCameraClick: () {
                                        Navigator.pop(context);
                                        pickImageFromCamera(1);
                                      },
                                      onGalleryClick: () {
                                        Navigator.pop(context);
                                        pickImageFromGallery(1);
                                      },
                                    );
                                  },
                                );
                              },
                            )
                          : disabledButton(title: 'Upload Aadhaar Front Image'),
                      SizedBox(height: 10),
                      _aadhaarBackImage == null
                          ? SizedBox.shrink()
                          : Image.file(_aadhaarBackImage!, height: 200.0),
                      !documentUploaded
                          ? KButton(
                              title: _aadhaarBackImage == null
                                  ? 'Upload Aadhaar Back Image'
                                  : 'Change Aadhaar Back Image',
                              onClick: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ImagePickerPopUp(
                                      onCameraClick: () {
                                        Navigator.pop(context);
                                        pickImageFromCamera(2);
                                      },
                                      onGalleryClick: () {
                                        Navigator.pop(context);
                                        pickImageFromGallery(2);
                                      },
                                    );
                                  },
                                );
                              },
                            )
                          : disabledButton(title: 'Upload Aadhaar Back Image'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 2,
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Text(
                                'OR',
                                style: TextStyle(color: Colors.grey.shade900),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        child: TextFormField(
                          readOnly: documentUploaded,
                          controller: passport,
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            border: outlineBorderStyle(),
                            focusedBorder: focusBorderStyle(),
                            enabledBorder: enableBorderStyle(),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintText: 'Passport Number',
                            hintStyle: hintTextStyle(context),
                          ),
                          onChanged: (value) {
                            if (_formKey.currentState != null) {
                              _formKey.currentState!.validate();
                            }
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 8) {
                              return 'Please Enter Proper Passport Number';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      _passportImage == null
                          ? SizedBox.shrink()
                          : Image.file(_passportImage!, height: 200.0),
                      !documentUploaded
                          ? KButton(
                              title: _passportImage == null
                                  ? 'Upload Passport Image'
                                  : 'Change Passport Image',
                              onClick: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ImagePickerPopUp(
                                      onCameraClick: () {
                                        Navigator.pop(context);
                                        pickImageFromCamera(4);
                                      },
                                      onGalleryClick: () {
                                        Navigator.pop(context);
                                        pickImageFromGallery(4);
                                      },
                                    );
                                  },
                                );
                              },
                            )
                          : disabledButton(title: 'Upload Passport Image'),
                      SizedBox(height: 10),
                      KTextField(
                        readOnly: documentUploaded,
                        title: 'Pan Card Number',
                        controller: panCard,
                        //textCapitalization: TextCapitalization.characters,
                        textInputType: TextInputType.text,
                        //textLimit: 10,
                        onChanged: (value) {
                          if (_formKey.currentState != null) {
                            _formKey.currentState!.validate();
                          }
                        },
                        validate: (value) {
                          // Regular expression for validating PAN card number
                          String pattern = r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$';
                          RegExp regExp = RegExp(pattern);

                          if (value == null || value.isEmpty) {
                            return 'Please enter PAN card number';
                          } else if (!regExp.hasMatch(value)) {
                            return 'Please enter a valid PAN card number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      _panCardImage == null
                          ? SizedBox.shrink()
                          : Image.file(_panCardImage!, height: 200.0),
                      !documentUploaded
                          ? KButton(
                              title: _panCardImage == null
                                  ? 'Upload Pan Card Image'
                                  : 'Change Pan Card Image',
                              onClick: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return ImagePickerPopUp(
                                      onCameraClick: () {
                                        Navigator.pop(context);
                                        pickImageFromCamera(3);
                                      },
                                      onGalleryClick: () {
                                        Navigator.pop(context);
                                        pickImageFromGallery(3);
                                      },
                                    );
                                  },
                                );
                              },
                            )
                          : disabledButton(title: 'Upload Pan Card Image'),
                      SizedBox(height: 10),
                      !documentUploaded
                          ? !isLoading
                              ? KButton(
                                  title: 'Submit',
                                  //  isLoading: isLoading,
                                  onClick: () {
                                  //  if (_formKey.currentState!.validate()) {
                                      // Check if either Aadhaar or Passport details are provided
                                      if (aadhaar.text.isEmpty &&
                                          passport.text.isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Error'),
                                              content: Text(
                                                  'Please enter either Aadhaar card details or Passport details.'),
                                              actions: [
                                                TextButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        return;
                                      }

                                      // Check if PAN details are provided
                                      if (panCard.text.isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Error'),
                                              content: Text(
                                                  'Please enter PAN card details.'),
                                              actions: [
                                                TextButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        return;
                                      }

                                      // If Aadhaar details are provided, check if images are uploaded
                                      if (aadhaar.text.isNotEmpty) {
                                        if (_aadhaarFrontImage == null ||
                                            _aadhaarBackImage == null) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Error'),
                                                content: Text(
                                                    'Please upload Aadhaar front and back images.'),
                                                actions: [
                                                  TextButton(
                                                    child: Text('OK'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          return;
                                        }
                                      }

                                      // If Passport details are provided, check if image is uploaded
                                      if (passport.text.isNotEmpty) {
                                        if (_passportImage == null) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Error'),
                                                content: Text(
                                                    'Please upload Passport image.'),
                                                actions: [
                                                  TextButton(
                                                    child: Text('OK'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          return;
                                        }
                                      }

                                      // Check if PAN image is uploaded
                                      if (_panCardImage == null) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Error'),
                                              content: Text(
                                                  'Please upload PAN card image.'),
                                              actions: [
                                                TextButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        return;
                                      }

                                      setState(() {
                                        isLoading = true;
                                      });

                                      uploadDocument();
                                  //  }
                                  })
                              : LoadingButton()
                          : disabledButton(title: 'Submit'),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void uploadDocument() async {
    setState(() {
      isLoading = true;
    });
    try {
      String? aadhaarFrontImageURL;
      String? aadhaarBackImageURL;
      String? passportImageURL;

      if (_aadhaarFrontImage != null && _aadhaarBackImage != null) {
        aadhaarFrontImageURL = await ServiceManager()
            .uploadImage(_aadhaarFrontImage!.path, 'document');
        aadhaarBackImageURL = await ServiceManager()
            .uploadImage(_aadhaarBackImage!.path, 'document');
      }

      if (_passportImage != null) {
        passportImageURL = await ServiceManager()
            .uploadImage(_passportImage!.path, 'document');
      }

      String panCardImagePath =
          await ServiceManager().uploadImage(_panCardImage!.path, 'document');

      _firestore.collection('provider').doc(ServiceManager.userID).update({
        'aadhaar': aadhaar.text,
        'aadhaarBackImage': aadhaarBackImageURL,
        'aadhaarFrontImage': aadhaarFrontImageURL,
        'panCard': panCard.text,
        'panCardImage': panCardImagePath,
        'passport': passport.text,
        'passportImage': passportImageURL,
      }).then((value) => {
            Navigator.pop(context),
            toastMessage(message: 'Document Uploaded'),
          });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toastMessage(message: 'Something went wrong', colors: kRedColor);
    }
    setState(() {
      isLoading = false;
    });
  }
}

KButton disabledButton({required String title}) {
  return KButton(
    color: Colors.grey,
    title: title,
    onClick: () {},
  );
}





  //                                 onClick: () {
  //                                   if (_formKey.currentState!.validate()) {
  //                                   if (aadhaar.text.isEmpty &&
  //                                       passport.text.isEmpty) {
  //                                     showDialog(
  //                                       context: context,
  //                                       builder: (BuildContext context) {
  //                                         return AlertDialog(
  //                                           title: Text('Error'),
  //                                           content: Text(
  //                                               'Please enter either Aadhaar card details or Passport details.'),
  //                                           actions: [
  //                                             TextButton(
  //                                               child: Text('OK'),
  //                                               onPressed: () {
  //                                                 Navigator.of(context).pop();
  //                                               },
  //                                             ),
  //                                           ],
  //                                         );
  //                                       },
  //                                     );
  //                                     return;
  //                                   }

  //                                   if (panCard.text.isEmpty) {
  //                                     showDialog(
  //                                       context: context,
  //                                       builder: (BuildContext context) {
  //                                         return AlertDialog(
  //                                           title: Text('Error'),
  //                                           content: Text(
  //                                               'Please enter PAN card details.'),
  //                                           actions: [
  //                                             TextButton(
  //                                               child: Text('OK'),
  //                                               onPressed: () {
  //                                                 Navigator.of(context).pop();
  //                                               },
  //                                             ),
  //                                           ],
  //                                         );
  //                                       },
  //                                     );
  //                                     return;
  //                                   }

  //                                   if (aadhaar.text.isNotEmpty) {
  //                                     if (_aadhaarFrontImage == null ||
  //                                         _aadhaarBackImage == null) {
  //                                       showDialog(
  //                                         context: context,
  //                                         builder: (BuildContext context) {
  //                                           return AlertDialog(
  //                                             title: Text('Error'),
  //                                             content: Text(
  //                                                 'Please upload Aadhaar front and back images.'),
  //                                             actions: [
  //                                               TextButton(
  //                                                 child: Text('OK'),
  //                                                 onPressed: () {
  //                                                   Navigator.of(context).pop();
  //                                                 },
  //                                               ),
  //                                             ],
  //                                           );
  //                                         },
  //                                       );
  //                                       return;
  //                                     }
  //                                   }

  //                                   if (passport.text.isNotEmpty) {
  //                                     if (_passportImage == null) {
  //                                       showDialog(
  //                                         context: context,
  //                                         builder: (BuildContext context) {
  //                                           return AlertDialog(
  //                                             title: Text('Error'),
  //                                             content: Text(
  //                                                 'Please upload Passport image.'),
  //                                             actions: [
  //                                               TextButton(
  //                                                 child: Text('OK'),
  //                                                 onPressed: () {
  //                                                   Navigator.of(context).pop();
  //                                                 },
  //                                               ),
  //                                             ],
  //                                           );
  //                                         },
  //                                       );
  //                                       return;
  //                                     }
  //                                   }

  //                                   if (_panCardImage == null) {
  //                                     showDialog(
  //                                       context: context,
  //                                       builder: (BuildContext context) {
  //                                         return AlertDialog(
  //                                           title: Text('Error'),
  //                                           content: Text(
  //                                               'Please upload PAN card image.'),
  //                                           actions: [
  //                                             TextButton(
  //                                               child: Text('OK'),
  //                                               onPressed: () {
  //                                                 Navigator.of(context).pop();
  //                                               },
  //                                             ),
  //                                           ],
  //                                         );
  //                                       },
  //                                     );
  //                                     return;
  //                                   }

  //                                   setState(() {
  //                                     isLoading = true;
  //                                   });
  //                                   print("vr");
  //                                   uploadDocument();
  //                                   // }
  //                                   // else {
  //                                   //   showDialog(
  //                                   //     context: context,
  //                                   //     builder: (BuildContext context) {
  //                                   //       return AlertDialog(
  //                                   //         title: Text('Error'),
  //                                   //         content: Text(
  //                                   //             'Please fill the required fields correctly.'),
  //                                   //         actions: [
  //                                   //           TextButton(
  //                                   //             child: Text('OK'),
  //                                   //             onPressed: () {
  //                                   //               Navigator.of(context).pop();
  //                                   //             },
  //                                   //           ),
  //                                   //         ],
  //                                   //       );
  //                                   //     },
  //                                   //   );
  //                                   // }
  //  } }