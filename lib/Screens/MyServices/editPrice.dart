import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/kDatabase.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';


class EditPrice extends StatefulWidget {

  String categoryID;
  String serviceID;
  int priceIndex;
  EditPrice({super.key, required this.categoryID, required this.serviceID, required this.priceIndex});

  @override
  State<EditPrice> createState() => _EditPriceState();
}

class _EditPriceState extends State<EditPrice> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController price = TextEditingController();
  TextEditingController priceName = TextEditingController();
  TextEditingController duration = TextEditingController();
  TextEditingController discountPrice = TextEditingController();

  String priceNameValue = '';
  String priceImage = '';
  String imageURL = '';
  String priceUnitValue = 'Hourly';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getPriceData();
  }

  void getPriceData() async {
    var collection = _firestore.collection('service');
    var docs = await collection.doc(widget.serviceID).get();
    var data = docs.data()!['price'][widget.priceIndex];
    price.text = '${data['price']}';
    discountPrice.text = '${data['discPrice']}';
    duration.text = '${data['duration']}';
    priceUnitValue = '${data['priceUnit']}';
    priceName.text = '${data['name'][0]['text']}';
    priceNameValue = '${data['name'][0]['text']}';
    // imageURL = '${data['image']['serverPath']}';
    priceImage = '${data['image']['serverPath']}';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Price'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 5),
              KTextField(
                title: 'Price',
                controller: price,
                textInputType: TextInputType.number,
              ),
              // KTextField(
              //   title: 'Discount Price',
              //   controller: discountPrice,
              //   textInputType: TextInputType.number,
              // ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price Unit', style: kBoldStyle()),
                    Container(
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      decoration: dropTextFieldDesign(context),
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton(
                            borderRadius: BorderRadius.circular(10.0),
                            value: priceUnitValue != '' ? priceUnitValue : null,
                            hint: Text('Price Unit'),
                            items: priceUnitList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                priceUnitValue = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if(priceUnitValue != 'Hourly')
                KTextField(
                  title: 'Duration in min',
                  controller: duration,
                  textInputType: TextInputType.number,
                ),
              // KTextField(title: 'Price Name', controller: priceName),

              StreamBuilder(
                  stream: _firestore.collection('category').doc(widget.categoryID)
                      .collection('subCategory').orderBy('name').snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      List subCategoryList = [];
                      var mainCategory = snapshot.data!.docs;
                      for(var category in mainCategory){
                        subCategoryList.add(category);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, left: 10.0),
                            child: Text('Price Name',
                                style: kSmallText().copyWith(
                                    fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            child: Container(
                              height: 65,
                              padding: EdgeInsets.symmetric(vertical: 5),
                              width: MediaQuery.of(context).size.width,
                              decoration: dropTextFieldDesign(context),
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton(
                                    borderRadius: BorderRadius.circular(10.0),
                                    value: priceNameValue != '' ? priceNameValue : null,
                                    hint: Text('Price Name', style: hintTextStyle(context)),
                                    items: subCategoryList
                                        .map<DropdownMenuItem>((value) {
                                      return DropdownMenuItem(
                                        value: value['name'],
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 65,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  image: DecorationImage(
                                                    image: NetworkImage(value['image']),
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
                                            priceImage = '${value['image']}';
                                          });
                                        },
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        priceNameValue = newValue;
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

              SizedBox(height: 5.0),
              // if(imageURL != '' && image == null)
              //   Container(
              //     height: 100,
              //     width: 100,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(10.0),
              //       image: DecorationImage(
              //         image: NetworkImage(imageURL),
              //         fit: BoxFit.cover,
              //       )
              //     ),
              //   ),
              // if(image != null)
              //   Padding(
              //     padding: const EdgeInsets.all(10.0),
              //     child: Image.file(File(image), height: 100),
              //   ),
              // SizedBox(height: 5.0),
              // Center(
              //   child: KButton(
              //     title: 'Change Image',
              //     onClick: (){
              //       showModalBottomSheet(
              //         context: context,
              //         builder: (context){
              //           return ImagePickerPopUp(
              //             onCameraClick: (){
              //               Navigator.pop(context);
              //               pickImageFromCamera();
              //             },
              //             onGalleryClick: (){
              //               Navigator.pop(context);
              //               pickImageFromGallery();
              //             },
              //           );
              //         },
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: isLoading != true ? KButton(
        title: 'Save',
        onClick: () async {
          if(_formKey.currentState!.validate()) {
            setState(() {
              isLoading = true;
            });
            editPriceAtIndex().then((value) => {
              Navigator.pop(context),
              toastMessage(message: 'Update Successful'),
            });
          }
        },
      ) : LoadingButton(),
    );
  }

  Future<void> editPriceAtIndex() async {

    final CollectionReference collection = _firestore.collection('service');
    final DocumentReference docRef = collection.doc(widget.serviceID);
    try {
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          List<dynamic> priceData = docSnapshot['price'];
          priceData[widget.priceIndex] = {
            // 'discPrice': int.parse(discountPrice.text),
            'discPrice': 0,
            'duration': duration.text != '' ? int.parse(duration.text) : 0,
            'image': {
              'localFile': '',
              'serverPath': priceImage,
            },
            "name": [{
              'code': '',
              'text': priceNameValue,
            }],
            'price': int.parse(price.text),
            'priceUnit': priceUnitValue,
            'selected': true,
            'stock': 0,
          }; // Update the item at the specified index
          transaction.update(docRef, {'price': priceData});
          // print('Item at index ${widget.priceIndex} updated successfully');
        } else {
          // print('Document does not exist');
        }
      });
    } catch (e) {
      toastMessage(message: 'Error updating item', colors: kRedColor);
    }
  }
}
