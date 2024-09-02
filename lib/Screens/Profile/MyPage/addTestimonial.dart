import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khwahish_provider/Components/DialogueBox/imagePickerPopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddTestimonial extends StatefulWidget {
  const AddTestimonial({super.key});

  @override
  State<AddTestimonial> createState() => _AddTestimonialState();
}

class _AddTestimonialState extends State<AddTestimonial> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController description = TextEditingController();

  String categoryID = '';
  bool isLoading = false;

  File? _image;
  File? _video;
  final ImagePicker _picker = ImagePicker();
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

  void pickVideoFromGallery() async {
    var pickedImage = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedImage != null) {
      File videoFile = File(pickedImage.path);
      int videoSize = await videoFile.length();

      if (videoSize <= 10 * 1024 * 1024) {
        setState(() {
          _video = videoFile;
          _generateThumbnail(pickedImage.path);
        });
      } else {
        toastMessage(message: 'Video size exceeds the limit', colors: kRedColor);
      }
    }
  }

  Uint8List _thumbnail = Uint8List(0);
  Future<void> _generateThumbnail(String path) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // Adjust as needed
      quality: 25, // Adjust as needed
    );

    setState(() {
      _thumbnail = thumbnail!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Testimonial'),
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
        child: Column(
          children: [
            Container(
              decoration: containerDesign(context),
              child: Column(
                children: [
                  SizedBox(height: 10),
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
                                    style: kSmallText().copyWith(
                                        fontWeight: FontWeight.bold)),
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
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5),
                                                      image: DecorationImage(
                                                        image: NetworkImage('${value['serverPath']}'),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(value['name']),
                                                ],
                                              ),
                                            ),
                                            onTap: (){
                                              setState(() {
                                                categoryID = value.reference.id;
                                              });
                                            },
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            // categoryValue = newValue;
                                            // subCategoryID = '';
                                            // subCategoryValue = '';
                                            // selectedSubCategories = [];
                                            // selectedSubCategoryName = [];
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
                  KTextField(title: 'Description', controller: description,),
                  kSpace(),

                  Column(
                    children: [
                      if(_image != null)
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(_image!.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      KButton(
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
                            },
                          );
                        },
                        title: _image == null ? 'Add Testimonial Image' : 'Change Testimonial Image',
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Row(
                      children: const [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _thumbnail.isNotEmpty ? Column(
                        children: [
                          Image.memory(_thumbnail),
                        ],
                      ) : SizedBox.shrink(),
                      KButton(
                        onClick: (){
                          pickVideoFromGallery();
                        },
                        title: _thumbnail.isEmpty ? 'Add Testimonial Video' : 'Change Video',
                      ),
                      Text('The video must be less than 10 MB', style: k10Text().copyWith(
                        color: kRedColor,
                      )),
                    ],
                  ),
                  kSpace(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: isLoading != true ? KButton(
                      title: 'Save',
                      onClick: (){
                        setState(() {
                          isLoading = true;
                        });
                        addTestimonialData(context);
                      },
                    ) : LoadingButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addTestimonialData(context) async {

    try {
      String imagePath = '';
      if(_image != null){
        imagePath = await ServiceManager().uploadImage(_image!.path, 'testimonial');
      }

      String videoPath = '';
      String thumbnailPath = '';
      if(_video != null){
        videoPath = await ServiceManager().uploadVideo(_video!.path, 'testimonial');
        thumbnailPath = await ServiceManager().uploadThumbnail(_thumbnail);
        setState(() {});
      }

      _firestore.collection('provider').doc(ServiceManager.userID).update({
        'testimonial': FieldValue.arrayUnion([{
          'category': categoryID,
          'description': description.text,
          'imagePath': imagePath,
          'thumbnail': thumbnailPath,
          'videoUrl': videoPath,
        }]),
      });
      Navigator.pop(context);
    } catch (e) {
      toastMessage(message: 'Something went wrong');
    }
  }
}
