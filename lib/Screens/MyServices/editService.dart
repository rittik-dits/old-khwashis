import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khwahish_provider/Components/DialogueBox/deletePopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/kDatabase.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/MyServices/addMyEvents.dart';
import 'package:khwahish_provider/Screens/MyServices/add_addOnPrice.dart';
import 'package:khwahish_provider/Screens/MyServices/editMyEvent.dart';
import 'package:khwahish_provider/Screens/MyServices/edit_addOnPrice.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:khwahish_provider/model/eventPrice.dart';
import 'package:khwahish_provider/model/subCategory.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class EditService extends StatefulWidget {
  String serviceID;
  EditService({super.key, required this.serviceID});

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController name = TextEditingController();
  TextEditingController tax = TextEditingController();
  TextEditingController descTitle = TextEditingController();
  TextEditingController desc = TextEditingController();
  TextEditingController duration = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController priceName = TextEditingController();
  TextEditingController discountPrice = TextEditingController();

  String priceUnitValue = 'Hourly';
  List selectedCategories = [];
  List selectedCategoryName = [];
  List selectedCities = [];
  List selectedSubCategories = [];
  List selectedSubCategoryName = [];
  bool isLoading = false;
  String categoryID = '';
  String subCategoryID = '';
  String categoryValue = '';
  String subCategoryValue = '';
  List<AddOn> addOnList = [];
  bool availablePanIndia = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getServiceData();
  }

  String galleryImage = '';
  String uploadedVideo = '';
  String uploadedThumbnail = '';
  List<Price> priceList = [];

  void getServiceData() async {
    priceList = [];
    addOnList = [];

    var collection = _firestore.collection('service');
    var docs = await collection.doc(widget.serviceID).get();

    name.text = '${docs.data()!['name'][0]['text']}';
    descTitle.text = '';
    galleryImage = '${docs.data()!['gallery'][0]['serverPath']}';
    for (var item in docs.data()!['cities']) {
      selectedCities.add(item);
    }
    print(selectedCities);
    for (var item in docs.data()!['category']) {
      selectedCategories.add(item);
      getCategory(docs['category'][0]);
    }
    for (var item in docs['subCategory']) {
      selectedSubCategories.add(item);
    }
    setState(() {});
    for (var item in docs.data()!['price']) {
      priceList.add(
        Price(
          discPrice: item['discPrice'],
          image: {
            'localFile': '${item['image']['localFile']}',
            'serverPath': '${item['image']['serverPath']}',
          },
          name: [
            Name(
              code: item['name'][0]['code'],
              text: item['name'][0]['text'],
            )
          ],
          price: item['price'],
          priceUnit: item['priceUnit'],
          selected: true,
          stock: 0,
        ),
      );
    }
    for (var item in docs['addon']) {
      addOnList.add(AddOn(
        name: item['addOnName'],
        interCityPrice: item['addOnPrice'][0]['price'],
        interStatePrice: item['addOnPrice'][1]['price'],
        outsideStatePrice: item['addOnPrice'][2]['price'],
      )
          // internationalPrice: item['addOnPrice'][3]['price']),
          );
    }
    if (selectedCities.contains(ServiceManager.panIndiaID)) {
      setState(() {
        availablePanIndia = true;
      });
    }
    setState(() {});
    setState(() {});
  }

  void getCategory(String catID) async {
    var collection = _firestore.collection('category');
    var docs = await collection.doc(catID).get();
    setState(() {
      categoryValue = '${docs['name']}';
      categoryID = catID;
    });
  }

  File? _video;
  void pickVideoFromGallery() async {
    var pickedImage = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _video = File(pickedImage.path);
        _generateThumbnail(pickedImage.path);
      });
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

  // List<SubCategory> subCategories = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Service'),
        // title: Text(widget.serviceID)
      ),
      body: StreamBuilder(
          stream: _firestore
              .collection('service')
              .doc(widget.serviceID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        decoration: containerDesign(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                'Category: $categoryValue',
                                style: kBoldStyle(),
                              ),
                            ),
                            if (categoryID != '')
                              StreamBuilder(
                                stream: _firestore
                                    .collection('category')
                                    .doc(categoryID)
                                    .collection('subCategory')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var docs = snapshot.data!.docs;
                                    // for(var item in docs){
                                    //   selectedSubCategories.add(SubCategory(
                                    //     id: item.reference.id,
                                    //     name: item['name'],
                                    //     image: item['image'],
                                    //     price: '',
                                    //     priceUnit: '',
                                    //     duration: '',
                                    //   ));
                                    // }
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 5.0, left: 0.0, bottom: 5),
                                            child: Text('Select Sub Category',
                                                style: kSmallText().copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Container(
                                            height: 240.0,
                                            decoration:
                                                roundedContainerDesign(context)
                                                    .copyWith(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                            ),
                                            child: Scrollbar(
                                              thumbVisibility: true,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 5.0),
                                                physics:
                                                    BouncingScrollPhysics(),
                                                itemCount: docs.length,
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 5.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            if (selectedSubCategories
                                                                .contains(docs[
                                                                        index]
                                                                    .reference
                                                                    .id)) {
                                                              setState(() {
                                                                selectedSubCategories
                                                                    .remove(docs[
                                                                            index]
                                                                        .reference
                                                                        .id);
                                                              });
                                                            } else {
                                                              setState(() {
                                                                selectedSubCategories
                                                                    .add(docs[
                                                                            index]
                                                                        .reference
                                                                        .id);
                                                              });
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                roundedContainerDesign(
                                                                        context)
                                                                    .copyWith(
                                                              color: k4Color
                                                                  .withOpacity(
                                                                      0.4),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4),
                                                                  child:
                                                                      Container(
                                                                    height: 45,
                                                                    width: 45,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      image:
                                                                          DecorationImage(
                                                                        image: NetworkImage(docs[index]
                                                                            [
                                                                            'image']),
                                                                        // image: NetworkImage(subCategories[index].image),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                    child: Text(
                                                                        docs[index]
                                                                            [
                                                                            'name'])),
                                                                // Expanded(child: Text(subCategories[index].name)),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10.0),
                                                                  // child: Icon(selectedSubCategories.contains(subCategories[index].id) ?
                                                                  child: Icon(selectedSubCategories.contains(docs[
                                                                              index]
                                                                          .reference
                                                                          .id)
                                                                      ? Icons
                                                                          .check_box_rounded
                                                                      : Icons
                                                                          .check_box_outline_blank),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // if(selectedSubCategories.contains(docs[index].reference.id))
                                                      // // if (selectedSubCategories.contains(subCategories[index].id))
                                                      // Column(
                                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                                      //   children: [
                                                      //     KTextField(
                                                      //       title: 'Price',
                                                      //       textInputType: TextInputType.number,
                                                      //       onChanged: (value){
                                                      //         setState(() {
                                                      //           subCategories[index].price = value;
                                                      //         });
                                                      //       },
                                                      //     ),
                                                      //     Padding(
                                                      //       padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                                      //       child: Column(
                                                      //         crossAxisAlignment: CrossAxisAlignment.start,
                                                      //         children: [
                                                      //           Text('Price Unit', style: kBoldStyle()),
                                                      //           Container(
                                                      //             height: 45,
                                                      //             width: MediaQuery.of(context).size.width,
                                                      //             decoration: dropTextFieldDesign(context),
                                                      //             child: DropdownButtonHideUnderline(
                                                      //               child: ButtonTheme(
                                                      //                 alignedDropdown: true,
                                                      //                 child: DropdownButton(
                                                      //                   borderRadius: BorderRadius.circular(10.0),
                                                      //                   value: subCategories[index].priceUnit != '' ? subCategories[index].priceUnit : null,
                                                      //                   // value: priceUnitValue != '' ? priceUnitValue : null,
                                                      //                   hint: Text('Price Unit'),
                                                      //                   items: priceUnitList
                                                      //                       .map<DropdownMenuItem<String>>((String value) {
                                                      //                     return DropdownMenuItem<String>(
                                                      //                       value: value,
                                                      //                       child: Text(value),
                                                      //                     );
                                                      //                   }).toList(),
                                                      //                   onChanged: (String? newValue) {
                                                      //                     setState(() {
                                                      //                       // priceUnitValue = newValue!;
                                                      //                       subCategories[index].priceUnit = newValue!;
                                                      //                     });
                                                      //                   },
                                                      //                 ),
                                                      //               ),
                                                      //             ),
                                                      //           ),
                                                      //         ],
                                                      //       ),
                                                      //     ),
                                                      //     // if(priceUnitValue != 'Hourly')
                                                      //     if(subCategories[index].priceUnit != 'Hourly')
                                                      //       KTextField(
                                                      //         title: 'Duration in min',
                                                      //         // controller: duration,
                                                      //         textInputType: TextInputType.number,
                                                      //         onChanged: (value){
                                                      //           setState(() {
                                                      //             subCategories[index].duration = value;
                                                      //           });
                                                      //         },
                                                      //       ),
                                                      //   ],
                                                      // ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return LoadingIcon();
                                },
                              ),
                            // KTextField(
                            //   title: 'Name',
                            //   controller: name,
                            // ),
                            // KTextField(
                            //   title: 'Tax',
                            //   controller: tax,
                            //   textInputType: TextInputType.number,
                            //   suffixButton: IconButton(
                            //     onPressed: (){},
                            //     icon: Icon(Icons.percent),
                            //   ),
                            // ),
                            // KTextField(title: 'Description Title', controller: descTitle,),
                            // KTextField(title: 'Description', controller: desc,),
                            // KTextField(
                            //   title: 'Duration in min',
                            //   controller: duration,
                            //   textInputType: TextInputType.number,
                            // ),
                            // StreamBuilder(
                            //     stream: _firestore.collection('category').orderBy('name').snapshots(),
                            //     builder: (context, snapshot) {
                            //       if(snapshot.hasData){
                            //         List categoryList = [];
                            //         var mainCategory = snapshot.data!.docs;
                            //         for(var category in mainCategory){
                            //           categoryList.add(category);
                            //         }
                            //         return Column(
                            //           crossAxisAlignment: CrossAxisAlignment.start,
                            //           children: [
                            //             Padding(
                            //               padding: EdgeInsets.only(top: 5.0, left: 10.0),
                            //               child: Text('Select Category',
                            //                   style: kSmallText().copyWith(
                            //                       fontWeight: FontWeight.bold)),
                            //             ),
                            //             Padding(
                            //               padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                            //               child: Container(
                            //                 height: 45,
                            //                 width: MediaQuery.of(context).size.width,
                            //                 decoration: dropTextFieldDesign(context),
                            //                 child: DropdownButtonHideUnderline(
                            //                   child: ButtonTheme(
                            //                     alignedDropdown: true,
                            //                     child: DropdownButton(
                            //                       borderRadius: BorderRadius.circular(10.0),
                            //                       value: categoryValue != '' ? categoryValue : null,
                            //                       hint: Text('Category', style: hintTextStyle(context)),
                            //                       items: categoryList
                            //                           .map<DropdownMenuItem>((value) {
                            //                         return DropdownMenuItem(
                            //                           value: value['name'],
                            //                           child: Text(value['name']),
                            //                           onTap: (){
                            //                             setState(() {
                            //                               categoryID = value.reference.id;
                            //                               selectedCategories = [value.reference.id];
                            //                             });
                            //                           },
                            //                         );
                            //                       }).toList(),
                            //                       onChanged: (newValue) {
                            //                         setState(() {
                            //                           categoryValue = newValue;
                            //                           subCategoryID = '';
                            //                           subCategoryValue = '';
                            //                         });
                            //                       },
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           ],
                            //         );
                            //       }
                            //       return Container();
                            //     }
                            // ),
                            // if(categoryID != '')
                            //   StreamBuilder(
                            //     stream: _firestore.collection('category').doc(categoryID).collection('subCategory').snapshots(),
                            //     builder: (context, snapshot){
                            //       if(snapshot.hasData) {
                            //         var docs = snapshot.data!.docs;
                            //         return Padding(
                            //           padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            //           child: Column(
                            //             crossAxisAlignment: CrossAxisAlignment.start,
                            //             children: [
                            //               Padding(
                            //                 padding: EdgeInsets.only(top: 5.0, left: 0.0, bottom: 5),
                            //                 child: Text('Select Sub Category',
                            //                     style: kSmallText().copyWith(
                            //                         fontWeight: FontWeight.bold)),
                            //               ),
                            //               Container(
                            //                 height: 240.0,
                            //                 decoration: roundedContainerDesign(context).copyWith(
                            //                   color: Theme.of(context).scaffoldBackgroundColor,
                            //                 ),
                            //                 child: ListView.builder(
                            //                   shrinkWrap: true,
                            //                   padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                            //                   physics: BouncingScrollPhysics(),
                            //                   itemCount: docs.length,
                            //                   itemBuilder: (context, index){
                            //                     return Padding(
                            //                       padding: const EdgeInsets.symmetric(vertical: 5.0),
                            //                       child: GestureDetector(
                            //                         onTap: (){
                            //                           if(selectedSubCategories.contains(docs[index].reference.id)){
                            //                             setState(() {
                            //                               selectedSubCategories.remove(docs[index].reference.id);
                            //                               selectedSubCategoryName.remove('${docs[index]['name']}');
                            //                             });
                            //                           } else {
                            //                             setState(() {
                            //                               selectedSubCategories.add(docs[index].reference.id);
                            //                               selectedSubCategoryName.remove('${docs[index]['name']}');
                            //                             });
                            //                           }
                            //                         },
                            //                         child: Container(
                            //                           decoration: BoxDecoration(
                            //                               color: k4Color.withOpacity(0.4),
                            //                               borderRadius: BorderRadius.circular(10.0)
                            //                           ),
                            //                           child: Row(
                            //                             children: [
                            //                               Padding(
                            //                                 padding: EdgeInsets.all(4),
                            //                                 child: Container(
                            //                                   height: 45,
                            //                                   width: 45,
                            //                                   decoration: BoxDecoration(
                            //                                     borderRadius: BorderRadius.circular(5),
                            //                                     image: DecorationImage(
                            //                                       image: NetworkImage('${docs[index]['image']}'),
                            //                                       fit: BoxFit.cover,
                            //                                     ),
                            //                                   ),
                            //                                 ),
                            //                               ),
                            //                               Expanded(child: Text('${docs[index]['name']}')),
                            //                               Padding(
                            //                                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            //                                 child: Icon(selectedSubCategories.contains(docs[index].reference.id) ?
                            //                                 Icons.check_box_rounded : Icons.check_box_outline_blank),
                            //                               ),
                            //                             ],
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     );
                            //                   },
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         );
                            //       }
                            //       return LoadingIcon();
                            //     },
                            //   ),
                            SizedBox(height: 5),
                            // Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                            //   child: Container(
                            //     padding: EdgeInsets.symmetric(vertical: 6.0),
                            //     decoration: roundedContainerDesign(context).copyWith(
                            //       color: k4Color.withOpacity(0.2),
                            //     ),
                            //     child: Column(
                            //       children: [
                            //         ListView.separated(
                            //           shrinkWrap: true,
                            //           padding: EdgeInsets.symmetric(horizontal: 10.0),
                            //           physics: NeverScrollableScrollPhysics(),
                            //           itemCount: priceList.length,
                            //           itemBuilder: (context, index){
                            //             return Column(
                            //               children: [
                            //                 kRowSpaceText('Price', '${priceList[index].price}'),
                            //                 // kRowSpaceText('Discount Price', '${priceList[index].discPrice}'),
                            //                 kRowSpaceText('Price Unit', priceList[index].priceUnit),
                            //                 kRowSpaceText('Price Name', priceList[index].name[0].text),
                            //                 Row(
                            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //                   children: [
                            //                     Container(
                            //                       height: 80,
                            //                       width: 80,
                            //                       decoration: BoxDecoration(
                            //                         borderRadius: BorderRadius.circular(10.0),
                            //                         image: DecorationImage(
                            //                           image: NetworkImage('${priceList[index].image['serverPath']}'),
                            //                           fit: BoxFit.cover,
                            //                         ),
                            //                       ),
                            //                     ),
                            //                     Column(
                            //                       children: [
                            //                         BorderButton(
                            //                           title: 'Edit',
                            //                           onClick: (){
                            //                             Navigator.push(context, MaterialPageRoute(builder: (context) => EditPrice(
                            //                               categoryID: categoryID,
                            //                               serviceID: widget.serviceID,
                            //                               priceIndex: index,
                            //                             ))).then((value) => {
                            //                               getServiceData(),
                            //                             });
                            //                           },
                            //                         ),
                            //                         SizedBox(height: 5.0),
                            //                         BorderButton(
                            //                           title: 'Delete',
                            //                           onClick: (){
                            //                             if(priceList.length > 1) {
                            //                               deletePopUp(context,
                            //                                 onClickYes: () {
                            //                                   Navigator.pop(context);
                            //                                   ServiceManager().deleteServicePriceAtIndex(
                            //                                     serviceID: widget.serviceID,
                            //                                     priceIndex: index,
                            //                                   ).then((value) => {
                            //                                   getServiceData(),
                            //                                 });
                            //                               });
                            //                             } else {
                            //                               toastMessage(message: 'One price is mandatory');
                            //                             }
                            //                           },
                            //                         ),
                            //                       ],
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ],
                            //             );
                            //           },
                            //           separatorBuilder: (context, int inx) {
                            //             return kDivider();
                            //           },
                            //         ),
                            //         Padding(
                            //           padding: const EdgeInsets.symmetric(vertical: 5.0),
                            //           child: KButton(
                            //             title: 'Add More Price',
                            //             onClick: (){
                            //               Navigator.push(context, MaterialPageRoute(builder: (context) => AddMorePrice(
                            //                 categoryID: categoryID,
                            //                 serviceID: widget.serviceID,
                            //                   ))).then((value) => {
                            //                   getServiceData(),
                            //               });
                            //             },
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            kSpace(),
                            Container(
                              decoration: containerDesign(context),
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, bottom: 5.0),
                                    child:
                                        Text('My Events', style: kBoldStyle()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration:
                                          roundedContainerDesign(context)
                                              .copyWith(
                                        color: k4Color.withOpacity(0.2),
                                      ),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        // itemCount: eventPriceList.length,
                                        itemCount: data!['eventPrice'].length,
                                        itemBuilder: (context, index) {
                                          var event = data['eventPrice'][index];
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(event['eventName']),
                                                    Text(
                                                        'Price Unit: ${event['priceUnit']}'),
                                                    Text(
                                                        'Inter City Price: ${kAmount(event['interCityPrice'])}'),
                                                    Text(
                                                        'Inter State Price: ${kAmount(event['interStatePrice'])}'),
                                                    Text(
                                                        'Outer State Price: ${kAmount(event['outerStatePrice'])}'),
                                                    Text(event['withSecurity'] !=
                                                            true
                                                        ? 'Not With Security'
                                                        : 'With Security'),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Column(
                                                    children: [
                                                      BorderButton(
                                                        title: 'Edit',
                                                        onClick: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      EditMyEvent(
                                                                        serviceID:
                                                                            widget.serviceID,
                                                                        scopeIndex:
                                                                            index,
                                                                      ))).then(
                                                              (value) => {
                                                                    getServiceData(),
                                                                  });
                                                        },
                                                      ),
                                                      SizedBox(height: 5.0),
                                                      BorderButton(
                                                        title: 'Delete',
                                                        onClick: () {
                                                          if (data['eventPrice']
                                                                  .length >
                                                              1) {
                                                            deletePopUp(context,
                                                                onClickYes: () {
                                                              ServiceManager()
                                                                  .deleteEventPriceAtIndex(
                                                                      serviceID:
                                                                          widget
                                                                              .serviceID,
                                                                      index:
                                                                          index);
                                                              Navigator.pop(
                                                                  context);
                                                              getServiceData();
                                                            });
                                                          } else {
                                                            toastMessage(
                                                                message:
                                                                    'One price is mandatory',
                                                                colors:
                                                                    kRedColor);
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return kDivider();
                                        },
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: KButton(
                                      title: 'Add More Events',
                                      onClick: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddMyEvents(
                                                      serviceID:
                                                          widget.serviceID,
                                                    ))).then((value) => {
                                              getServiceData(),
                                              setState(() {}),
                                            });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            kDivider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                kSpace(),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text('Add-On Prices',
                                      style: kBoldStyle()),
                                ),
                                addOnList.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        itemCount: addOnList.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 6, horizontal: 10),
                                              decoration:
                                                  roundedContainerDesign(
                                                          context)
                                                      .copyWith(
                                                color: k4Color.withOpacity(0.2),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                            addOnList[index]
                                                                .name,
                                                            style:
                                                                kBoldStyle()),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      EditAddOnService(
                                                                        serviceID:
                                                                            widget.serviceID,
                                                                        addOnIndex:
                                                                            index,
                                                                      ))).then(
                                                              (value) => {
                                                                    getServiceData(),
                                                                  });
                                                        },
                                                        icon: Icon(Icons
                                                            .edit_outlined),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          deletePopUp(context,
                                                              onClickYes: () {
                                                            ServiceManager()
                                                                .deleteAddOnAtIndex(
                                                              index: index,
                                                              serviceID: widget
                                                                  .serviceID,
                                                            );
                                                            setState(() {
                                                              addOnList
                                                                  .removeAt(
                                                                      index);
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                        icon: Icon(Icons
                                                            .delete_forever_outlined),
                                                      ),
                                                    ],
                                                  ),
                                                  kRowSpaceText(
                                                      'Inter City Price',
                                                      '₹${addOnList[index].interCityPrice}'),
                                                  kRowSpaceText(
                                                      'Inter State Price',
                                                      '₹${addOnList[index].interStatePrice}'),
                                                  kRowSpaceText(
                                                      'Outside State Price',
                                                      '₹${addOnList[index].outsideStatePrice}'),
                                                  // kRowSpaceText('International Price', '₹${addOnList[index].internationalPrice}'),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text('No Add-On Price'),
                                      ),
                              ],
                            ),
                            if (addOnList.length < 2)
                              Center(
                                child: KButton(
                                  title: 'Add Add-On Price',
                                  onClick: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddAddOnPrice(
                                                  serviceID: widget.serviceID,
                                                ))).then((value) => {
                                          getServiceData(),
                                        });
                                  },
                                ),
                              ),
                            kSpace(),
                          ],
                        ),
                      ),
                      kSpace(),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                        child: Text('Available in cities', style: kBoldStyle()),
                      ),
                      ListTile(
                        title: Text('Pan India'),
                        trailing: Icon(availablePanIndia != true
                            ? Icons.check_box_outline_blank
                            : Icons.check_box),
                        onTap: () {
                          if (availablePanIndia != true) {
                            setState(() {
                              availablePanIndia = !availablePanIndia;
                              selectedCities = [ServiceManager.panIndiaID];
                            });
                          } else if (selectedCities
                              .contains(ServiceManager.panIndiaID)) {
                            setState(() {
                              availablePanIndia = !availablePanIndia;
                              selectedCities.remove(ServiceManager.panIndiaID);
                            });
                          }
                        },
                      ),
                      if (availablePanIndia != true)
                        StreamBuilder(
                          stream: _firestore
                              .collection('city')
                              .orderBy('name')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var docs = snapshot.data!.docs;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Wrap(
                                  children: docs.map((city) {
                                    String referenceId = city.reference.id;
                                    bool isValid = referenceId !=
                                        ServiceManager.panIndiaID;

                                    return isValid
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            child: GestureDetector(
                                              onTap: () {
                                                if (selectedCities.contains(
                                                    city.reference.id)) {
                                                  setState(() {
                                                    selectedCities.remove(
                                                        city.reference.id);
                                                  });
                                                } else {
                                                  setState(() {
                                                    selectedCities
                                                        .add(city.reference.id);
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                                decoration: BoxDecoration(
                                                  color:
                                                      selectedCities.contains(
                                                              city.reference.id)
                                                          ? kMainColor
                                                          : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Text(
                                                  '${city['name']}',
                                                  style: TextStyle(
                                                    color: selectedCities
                                                            .contains(city
                                                                .reference.id)
                                                        ? kBTextColor
                                                        : kDarkColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink();
                                  }).toList(),
                                ),
                              );
                            }
                            return LoadingIcon();
                          },
                        ),
                      kSpace(),
                      Center(
                        child: isLoading != true
                            ? KButton(
                                title: 'Save',
                                onClick: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (selectedSubCategories.isNotEmpty) {
                                      if (selectedCities.isNotEmpty) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        editService(context);
                                      } else {
                                        toastMessage(
                                            message: 'Select Cities',
                                            colors: kRedColor);
                                      }
                                    } else {
                                      toastMessage(
                                          message: 'Select Sub Category',
                                          colors: kRedColor);
                                    }
                                  } else {
                                    toastMessage(
                                        message: 'Fill the required fields',
                                        colors: kRedColor);
                                  }

                                  // setState(() {
                                  //   isLoading = true;
                                  // });
                                  // editService(context);
                                },
                              )
                            : LoadingButton(),
                      ),
                      kSpace(),
                    ],
                  ),
                ),
              );
            }
            return LoadingIcon();
          }),
    );
  }

  void editService(context) async {
    if (_video != null) {
      String videoPath =
          await ServiceManager().uploadVideo(_video!.path, 'service');
      String thumbnailPath = await ServiceManager().uploadThumbnail(_thumbnail);
      setState(() {
        uploadedVideo = videoPath;
        uploadedThumbnail = thumbnailPath;
      });
    }

    // List selectedEventPrice = [];
    // for(var item in eventPriceList){
    //   selectedEventPrice.add({
    //     'eventID': item.id,
    //     'eventName': item.name,
    //     'interCityPrice': item.withSecurity != true ? item.interCityPrice : item.interCityPrice + 1000,
    //     'interStatePrice': item.withSecurity != true ? item.interStatePrice : item.interStatePrice + 1000,
    //     'outerStatePrice': item.withSecurity != true ? item.outerStatePrice : item.outerStatePrice + 1000,
    //     'priceUnit': item.priceUnit,
    //     'withSecurity': item.withSecurity,
    //   });
    // }

    List<String> subCat = [];
    for (var item in selectedSubCategories) {
      subCat.add('$item');
    }

    try {
      _firestore.collection('service').doc(widget.serviceID).update({
        "cities": selectedCities,
        // 'eventPrice' : selectedEventPrice,
        "group": [],
        'id': '',
        "name": [
          {
            'code': '',
            'text': ServiceManager.userName,
          }
        ],
        // "priceProduct": 0,
        "subCategory": subCat,
        "thisIsArticle": false,
        "timeModify": DateTime.now(),
        "unavailable": false,
        "visible": true,
      });
      Navigator.pop(context);
      toastMessage(message: 'Service Edited');
    } catch (e) {
      print(e);
    }
  }
}
