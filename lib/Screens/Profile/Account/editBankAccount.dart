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

class EditBankAccount extends StatefulWidget {

  String accountID;
  EditBankAccount({super.key, required this.accountID});

  @override
  State<EditBankAccount> createState() => _EditBankAccountState();
}

class _EditBankAccountState extends State<EditBankAccount> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController accountHolderName = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController branch = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  TextEditingController ifscCode = TextEditingController();

  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();
  File? _image;
  void pickImageFromGallery() async {
    var pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
    });
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
    getAccountData();
  }

  String uploadedImage = '';
  void getAccountData() async {
    var collection = _firestore.collection('bankAccount');
    var docs = await collection.doc(widget.accountID).get();
    if(docs.exists){
      accountHolderName.text = '${docs['accountHolderName']}';
      bankName.text = '${docs['bankName']}';
      branch.text = '${docs['branch']}';
      accountNumber.text = '${docs['accountNumber']}';
      ifscCode.text = '${docs['ifscCode']}';
      uploadedImage = '${docs['chequeImage']}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Account'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              KTextField(
                title: 'Account Holder Name',
                controller: accountHolderName,
              ),
              KTextField(title: 'Bank Name', controller: bankName,),
              KTextField(title: 'Branch', controller: branch,),
              KTextField(
                title: 'Account Number',
                controller: accountNumber,
              ),
              KTextField(
                title: 'IFSC Code',
                controller: ifscCode,
                textLimit: 11,
              ),
              if(uploadedImage != '' && _image == null)
              SizedBox(
                height: 100,
                child: Image.network(uploadedImage),
              ),
              SizedBox(height: 5),
              if(_image != null)
                SizedBox(
                  height: 100,
                  child: Image.file(File(_image!.path)),
                ),
              SizedBox(height: 5),
              KButton(
                title: 'Upload Cancel Cheque',
                onClick: (){
                  showModalBottomSheet(
                      context: context,
                      builder: (context){
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
                      }
                  );
                },
              ),
              kSpace(),
              isLoading != true ? KButton(
                title: 'Save',
                onClick: (){
                  if(_formKey.currentState!.validate()){
                    setState(() {
                      isLoading = true;
                    });
                    addAccount(context);
                  }
                },
              ) : LoadingButton(),
            ],
          ),
        ),
      ),
    );
  }

  void addAccount(context) async {

    if(_image != null) {
      String checkImage = await ServiceManager().uploadImage(_image!.path, 'bankAccount');
      setState(() {});
    }

    try {
      _firestore.collection('bankAccount').doc(widget.accountID).update({
        'accountHolderName': accountHolderName.text,
        'accountNumber': accountNumber.text,
        'bankName': bankName.text,
        'branch': branch.text,
        // 'chequeImage': checkImage,
        // 'createdAT': DateTime.now(),
        'ifscCode': ifscCode.text,
        // 'isDeleted': false,
        // 'isVerified': false,
        // 'userID': ServiceManager.userID,
      });
      Navigator.pop(context);
      toastMessage(message: 'Account Added');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }
}
