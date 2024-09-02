import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/kDatabase.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class EditMyEvent extends StatefulWidget {

  String serviceID;
  int scopeIndex;
  EditMyEvent({super.key, required this.serviceID, required this.scopeIndex});

  @override
  State<EditMyEvent> createState() => _EditMyEventState();
}

class _EditMyEventState extends State<EditMyEvent> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController interCityPrice = TextEditingController();
  TextEditingController interStatePrice = TextEditingController();
  TextEditingController outerStatePrice = TextEditingController();

  String eventIDValue = '';
  String eventName = '';
  String priceUnit = '';
  bool withSecurity = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getScopeData();
  }

  void getScopeData() async {
    var collection = _firestore.collection('service');
    var docs = await collection.doc(widget.serviceID).get();
    if(docs.exists){
      eventIDValue = '${docs['eventPrice'][widget.scopeIndex]['eventID']}';
      eventName = '${docs['eventPrice'][widget.scopeIndex]['eventName']}';
      interCityPrice.text = '${docs['eventPrice'][widget.scopeIndex]['interCityPrice']}';
      interStatePrice.text = '${docs['eventPrice'][widget.scopeIndex]['interStatePrice']}';
      outerStatePrice.text = '${docs['eventPrice'][widget.scopeIndex]['outerStatePrice']}';
      priceUnit = '${docs['eventPrice'][widget.scopeIndex]['priceUnit']}';
      withSecurity = docs['eventPrice'][widget.scopeIndex]['withSecurity'];
      setState(() {});
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: _firestore.collection('events').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  var data = snapshot.data!.docs;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Event Type', style: k12BoldStyle()),
                        Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width,
                          decoration: dropTextFieldDesign(context),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton(
                                borderRadius: BorderRadius.circular(10.0),
                                value: eventIDValue != '' ? eventIDValue : null,
                                hint: Text('Event Type', style: Theme.of(context).textTheme.bodyMedium),
                                items: data
                                    .map<DropdownMenuItem>((value) {
                                  return DropdownMenuItem(
                                    value: value.reference.id,
                                    child: Text('${value['name']}'),
                                    onTap: (){
                                      eventName = '${value['name']}';
                                    },
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    eventIDValue = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return CircularProgressIndicator();
              }
            ),
            KTextField(
              title: 'Inter City Price',
              controller: interCityPrice,
              prefixText: ' ₹ ',
              textInputType: TextInputType.number,
            ),
            KTextField(
              title: 'Inter State Price',
              controller: interStatePrice,
              prefixText: ' ₹ ',
              textInputType: TextInputType.number,
            ),
            KTextField(
              title: 'Outer State Price',
              controller: outerStatePrice,
              prefixText: ' ₹ ',
              textInputType: TextInputType.number,
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
                          value: priceUnit != '' ? priceUnit : null,
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
                              priceUnit = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              onTap: (){
                setState(() {
                  withSecurity = !withSecurity;
                });
                if(withSecurity != true){
                  interCityPrice.text = '${int.parse(interCityPrice.text) - 1000}';
                  interStatePrice.text = '${int.parse(interStatePrice.text) - 1000}';
                  outerStatePrice.text = '${int.parse(outerStatePrice.text) - 1000}';
                } else {
                  interCityPrice.text = '${int.parse(interCityPrice.text) + 1000}';
                  interStatePrice.text = '${int.parse(interStatePrice.text) + 1000}';
                  outerStatePrice.text = '${int.parse(outerStatePrice.text) + 1000}';
                }
              },
              leading: Icon(withSecurity != false ? Icons.check_box : Icons.check_box_outline_blank),
              title: Text('With Security'),
            )
          ],
        ),
      ),
      floatingActionButton: isLoading != true ? KButton(
        title: 'Save',
        onClick: (){
          setState(() {
            isLoading = true;
          });
          updateScope(context);
        },
      ) : LoadingButton(),
    );
  }

  void updateScope(context) async {
    final CollectionReference collection = _firestore.collection('service');
    final DocumentReference docRef = collection.doc(widget.serviceID);
    try{
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          List<dynamic> eventPriceData = docSnapshot['eventPrice'];
          eventPriceData[widget.scopeIndex] = {
            'eventID': eventIDValue,
            'eventName': eventName,
            'interCityPrice': int.parse(interCityPrice.text),
            'interStatePrice': int.parse(interStatePrice.text),
            'outerStatePrice': int.parse(outerStatePrice.text),
            'priceUnit': priceUnit,
            'withSecurity': withSecurity,
          };
          transaction.update(docRef, {'eventPrice': eventPriceData});
          Navigator.pop(context);
          toastMessage(message: 'Item updated successfully');
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      toastMessage(message: 'Something went wrong', colors: kRedColor);
    }
  }
}
