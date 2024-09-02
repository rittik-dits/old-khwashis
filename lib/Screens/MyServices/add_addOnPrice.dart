import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:khwahish_provider/model/addOn.dart';

class AddAddOnPrice extends StatefulWidget {

  String serviceID;
  AddAddOnPrice({super.key, required this.serviceID});

  @override
  State<AddAddOnPrice> createState() => _AddAddOnPriceState();
}

class _AddAddOnPriceState extends State<AddAddOnPrice> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List selectedAddOn = [];
  bool isLoading = false;

  List<AddOn> addOnList = [
    // AddOn(name: 'Hands', interCityPrice: 0, interStatePrice: 0,
    //     outsideStatePrice: 0),
    // AddOn(name: 'Sound and transport', interCityPrice: 0, interStatePrice: 0,
    //     outsideStatePrice: 0,
    // ),
  ];

  @override
  void initState() {
    super.initState();
    getServiceData();
  }

  // List<AddOn> addOnList = [];
  void getServiceData() async {
    var collection = _firestore.collection('service');
    var docs = await collection.doc(widget.serviceID).get();
    if(docs.exists){
      for(var item in docs['addon']){
        if(item['addOnName'] != 'Hands'){
          addOnList.add(AddOn(
            name: 'Hands',
            interCityPrice: 0,
            interStatePrice: 0,
            outsideStatePrice: 0,
          ));
        }
        if(item['addOnName'] != 'Sound and transport'){
          addOnList.add(AddOn(
            name: 'Sound and transport',
            interCityPrice: 0,
            interStatePrice: 0,
            outsideStatePrice: 0,
          ));
        }
      }
      if(docs['addon'].isEmpty) {
        addOnList.add(AddOn(name: 'Hands', interCityPrice: 0, interStatePrice: 0,
            outsideStatePrice: 0));
        addOnList.add(AddOn(name: 'Sound and transport', interCityPrice: 0, interStatePrice: 0,
            outsideStatePrice: 0));
      }
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Additional Price'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                decoration: containerDesign(context),
                child: ListView.separated(
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
                            child: Container(
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
                                onChanged: (value){
                                  setState(() {
                                    addOnList[index].interCityPrice = int.parse(value);
                                  });
                                },
                              ),
                              KTextField(
                                title: 'InterState Price',
                                textInputType: TextInputType.number,
                                onChanged: (value){
                                  setState(() {
                                    addOnList[index].interStatePrice = int.parse(value);
                                  });
                                },
                              ),
                              KTextField(
                                title: 'Outside State Price',
                                textInputType: TextInputType.number,
                                onChanged: (value){
                                  setState(() {
                                    addOnList[index].outsideStatePrice = int.parse(value);
                                  });
                                },
                              ),
                              // KTextField(
                              //   title: 'International Price',
                              //   textInputType: TextInputType.number,
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
              ),
              kBottomSpace(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoading != true ? KButton(
        title: 'Save',
        onClick: (){
          if(_formKey.currentState!.validate()){
            setState(() {
              isLoading = true;
            });
            addExtraPrice();
          }
        },
      ) : LoadingButton(),
    );
  }

  void addExtraPrice(){

    List selectedAddOnList = [];
    addOnList.forEach((item) {
      if(item.interCityPrice != 0){
        selectedAddOnList.add({
          'addOnName': item.name,
          'addOnPrice': [
            {
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
    });

    _firestore.collection('service').doc(widget.serviceID).update({
      'addon': FieldValue.arrayUnion(selectedAddOnList),
    }).then((value) => {
      Navigator.pop(context),
      toastMessage(message: 'Price Added'),
    });
  }
}
