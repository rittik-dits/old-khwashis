import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Chat/messagePage.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: kWhiteColor,
        backgroundColor: k4Color,
        title: Text('Chat', style: kWhiteTextStyle()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: _firestore.collection('chat')
                  .orderBy('lastMessageTime', descending: true)
                  // .where('providerId', isEqualTo: ServiceManager.userID)
                  .snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  var chat = snapshot.data!.docs;
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    decoration: containerDesign(context),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: chat.length,
                      itemBuilder: (context, index){
                        return ListTile(
                          onTap: (){
                            // Navigator.push(context, MaterialPageRoute(
                            //     builder: (context) => MessagePage(
                            //       chatID: chat[index].reference.id,
                            //       chatWithUserID: '${chat[index]['userID']}',
                            //       name: '${chat[index]['senderName']}',
                            //       image: '${chat[index]['senderImage']}',
                            //     )));
                          },
                          leading: CircleAvatar(
                            radius: 30,
                            // backgroundImage: AssetImage('images/img_blank_profile.png'),
                            backgroundImage: NetworkImage(chat[index]['senderImage']),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${chat[index]['senderName']}', style: kBoldStyle()),
                              if(chat[index]['lastMessage'] != '')
                                Text('${chat[index]['lastMessage']}',
                                  style: k10Text(), maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if(chat[index]['lastProviderUnread'] != 0)
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: kMainColor,
                                  child: Text('${chat[index]['lastProviderUnread']}', style: kWhiteTextStyle()),
                                ),
                              if(chat[index]['lastMessageTime'] != '')
                                Text(timeago.format(chat[index]['lastMessageTime'].toDate())),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Divider(thickness: 1),
                        );
                      },
                    ),
                  );
                }
                return LoadingIcon();
              }
            ),
          ],
        ),
      ),
    );
  }
}
