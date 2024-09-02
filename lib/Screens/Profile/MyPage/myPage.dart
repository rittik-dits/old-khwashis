import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/DialogueBox/deletePopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/kDatabase.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/galleryViewer.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/videoPlayerScreen.dart';
import 'package:khwahish_provider/Screens/Profile/MyPage/addTestimonial.dart';
import 'package:khwahish_provider/Screens/Profile/MyPage/editTestimonial.dart';
import 'package:khwahish_provider/Screens/setLocation.dart';
import 'package:khwahish_provider/Services/location.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController city = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController website = TextEditingController();
  TextEditingController facebook = TextEditingController();
  TextEditingController instagram = TextEditingController();
  TextEditingController telegram = TextEditingController();
  TextEditingController twitter = TextEditingController();
  TextEditingController description = TextEditingController();

  String selectTime = '';
  TimeOfDay selectedTime = TimeOfDay.now();
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime, builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      });
    if (picked != null && picked != selectedTime ) {
      setState(() {
        selectedTime = picked;
        selectTime = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  bool isLoading = false;
  String categoryID = '';
  String stateValue = '';
  String cityID = '';
  String cityName = '';

  @override
  void initState() {
    super.initState();
    mobile.text = ServiceManager.userMobile;
    getUserData();
  }

  List<WorkTime> workTiming = [];
  List testimonialList = [];
  void getUserData() async {
    setState(() {
      workTiming = [];
      testimonialList = [];
    });
    var collection = _firestore.collection('provider');
    var docs = await collection.doc(ServiceManager.userID).get();
    if(docs.exists){
      // setState(() {
        // city.text = '${docs.data()!['address']}';
        cityName = '${docs.data()!['address']}';
        address.text = '${docs.data()!['artistAddress']}';
        stateValue = '${docs.data()!['selectedState']}';
        website.text = '${docs.data()!['www']}';
        facebook.text = '${docs.data()!['facebook']}';
        instagram.text = '${docs.data()!['instagram']}';
        telegram.text = '${docs.data()!['telegram']}';
        twitter.text = '${docs.data()!['twitter']}';
        description.text = '${docs.data()!['desc'][0]['text']}';
        if(docs['category'].isNotEmpty){
          categoryID = docs['category'][0];
        }
      // });
      for(var time in docs['workTime']){
        setState(() {
          workTiming.add(WorkTime(fromTime: time['openTime'], toTime: time['closeTime']));
        });
      }
      for(var item in docs['testimonial']){
        testimonialList.add(item);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
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
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              decoration: containerDesign(context),
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
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, left: 10.0),
                    child: Text('Base Location',
                        style: k12BoldStyle()),
                  ),
                  StreamBuilder(
                      stream: _firestore.collection('states').orderBy('name').snapshots(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          var data = snapshot.data!.docs;
                          List stateList = [];
                          List stateCityList = [];
                          for(var item in data){
                            stateList.add(item);

                            if(item.reference.id == stateValue){
                              stateCityList = item['cities'];
                            }
                          }
                          return Column(
                            children: [
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
                                          setState(() {
                                            stateValue = newValue;
                                            cityID = '';
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if(stateValue != '')
                                StreamBuilder(
                                    stream: _firestore.collection('city').orderBy('name').snapshots(),
                                    builder: (context, snapshot2) {
                                      if(snapshot2.hasData){
                                        var data2 = snapshot2.data!.docs;
                                        List cityList = [];
                                        for(var item in data2){
                                          if(stateCityList.contains(item.reference.id)){
                                            cityList.add(item);
                                          }
                                        }
                                        if(cityName != ''){
                                          for(var item in cityList){
                                            if(item['name'] == cityName){
                                              cityID = item.reference.id;
                                            }
                                          }
                                        }
                                        return cityList.isNotEmpty ? Padding(
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
                                                  value: cityID != '' ? cityID : null,
                                                  hint: Text('Select City', style: hintTextStyle(context)),
                                                  // items: occasion
                                                  items: cityList
                                                      .map<DropdownMenuItem>((value) {
                                                    return DropdownMenuItem(
                                                      value: value.reference.id,
                                                      child: Text('${value['name']}'),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    // _formKey.currentState!.validate();

                                                    String? selectedCityName;
                                                    for (var city in cityList) {
                                                      if (city.reference.id == newValue) {
                                                        selectedCityName = city['name'];
                                                        break;
                                                      }
                                                    }

                                                    // print('Selected City ID: $newValue');
                                                    // print('Selected City Name: $selectedCityName');

                                                    setState(() {
                                                      cityID = newValue;
                                                      cityName = '$selectedCityName';
                                                    });
                                                    // getServiceData();
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ) : Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          child: Text('No Cities available select other state',
                                            style: TextStyle(color: kRedColor, fontSize: 15, fontWeight: FontWeight.w600),
                                          ),
                                        );
                                      }
                                      return SizedBox.shrink();
                                    }
                                ),
                            ],
                          );
                        }
                        return SizedBox.shrink();
                      }
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        KTextField(title: 'Address', controller: address,),
                      ],
                    ),
                  ),
                  kDivider(),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Working Time', style: kHeaderStyle()),
                        TextButton(
                          onPressed: (){
                            setState(() {
                              workTiming.add(WorkTime(fromTime: '0:00 am', toTime: '0:00 pm'));
                            });
                          },
                          child: Text('Add Timing'),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: workTiming.length,
                    itemBuilder: (context, index){
                      return Row(
                        children: [
                          MaterialButton(
                            onPressed: (){
                              _selectTime(context).then((value) => {
                                workTiming[index].fromTime = selectTime,
                              });
                            },
                            color: kButtonColor,
                            textColor: kBTextColor,
                            shape: materialButtonDesign(),
                            child: Column(
                              children: [
                                Text('From'),
                                Text(workTiming[index].fromTime),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.0),
                          MaterialButton(
                            onPressed: (){
                              _selectTime(context).then((value) => {
                                workTiming[index].toTime = selectTime,
                              });
                            },
                            color: kButtonColor,
                            textColor: kBTextColor,
                            shape: materialButtonDesign(),
                            child: Column(
                              children: [
                                Text('To'),
                                Text(workTiming[index].toTime),
                              ],
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: (){
                              setState(() {
                                workTiming.removeAt(index);
                              });
                            },
                            icon: Icon(Icons.highlight_remove),
                          ),
                        ],
                      );
                    },
                  ),
                  kDivider(),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 10),
                    child: Text('Social Network', style: kHeaderStyle()),
                  ),
                  KTextField(
                    title: 'Website',
                    controller: website,
                    suffixButton: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset('images/social/website.png', height: 20),
                    ),
                  ),
                  KTextField(
                    title: 'Facebook',
                    controller: facebook,
                    suffixButton: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset('images/social/facebook.png', height: 20),
                    ),
                  ),
                  KTextField(
                    title: 'Instagram',
                    controller: instagram,
                    suffixButton: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset('images/social/instagram.png', height: 20),
                    ),
                  ),
                  KTextField(
                    title: 'Telegram',
                    controller: telegram,
                    suffixButton: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset('images/social/Telegram_logo.png', height: 20),
                    ),
                  ),
                  KTextField(
                    title: 'Twitter',
                    controller: twitter,
                    suffixButton: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset('images/social/twitter_logo.png', height: 20),
                    ),
                  ),
                  SizedBox(height: 5),
                  kDivider(),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Testimonial', style: kHeaderStyle(),),
                  ),
                  testimonialList.isNotEmpty ?
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    // scrollDirection: Axis.horizontal,
                    itemCount: testimonialList.length,
                    itemBuilder: (context, index){
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${testimonialList[index]['description']}'),
                                SizedBox(height: 5),
                                if(testimonialList[index]['imagePath'] != '' || testimonialList[index]['videoUrl'] != '')
                                GestureDetector(
                                  onTap: (){
                                    if(testimonialList[index]['imagePath'] != ''){
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => ImageViewer(
                                              imageURL: testimonialList[index]['imagePath'])));
                                    } else {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => VideoPlayerScreen(
                                              videoUrl: testimonialList[index]['videoUrl'])));
                                    }
                                  },
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: testimonialList[index]['imagePath'] != '' ? DecorationImage(
                                        image: NetworkImage(testimonialList[index]['imagePath']),
                                        fit: BoxFit.cover,
                                      ) : DecorationImage(
                                        image: NetworkImage(testimonialList[index]['thumbnail']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              BorderButton(
                                title: 'Edit',
                                onClick: (){
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => EditTestimonial(
                                          index: index))).then((value) => {
                                            getUserData(),
                                  });
                                },
                              ),
                              SizedBox(height: 5.0),
                              BorderButton(
                                title: 'Delete',
                                onClick: (){
                                  deletePopUp(context, onClickYes: (){
                                    ServiceManager().deleteTestimonialAtIndex(index: index).then((value) => {
                                      Navigator.pop(context),
                                      getUserData(),
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 10);
                    },
                  ) : Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('No Testimonial Added', style: kHeaderStyle(),),
                  ),
                  Center(
                    child: KButton(
                      title: 'Add Testimonial',
                      onClick: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => AddTestimonial())).then((value) => {
                              getUserData(),
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            kBottomSpace(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoading != true ? KButton(
        title: 'Save',
        onClick: (){
          if(_formKey.currentState!.validate()){
            if(stateValue != ''){
              setState(() {
                isLoading = true;
              });
              updateData();
            } else {
              toastMessage(message: 'Select State', colors: kRedColor);
            }
          }
        },
      ) : LoadingButton(),
    );
  }

  void updateData() async {

    List workTime = [];
    for (var item in workTiming) {
      workTime.add({
        'closeTime': item.toTime,
        'openTime': item.fromTime,
      });
    }

    try {
      _firestore.collection('provider').doc(ServiceManager.userID).update({
        // 'address': city.text,
        'address': cityName,
        'artistAddress': address.text,
        'category': categoryID != '' ? [categoryID] : [],
        'selectedState': stateValue,
        'workTime': workTime,
        'www': website.text,
        'facebook': facebook.text,
        'instagram': instagram.text,
        'telegram': telegram.text,
        'twitter': twitter.text,
      });
      Navigator.pop(context);
      toastMessage(message: 'Updated');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toastMessage(message: 'Something went wrong');
    }

  }
}
