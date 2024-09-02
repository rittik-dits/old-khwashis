import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/DialogueBox/deletePopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Profile/Account/addBankAccount.dart';
import 'package:khwahish_provider/Screens/Profile/Account/editBankAccount.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/style.dart';

class BankAccount extends StatefulWidget {
  const BankAccount({super.key});

  @override
  State<BankAccount> createState() => _BankAccountState();
}

class _BankAccountState extends State<BankAccount> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('bankAccount')
            .where('userID', isEqualTo: ServiceManager.userID).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            var data = snapshot.data!.docs;
            return data.isNotEmpty ? ListView.separated(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 80),
              itemCount: data.length,
              itemBuilder: (context, index){
                String visiblePart = data[index]['accountNumber'].substring(4); // Show the first 4 digits
                String hiddenPart = "XXXX"; // Hide the rest
                return Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: roundedContainerDesign(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bank: ${data[index]['bankName']}'),
                            Text('Account Number: $visiblePart $hiddenPart'),
                            if(data[index]['isVerified'] != false)
                            Text('Verified',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => EditBankAccount(
                                  accountID: data[index].reference.id)));
                        },
                        icon: Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: (){
                          deletePopUp(context, onClickYes: (){
                            Navigator.pop(context);
                            _firestore.collection('bankAccount').doc(data[index].reference.id).delete();
                          });
                        },
                        icon: Icon(Icons.delete_forever_outlined),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return kSpace();
              },
            ) : EmptyScreen(message: 'No Account Found');
          }
          return LoadingIcon();
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: KButton(
        title: 'Add Account',
        onClick: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddBankAccount()));
        },
      ),
    );
  }
}
