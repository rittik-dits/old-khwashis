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

class AddMyEvents extends StatefulWidget {

  String serviceID;
  AddMyEvents({super.key, required this.serviceID});

  @override
  State<AddMyEvents> createState() => _AddMyEventsState();
}

class _AddMyEventsState extends State<AddMyEvents> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String scopeValue = '';
  String priceUnitValue = '';
  bool isLoading = false;
  List<EventPrice> eventPriceList = [];

  @override
  void initState() {
    super.initState();
    getServiceData();
  }

  List selectedScope = [];
  void getServiceData() async {
    var collection = _firestore.collection('service');
    var docs = await collection.doc(widget.serviceID).get();
    if(docs.exists){
      for(var item in docs['eventPrice']){
        selectedScope.add(item['eventID']);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Events'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
              child: Text('Event Listing', style: kBoldStyle()),
            ),
            StreamBuilder(
                stream: _firestore.collection('events').orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    var items = snapshot.data!.docs;

                    List data = [];
                    for(var item in items){
                      if(!selectedScope.contains(item.reference.id)){
                        data.add(item);
                      }
                    }

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
                                      style: k10Text().copyWith(
                                        color: Colors.blue
                                      ),
                                    ),
                                  SizedBox(height: 5),
                                  KTextField(
                                    title: 'Inter City Price',
                                    textInputType: TextInputType.number,
                                    prefixText: ' ₹ ',
                                    onChanged: (value){
                                      EventPrice eventPrice = eventPriceList.firstWhere(
                                              (element) => element.id == data[index].reference.id);
                                      eventPrice.interCityPrice = int.parse(value);
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
                                            eventPrice.interStatePrice = int.parse(value);
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
                                            eventPrice.outerStatePrice = int.parse(value);
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
                                                hint: Text('Price Unit', style: Theme.of(context).textTheme.bodyMedium),
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
            kBottomSpace(),
          ],
        ),
      ),
      floatingActionButton: isLoading != true ? KButton(
        title: 'Save',
        onClick: (){
          setState(() {
            isLoading = true;
          });
          addScopePrice();
        },
      ) : LoadingButton(),
    );
  }

  void addScopePrice() {
    try {

      for(var item in eventPriceList){
        _firestore.collection('service').doc(widget.serviceID).update({
          "eventPrice": FieldValue.arrayUnion([{
            'eventID': item.id,
            'eventName': item.name,
            'interCityPrice': item.withSecurity != true ? item.interCityPrice : item.interCityPrice + 1000,
            'interStatePrice': item.withSecurity != true ? item.interStatePrice : item.interStatePrice + 1000,
            'outerStatePrice': item.withSecurity != true ? item.outerStatePrice : item.outerStatePrice + 1000,
            'priceUnit': item.priceUnit,
            'withSecurity': item.withSecurity,
          }]),
        });
      }
      Navigator.pop(context);
      toastMessage(message: 'Item saved');

    } catch (e){
      setState(() {
        isLoading = false;
      });
      toastMessage(message: '$e', colors: kRedColor);
    }
  }
}
