import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/notLogedInScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class MessagePage extends StatefulWidget {

  MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kBackgroundDesign(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          // foregroundColor: kWhiteColor,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: shadedTopGradient(),
            ),
          ),
          // titleSpacing: 0.0,
          title: Row(
            children: const [
              CircleAvatar(
                // backgroundImage: AssetImage('images/img_blank_profile.png'),
                backgroundImage: AssetImage('images/app_logo.png'),
                // backgroundImage: NetworkImage(widget.image),
              ),
              SizedBox(width: 10.0),
              Text('Khwahish'),
            ],
          ),
        ),
        body: ServiceManager.userID != '' ? Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: _firestore.collection('messages')
                      .orderBy('createdAt', descending: true)
                      .where('chatID', isEqualTo: ServiceManager.userID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData) {
                      var message = snapshot.data!.docs;
      
                      // _firestore.collection('chat').doc(widget.chatID).update({
                      //   'lastUserUnread': 0
                      // });
      
                      return ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        physics: BouncingScrollPhysics(),
                        itemCount: message.length,
                        itemBuilder: (context, index){
                          return Align(
                            alignment: message[index]['sendBy'] == ServiceManager.userID ?
                            Alignment.centerRight : Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 4.0, bottom: 4.0,
                                left: message[index]['sendBy'] == ServiceManager.userID ? 40.0 : 10,
                                right: message[index]['sendBy'] != ServiceManager.userID ? 40.0 : 10,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor != Colors.black ? Colors.white : kDarkColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: true ? [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2.0,
                                      blurRadius: 2.0,
                                      offset: Offset(1,2),
                                    ),
                                  ] : null,
                                ),
                                child: Column(
                                  children: [
                                    Text('${message[index]['message']}'),
                                    // Text(timeago.format(message[index]['createdAt'].toDate())),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return LoadingIcon();
                  }
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
              decoration: containerDesign(context).copyWith(color: k4Color),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: Theme.of(context).scaffoldBackgroundColor
                      ),
                      child: TextField(
                        controller: message,
                        onChanged: (value){},
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'send message...',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      if(message.text != '') {
                        sendMessage();
                      }
                    },
                    icon: Icon(Icons.send, color: kWhiteColor),
                  ),
                ],
              ),
            ),
          ],
        ) : NotLoggedInScreen(),
      ),
    );
  }

  void sendMessage() {
    _firestore.collection('messages').add({
      'chatID': ServiceManager.userID,
      'createdAt': DateTime.now(),
      'message': message.text,
      'read': false,
      'receiveBy': 'Admin',
      'sendBy': ServiceManager.userID,
    }).then((value) => {
      updateChat(message.text),
      setState((){
        message.text = '';
      }),
    });
  }

  Future<void> updateChat(String messageText) async {

    try {
      DocumentSnapshot docSnapshot = await _firestore.collection('chat').doc(ServiceManager.userID).get();
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        DocumentReference docRef = _firestore.collection('chat').doc(ServiceManager.userID);
        Map<String, dynamic> updatedData = {
          'lastMessageTime': DateTime.now(),
          'lastMessage': messageText,
          'lastAdminUnread': data['lastAdminUnread'] + 1,
        };
        await docRef.update(updatedData);
        setState(() {
          message.text = '';
        });

      } else {
        print('Document does not exist.');
        _firestore.collection('chat').doc(ServiceManager.userID).set({
          'lastAdminUnread': 1,
          'lastMessage': messageText,
          'lastMessageTime': DateTime.now(),
          'lastUserUnread': 0,
          'userID': ServiceManager.userID,
          'userName': ServiceManager.userName,
          'userImage': ServiceManager.profileURL,
        });
      }
    } catch (e) {
      print('Error fetching and printing data: $e');
    }
  }
}
