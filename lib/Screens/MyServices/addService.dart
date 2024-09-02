import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/kDatabase.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:khwahish_provider/model/eventPrice.dart';
import 'package:khwahish_provider/model/subCategory.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {

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

  List<String> priceUnitList = [
    'Hourly', 'Fixed'
  ];
  String priceUnitValue = 'Hourly';
  String categoryID = '';
  String subCategoryID = '';
  String categoryValue = '';
  String subCategoryValue = '';
  List selectedCategories = [];
  List selectedCategoryName = [];
  List selectedSubCategories = [];
  List selectedSubCategoryName = [];
  List selectedAddOn = [];
  List selectedCities = [];
  List<EventPrice> eventPriceList = [];
  bool isLoading = false;
  bool availablePanIndia = false;

  List<SubCategory> subCategories = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Service'),
        // actions: [
        //   TextButton(onPressed: (){
        //     ServiceManager().updateAll();
        //   }, child: Text('update')),
        // ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                // decoration: containerDesign(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  selectedCategories = [value.reference.id];
                                                });
                                              },
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              categoryValue = newValue;
                                              subCategoryID = '';
                                              subCategoryValue = '';
                                              selectedSubCategories = [];
                                              selectedSubCategoryName = [];
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
                    if(categoryID != '')
                      StreamBuilder(
                        stream: _firestore.collection('category').doc(categoryID).collection('subCategory').snapshots(),
                        builder: (context, snapshot){
                          if(snapshot.hasData) {
                            var docs = snapshot.data!.docs;
                            for(var item in docs){
                              // subCategories.add(SubCategory(
                              //     id: item.reference.id,
                              //     name: item['name'],
                              //     image: item['image'],
                              //     price: '',
                              //     priceUnit: '',
                              //     duration: '',
                              // ));
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 5.0, left: 0.0, bottom: 5),
                                    child: Text('Select Sub Category',
                                        style: kSmallText().copyWith(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    height: 240.0,
                                    decoration: roundedContainerDesign(context).copyWith(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                    ),
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                        physics: BouncingScrollPhysics(),
                                        // physics: NeverScrollableScrollPhysics(),
                                        itemCount: docs.length,
                                        itemBuilder: (context, index){
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                child: GestureDetector(
                                                  onTap: (){
                                                    if (selectedSubCategories.contains(docs[index].reference.id)) {
                                                      setState(() {
                                                        selectedSubCategories.remove(docs[index].reference.id);
                                                      });
                                                    } else {
                                                      setState(() {
                                                        selectedSubCategories.add(docs[index].reference.id);
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: k4Color.withOpacity(0.4),
                                                        borderRadius: BorderRadius.circular(10.0)
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.all(4),
                                                          child: Container(
                                                            height: 45,
                                                            width: 45,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(5),
                                                              image: DecorationImage(
                                                                image: NetworkImage(docs[index]['image']),
                                                                // image: NetworkImage(subCategories[index].image),
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(child: Text(docs[index]['name'])),
                                                        // Expanded(child: Text(subCategories[index].name)),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                          // child: Icon(selectedSubCategories.contains(subCategories[index].id) ?
                                                          child: Icon(selectedSubCategories.contains(docs[index].reference.id) ?
                                                          Icons.check_box_rounded : Icons.check_box_outline_blank),
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
                    kDivider(),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                    child: Text('Type Of Event', style: kBoldStyle()),
                  ),
                  StreamBuilder(
                    stream: _firestore.collection('events').orderBy('name').snapshots(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        var data = snapshot.data!.docs;
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          itemCount: data.length,
                          itemBuilder: (context, index) {

                            int eventPriceIndex = eventPriceList.indexWhere((element) => element.id == data[index].reference.id);

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: (){
                                          if(eventPriceList.any((element) => element.id == data[index].reference.id)){
                                            eventPriceList.removeWhere((element) => element.id == data[index].reference.id);
                                          } else {
                                            eventPriceList.add(EventPrice(
                                              id: data[index].reference.id,
                                              name: '${data[index]['name']}',
                                              interCityPrice: 0,
                                              interStatePrice: 0,
                                              outerStatePrice: 0,
                                              priceUnit: 'Fixed',
                                              withSecurity: false,
                                            ));
                                          }
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Icon(eventPriceList.any((element) => element.id == data[index].reference.id) ?
                                            Icons.check_box : Icons.check_box_outline_blank),
                                            Expanded(child: Text('${data[index]['name']}')),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if(eventPriceList.any((element) => element.id == data[index].reference.id))
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: (){
                                          EventPrice eventPrice = eventPriceList.firstWhere(
                                                (element) => element.id == data[index].reference.id,
                                          );
                                          eventPrice.withSecurity = !eventPrice.withSecurity;
                                          setState(() {});
                                        },
                                        child: Row(
                                          children: [
                                            Icon(eventPriceList.any((element) => element.id == data[index].reference.id && element.withSecurity)
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank),
                                            Text('With Security'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if(eventPriceList.any((element) => element.id == data[index].reference.id))
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if(eventPriceList.any((element) => element.id == data[index].reference.id && element.withSecurity))
                                    Text('${kAmount(ServiceManager.securityCharge)} will be added for security to your amount',
                                      style: k10Text().copyWith(color: Colors.blue),
                                    ),
                                    SizedBox(height: 5),
                                    KTextField(
                                      title: 'Inter City Price',
                                      textInputType: TextInputType.number,
                                      prefixText: ' ₹ ',
                                      onChanged: (value){
                                        EventPrice eventPrice = eventPriceList.firstWhere(
                                              (element) => element.id == data[index].reference.id);
                                        eventPrice.interCityPrice = num.parse(value).toInt();
                                        setState(() {});
                                      },
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: KTextField(
                                            title: 'Inter State Price',
                                            textInputType: TextInputType.number,
                                            prefixText: ' ₹ ',
                                            onChanged: (value){
                                              EventPrice eventPrice = eventPriceList.firstWhere(
                                                      (element) => element.id == data[index].reference.id);
                                              eventPrice.interStatePrice = num.parse(value).toInt();
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: KTextField(
                                            title: 'Outer State Price',
                                            textInputType: TextInputType.number,
                                            prefixText: ' ₹ ',
                                            onChanged: (value){
                                              EventPrice eventPrice = eventPriceList.firstWhere(
                                                      (element) => element.id == data[index].reference.id);
                                              eventPrice.outerStatePrice = num.parse(value).toInt();
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Price Unit', style: k12BoldStyle()),
                                          Container(
                                            height: 45,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: dropTextFieldDesign(context),
                                            child: DropdownButtonHideUnderline(
                                              child: ButtonTheme(
                                                alignedDropdown: true,
                                                child: DropdownButton(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  value: eventPriceList[eventPriceIndex].priceUnit != '' ? eventPriceList[eventPriceIndex].priceUnit : null,
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
                                                      eventPriceList[eventPriceIndex].priceUnit = newValue!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 10);
                          },
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    }
                  ),
                ],
              ),
              kDivider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Text('Add Add-On Service', style: kBoldStyle()),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: addOnList.length,
                    itemBuilder: (context, index){
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: GestureDetector(
                              onTap: (){
                                if (selectedAddOn.contains(addOnList[index].name)) {
                                  setState(() {
                                    selectedAddOn.remove(addOnList[index].name);
                                  });
                                } else {
                                  setState(() {
                                    selectedAddOn.add(addOnList[index].name);
                                  });
                                }
                              },
                              child: SizedBox(
                                height: 35,
                                child: Row(
                                  children: [
                                    Expanded(child: Text(addOnList[index].name, style: k12BoldStyle())),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: Icon(selectedAddOn.contains(addOnList[index].name) ?
                                      Icons.check_box_rounded : Icons.check_box_outline_blank),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if(selectedAddOn.contains(addOnList[index].name))
                            Column(
                              children: [
                                KTextField(
                                  title: 'Inter City Price',
                                  textInputType: TextInputType.number,
                                  prefixText: ' ₹ ',
                                  onChanged: (value){
                                    setState(() {
                                      addOnList[index].interCityPrice = int.parse(value);
                                    });
                                  },
                                ),
                                KTextField(
                                  title: 'InterState Price',
                                  textInputType: TextInputType.number,
                                  prefixText: ' ₹ ',
                                  onChanged: (value){
                                    setState(() {
                                      addOnList[index].interStatePrice = int.parse(value);
                                    });
                                  },
                                ),
                                KTextField(
                                  title: 'Outside State Price',
                                  textInputType: TextInputType.number,
                                  prefixText: ' ₹ ',
                                  onChanged: (value){
                                    setState(() {
                                      addOnList[index].outsideStatePrice = int.parse(value);
                                    });
                                  },
                                ),
                                // KTextField(
                                //   title: 'International Price',
                                //   textInputType: TextInputType.number,
                                //   prefixText: ' ₹ ',
                                //   onChanged: (value){
                                //     setState(() {
                                //       addOnList[index].internationalPrice = int.parse(value);
                                //     });
                                //   },
                                // ),
                              ],
                            ),
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(thickness: 1),
                      );
                    },
                  ),
                ],
              ),
              kDivider(),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10),
                child: Text('Available in cities', style: kHeaderStyle()),
              ),
              ListTile(
                title: Text('Pan India'),
                trailing: Icon(availablePanIndia != true ? Icons.check_box_outline_blank : Icons.check_box),
                onTap: (){
                  if(availablePanIndia != true){
                    setState(() {
                      availablePanIndia = !availablePanIndia;
                      selectedCities = [ServiceManager.panIndiaID];
                    });
                  } else if(selectedCities.contains(ServiceManager.panIndiaID)) {
                    setState(() {
                      availablePanIndia = !availablePanIndia;
                      selectedCities.remove(ServiceManager.panIndiaID);
                    });
                  }
                },
              ),
              if(availablePanIndia != true)
              StreamBuilder(
                stream: _firestore.collection('city').orderBy('name').snapshots(),
                builder: (context, snapshot){
                  if(snapshot.hasData) {
                    var docs = snapshot.data!.docs;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Wrap(
                        children: docs.map((city) {
                          String referenceId = city.reference.id;
                          bool isValid = referenceId != ServiceManager.panIndiaID;

                          return isValid ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            child: GestureDetector(
                              onTap: (){
                                if(selectedCities.contains(city.reference.id)){
                                  setState(() {
                                    selectedCities.remove(city.reference.id);
                                  });
                                } else {
                                  setState(() {
                                    selectedCities.add(city.reference.id);
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: selectedCities.contains(city.reference.id) ? kMainColor :
                                  Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text('${city['name']}',
                                  style: TextStyle(
                                    color: selectedCities.contains(city.reference.id) ? kBTextColor :
                                    kDarkColor,
                                  ),
                                ),
                              ),
                            ),
                          ) : SizedBox.shrink();
                        }).toList(),
                      ),
                    );
                  }
                  return LoadingIcon();
                },
              ),

              kSpace(),
              Center(
                child: Column(
                  children: [
                    if(isLoading != true)
                      KButton(
                        title: 'Save',
                        onClick: () async {
                        
                          if(_formKey.currentState!.validate()){
                            if(selectedCategories.isNotEmpty){
                              if(selectedSubCategories.isNotEmpty){
                                if(selectedCities.isNotEmpty){
                                  if(eventPriceList.isNotEmpty){
                                    setState(() {
                                      isLoading = true;
                                    });
                                    addService();
                                  } else {
                                    toastMessage(message: 'Select Events', colors: kRedColor);
                                  }
                                } else {
                                  toastMessage(message: 'Select Cities', colors: kRedColor);
                                }
                              } else {
                                toastMessage(message: 'Select Sub Category', colors: kRedColor);
                              }
                            } else {
                              toastMessage(message: 'Select Category', colors: kRedColor);
                            }
                          } else {
                            toastMessage(message: 'Fill the required fields', colors: kRedColor);
                          }
                        },
                      ),
                    if(isLoading != false)
                      LoadingButton(),
                  ],
                ),
              ),
              kSpace(),
            ],
          ),
        ),
      ),
    );
  }

  void addService() async {

    List selectedEventPrice = [];
    for(var item in eventPriceList){
      selectedEventPrice.add({
        'eventID': item.id,
        'eventName': item.name,
        'interCityPrice': item.withSecurity != true ? item.interCityPrice : item.interCityPrice + 1000,
        'interStatePrice': item.withSecurity != true ? item.interStatePrice : item.interStatePrice + 1000,
        'outerStatePrice': item.withSecurity != true ? item.outerStatePrice : item.outerStatePrice + 1000,
        'priceUnit': item.priceUnit,
        'withSecurity': item.withSecurity,
      });
    }

    List selectedAddOnList = [];
    for (var item in addOnList) {
      if(item.interCityPrice > 0 && item.interStatePrice > 0){
        selectedAddOnList.add({
          'addOnName': item.name,
          'addOnPrice': [{
              'priceName': 'Inter City',
              'price': item.interCityPrice,
            },
            {
              'priceName': 'Inter State',
              'price': item.interStatePrice,
            },
            {
              'priceName': 'Outer State',
              'price': item.outsideStatePrice,
            },
          ]
        });
      }
    }

    List priceList = [];
    for (var item in subCategories) {
      if(item.price != ''){
        priceList.add({
          'discPrice': 0,
          'duration': item.duration != '' ? int.parse(item.duration) : 0,
          'image': {
            'localFile': '',
            'serverPath': item.image,
          },
          "name": [{
            'code': '',
            'text': item.name,
          }],
          'price': int.parse(item.price),
          'priceUnit': item.priceUnit,
          'selected': true,
          'stock': 0,
        });
      }
    }

    try{
      _firestore.collection('service').add({
        "addon" : selectedAddOnList,
        "category" : selectedCategories,
        "cities": selectedCities,
        "countProduct" : 1,
        "delete" : false,
        // "desc" : [desc.text],
        "desc" : [],
        // "descTitle" : descTitle.text,
        "descTitle" : [],
        "discPriceProduct" : 0,
        // "duration" : int.parse(duration.text),
        "duration" : 0,
        "eventPrice" : selectedEventPrice,
        "favoritesCount" : 0,
        "gallery" : [
          {
            'localFile': '',
            // 'serverPath': galleryImage,
            'serverPath': ServiceManager.profileURL,
          }
        ],
        "group": [],
        'id': '',
        "name": [
          {
            'code': '',
            // 'text': name.text,
            'text': ServiceManager.userName,
          }
        ],
        "price": priceList,
        "priceProduct": 0,
        "providers": [ServiceManager.userID],
        "avgRating": 0,
        "serviceGallery": [],
        "stock": 0,
        "subCategory": selectedSubCategories,
        "taxAdmin": 0,
        "thisIsArticle": false,
        "timeModify": DateTime.now(),
        "unavailable": false,
        "unit": priceUnitValue,
        "visible": true,
      }).then((value) => {
        Navigator.pop(context),
        toastMessage(message: 'Services Added'),
      });
    } catch(e) {
      setState(() {
        isLoading = false;
      });
      toastMessage(message: 'Something went wrong', colors: kRedColor);
    }
  }
}

