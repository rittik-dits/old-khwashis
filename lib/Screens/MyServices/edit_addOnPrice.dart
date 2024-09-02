import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:khwahish_provider/model/addOn.dart';

class EditAddOnService extends StatefulWidget {

  String serviceID;
  int addOnIndex;
  EditAddOnService({super.key, required this.serviceID, required this.addOnIndex});

  @override
  State<EditAddOnService> createState() => _EditAddOnServiceState();
}

class _EditAddOnServiceState extends State<EditAddOnService> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController interCity = TextEditingController();
  final TextEditingController interState = TextEditingController();
  final TextEditingController outsideState = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAddOnData();
  }

  bool isLoading = false;

  String addOnName = '';
  List<AddOn> addOnList = [];
  void getAddOnData() async {
    var collection = _firestore.collection('service');
    var docs = await collection.doc(widget.serviceID).get();
    if(docs.exists){
      addOnName = '${docs['addon'][widget.addOnIndex]['addOnName']}';
      interCity.text = '${docs['addon'][widget.addOnIndex]['addOnPrice'][0]['price']}';
      interState.text = '${docs['addon'][widget.addOnIndex]['addOnPrice'][1]['price']}';
      outsideState.text = '${docs['addon'][widget.addOnIndex]['addOnPrice'][2]['price']}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Add On Price'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, bottom: 10),
                child: Text('Add On Name: $addOnName', style: kBoldStyle()),
              ),
              KTextField(
                title: 'Inter City Price',
                controller: interCity,
                textInputType: TextInputType.number,
                onChanged: (value){
                  if(value.isNotEmpty){
                    interState.text = (int.parse(interCity.text) * 1.5).toStringAsFixed(0);
                    outsideState.text = (int.parse(interCity.text) * 2).toStringAsFixed(0);
                  } else {
                    interState.text = '';
                    outsideState.text = '';
                  }
                },
              ),
              KTextField(
                title: 'InterState Price',
                controller: interState,
                textInputType: TextInputType.number,
              ),
              KTextField(
                title: 'Outside State Price',
                controller: outsideState,
                textInputType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isLoading != true ? KButton(
        title: 'Save',
        onClick: (){
          if(_formKey.currentState!.validate()){
            setState(() {
              isLoading = true;
            });
            updateAddOnPrice(context);
          }
        },
      ) : LoadingButton(),
    );
  }

  void updateAddOnPrice(context) async {
    final CollectionReference collection = _firestore.collection('service');
    final DocumentReference docRef = collection.doc(widget.serviceID);
    try {
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          List<dynamic> addOnPrice = docSnapshot['addon'];
          addOnPrice[widget.addOnIndex] = {
            'addOnName': addOnName,
            'addOnPrice': [
              {
                'priceName': 'Inter City',
                'price': int.parse(interCity.text),
              },
              {
                'priceName': 'Inter State',
                'price': int.parse(interState.text),
              },
              {
                'priceName': 'Outer State',
                'price': int.parse(outsideState.text),
              },
            ],
          };
          transaction.update(docRef, {'addon': addOnPrice});
          // print('Item at index ${widget.priceIndex} updated successfully');
        } else {
          // print('Document does not exist');
        }
      });
      Navigator.pop(context);
      toastMessage(message: 'Price Updated Successfully');
    } catch (e) {
      toastMessage(message: 'Error updating item', colors: kRedColor);
      setState(() {
        isLoading = false;
      });
    }
  }
}
