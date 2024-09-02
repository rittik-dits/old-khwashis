import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khwahish_provider/Components/DialogueBox/cancelPopUp.dart';
import 'package:khwahish_provider/Components/DialogueBox/popup.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/FirebaseAPIMessage.dart';
import 'package:khwahish_provider/Services/emailController.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class BookingDetails extends StatefulWidget {

  String bookingID;
  BookingDetails({super.key, required this.bookingID});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Booking Details'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('booking').doc(widget.bookingID).snapshots(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            var data = snapshot.data;
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: containerDesign(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        kRowText('Order ID: ', data!.reference.id),
                        Row(
                          children: [
                            Icon(Icons.schedule_outlined, size: 20),
                            SizedBox(width: 10),
                            Text(DateFormat('dd-MM-yyyy - hh:mm a').format(DateTime.parse('${data['time'].toDate()}'))),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        if(data['paymentMethod'] != '')
                          Row(
                            children: [
                              Text('Payment', style: kBoldStyle()),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: k4Color,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text('${data['paymentMethod']}', style: kWhiteTextStyle()),
                              ),
                            ],
                          ),
                        kRowSpaceText('Payment Status', '${data['paymentStatus']}'),
                        kDivider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer', style: kBoldStyle(),),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                      image: NetworkImage('${data['customerAvatar']}'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${data['customer']}',
                                        style: kBoldStyle(),
                                        maxLines: 2, overflow: TextOverflow.ellipsis,
                                      ),
                                      kRowText('Address: ', '${data['address']}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        kDivider(),
                        kRowSpaceText('Order Status', '${data['status']}'),
                        // kRowSpaceText('Address', '${data['address']}'),
                        data['anyTime'] == true ?
                        kRowSpaceText('Appointment Time', 'Any Time') :
                        Column(
                          children: [
                            kRowSpaceText('Date', '${data['selectedDate']}'),
                            kRowSpaceText('Start Time', DateFormat('hh:mm a').format(DateTime.parse('${data['selectTime'].toDate()}'))),
                            kRowSpaceText('End Time', DateFormat('hh:mm a').format(DateTime.parse('${data['selectEndTime'].toDate()}'))),
                          ],
                        ),
                        if(data['products'][0]['venue'] != null && data['products'][0]['venue'] != '')
                          kRowSpaceText('Venue City', '${data['products'][0]['venue']}'),
                          kRowSpaceText('Venue Address', '${data['products'][0]['venueAddress']}'),
                        if(data['products'] != null)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: data['products'].length,
                            itemBuilder: (context, index){
                              var product = data['products'][index];
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                              image: NetworkImage('${product['gallery'][0]['serverPath']}'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${product['name'][0]['text']}',
                                                style: kBoldStyle(),
                                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                              ),
                                              if(data['eventName'] != '')
                                              Text('Event: ${data['eventName']}'),
                                              // Text('₹${product['price'][0]['price']}'),
                                              if(product['numberOfGuest'] != null && product['numberOfGuest'] != '')
                                                Text('Number of Guest: ${product['numberOfGuest']}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if(product['addon'].isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        kDivider(),
                                        Text('Add On Services', style: k12BoldStyle()),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: product['addon'].length,
                                          itemBuilder: (context, index){
                                            return kRowSpaceText('${product['addon'][index]['addOnName']}',
                                                '₹${(product['addon'][index]['price'].toStringAsFixed(2))}');
                                          },
                                        ),
                                        // kRowSpaceText('${product['']}', '₹${(data['price'].toStringAsFixed(2))}'),
                                      ],
                                    ),
                                ],
                              );
                            },
                          ),
                        kDivider(),
                        kRowSpaceText('Sub Total', '₹${(data['price'].toStringAsFixed(2))}'),
                        kRowSpaceText('Add On Price', '₹${(data['products'][0]['addonPrice'].toStringAsFixed(2))}'),
                        kRowSpaceText('Discount', '(-) ₹${(data['discount'].toStringAsFixed(2))}'),
                        // kRowSpaceText('VAT/TAX', '(+) ₹${(data['tax'].toStringAsFixed(2))}'),
                        kDivider(),
                        kRowSpaceText('Total Amount', '₹${(data['total'].toStringAsFixed(2))}'),
                        if(data['status'] != 'Cancelled' && data['status'] != 'Accepted' && data['status'] != 'Completed')
                        Column(
                          children: [
                            kSpace(),
                            KButton(
                              title: 'Accept Booking',
                              color: Colors.green,
                              onClick: (){
                                kPopUp(context,
                                  title: 'Accept?',
                                  desc: 'Are you sure you want to accept this booking?',
                                  onClickYes: (){
                                    Navigator.pop(context);
                                    _firestore.collection('booking').doc(data.reference.id).update({
                                      'status': 'Accepted',
                                    });

                                    sendAcceptNotification(userID: '${data['customerId']}');
                                    ///to Admin
                                    EmailController().sendMail(
                                      recipientEmail: EmailController.adminEmail,
                                      mailMessage: 'I have accepted the booking successfully '
                                          'and would like to perform as an artist in your event.\n'
                                          'Booking ID: ${widget.bookingID}',
                                    );
                                    ///to User
                                    EmailController().sendMailOnAcceptanceWithDoc(
                                      recipientEmail: '${data['customerEmail']}',
                                      mailMessage: 'I have accepted the booking successfully '
                                          'and would like to perform as an artist in your event.\n'
                                          'Booking ID: ${widget.bookingID}',
                                    );
                                    ///To Artist
                                    EmailController().sendMailOnAcceptanceWithDoc(
                                      recipientEmail: ServiceManager.userEmail,
                                      mailMessage: 'You have accepted the booking successfully\n'
                                          'Booking ID: ${widget.bookingID}',
                                    );
                                  },
                                );
                              },
                            ),
                            Center(
                              child: KButton(
                                title: 'Cancel Booking',
                                color: kRedColor,
                                onClick: (){
                                  cancelPopUp(context, onClickYes: (){
                                    Navigator.pop(context);
                                    _firestore.collection('booking').doc(data.reference.id).update({
                                      'status': 'Cancelled',
                                    });
                                  });

                                  sendCancelNotification(userID: '${data['customerId']}');
                                  ///to user
                                  EmailController().sendMail(
                                    recipientEmail: '${data['customerEmail']}',
                                    mailMessage: "You booking was cancelled by the artist \n Booking ID: "
                                        "${widget.bookingID}",
                                  );
                                  ///to Admin
                                  EmailController().sendMail(
                                    recipientEmail: EmailController.adminEmail,
                                    mailMessage: 'Artist : ${ServiceManager.userName} have cancelled the booking.\n'
                                        'Booking ID: ${widget.bookingID}',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        if(data['status'] == 'Accepted')
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: KButton(
                              title: 'Completed',
                              onClick: (){
                                _firestore.collection('booking').doc(data.reference.id).update({
                                  'status': 'Completed',
                                });
                                ///to Admin
                                EmailController().sendMail(
                                  recipientEmail: EmailController.adminEmail,
                                  mailMessage: 'Artist have completed the event successfully\n'
                                      'Booking ID: ${widget.bookingID}',
                                );
                                ///to Artist
                                EmailController().sendMail(
                                  recipientEmail: ServiceManager.userEmail,
                                  mailMessage: "You have completed the event successfully \n Booking ID: "
                                      "${data.reference.id}.",
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return LoadingIcon();
        },
      ),
    );
  }

  void sendAcceptNotification({required String userID}) async {
    var collection = _firestore.collection('listusers');
    var docs = await collection.doc(userID).get();
    if(docs.exists){
      NotificationCloud().sendNotification('Hey ${docs['name']}', 'Your booking has been accepted', docs['FCM']);
    }
  }

  void sendCancelNotification({required String userID}) async {
    var collection = _firestore.collection('listusers');
    var docs = await collection.doc(userID).get();
    if(docs.exists){
      NotificationCloud().sendNotification('Hey ${docs['name']}', 'Sorry! Your booking has been cancelled', docs['FCM']);
    }
  }
}
