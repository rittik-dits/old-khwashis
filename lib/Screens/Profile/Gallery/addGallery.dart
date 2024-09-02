import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class AddGallery extends StatefulWidget {
  const AddGallery({super.key});

  @override
  State<AddGallery> createState() => _AddGalleryState();
}

class _AddGalleryState extends State<AddGallery> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String categoryID = '';
  String categoryValue = '';
  bool isLoading = false;

  List<XFile> _selectedImages = [];
  Future<void> _pickImages() async {
    List<XFile>? images = await ImagePicker().pickMultiImage(
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images;
      });

      // Handle the selected images
      for (var image in images) {
        // Do something with each selected image (e.g., display or upload)
        print(image.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Gallery'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                                  value: categoryValue != '' ? categoryValue : null,
                                  hint: Text('Category', style: hintTextStyle(context)),
                                  items: categoryList
                                      .map<DropdownMenuItem>((value) {
                                    return DropdownMenuItem(
                                      value: value['name'],
                                      child: Text(value['name']),
                                      onTap: (){
                                        setState(() {
                                          categoryID = value.reference.id;
                                        });
                                      },
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      categoryValue = newValue;
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
            if(_selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: FileImage(File(_selectedImages[index].path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -10,
                          right: -10,
                          child: IconButton(
                            onPressed: (){
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            icon: Icon(Icons.highlight_remove, color: kMainColor),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            SizedBox(height: 10),
            Center(
              child: KButton(
                title: 'Add Images',
                onClick: (){
                  _pickImages();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoading != true ? KButton(
        title: 'Save',
        onClick: (){
          if(categoryID != '') {
            if(_selectedImages.isNotEmpty){
              setState(() {
                isLoading = true;
              });
              addImageToGallery();
            } else {
              toastMessage(message: 'Pick Images');
            }
          } else {
            toastMessage(message: 'Select Category');
          }
        },
      ) : LoadingButton(),
    );
  }

  void addImageToGallery() async {

    List galleryImages = [];
    if(_selectedImages.isNotEmpty){
      for(var item in _selectedImages){
        String imagePath = await ServiceManager().uploadImage(item.path, 'artistGallery');
        setState(() {
          galleryImages.add({
            'categoryID': categoryID,
            'image': imagePath,
          });
        });
      }
    }

    _firestore.collection('provider').doc(ServiceManager.userID).update({
      'gallery': FieldValue.arrayUnion(galleryImages),
    }).then((value) => {
      Navigator.pop(context),
      toastMessage(message: 'Image added'),
    });

  }
}
