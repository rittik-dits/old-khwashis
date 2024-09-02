import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Profile/coupons.dart';
import 'package:khwahish_provider/Screens/Profile/privacyPolicy.dart';
import 'package:khwahish_provider/Screens/Profile/termAndCondition.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Screens/navigationScreen.dart';
import 'package:khwahish_provider/Services/emailController.dart';
import 'package:khwahish_provider/Services/purchase_api.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:open_file/open_file.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:mailer/smtp_server.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController couponCode = TextEditingController();

  bool isLoading = false;
  bool couponApplied = false;
  num totalDiscount = 0;
  num totalTax = 0;
  num payableAmount = ServiceManager.registrationFee;

  late Razorpay _razorpay;
  bool showAll=false;

  void startPayment(num amount) {
    var options = {
      'key': ServiceManager.razorPayKey,
      'amount': amount * 100,
      'name': 'Khwahish',
      'description': 'Subscription Charge',
      'prefill': {
        'contact': ServiceManager.userMobile,
        'email': ServiceManager.userEmail
      }
    };
    _razorpay.open(options);
  }

  @override
  void initState() {
    print(ServiceManager.userID);
    print(EmailController.adminEmail);
    print(ServiceManager.userAddress);

    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    calculateTax();

    // Purchases.addCustomerInfoUpdateListener((_) =>
    //     updateCustomerStatus());
    // updateCustomerStatus();
  }

  void calculateTax() {
    num tax = payableAmount / 100 * 18; //18% GST
    setState(() {
      totalTax = tax;
    });
  }

  Future fetchOffers() async {
    final offerings = await PurchaseApi.fetchOffers();

    if (offerings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No Plans Found'),
      ));
    } else {
      final offer = offerings
          .map((offer) => offer.availablePackages)
          .expand((pair) => pair)
          .toList();

      // Utils.showSheet(
      //   context,
      //     (context) => PayWalletWidget
      // )
    }
  }

  Future updateCustomerStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();

    customerInfo.entitlements;
  }

  //-------------------------------invoice pdf--------------------------
  Future<pw.Font> loadCustomFont() async {
    final fontData = await rootBundle.load('fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    return ttf;
  }

  Future<pw.ImageProvider> loadImage(String path) async {
    final data = await rootBundle.load(path);
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  Future<Uint8List> generateInvoicePdf(Map<String, String> priceDetails) async {
  final pdf = pw.Document();
  final font = await loadCustomFont();
  final image = await loadImage('images/app_logo.png');

  // Generate a random 12-digit invoice ID
  final invoiceId = List.generate(12, (_) => Random().nextInt(10)).join();

  // Get the current date
  final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Image(image, width: 100, height: 100),
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('Khwahish Tax Invoice',
                    style: pw.TextStyle(fontSize: 24, font: font)),
              ),
              pw.SizedBox(height: 20),
              
              pw.Row(children: [
                pw.Expanded(child: pw.Container()),
                pw.Expanded(child: 
                 pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Date: $currentDate'),
                  pw.Text('Invoice ID: $invoiceId'),
                ],
              )),

              ]
              ),
              pw.SizedBox(height: 20),
             

              // Sender and Receiver Addresses
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("To:"),
                        pw.Text(ServiceManager.userName),
                        pw.Text(ServiceManager.userAddress),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("From:"),
                        pw.Text("INTELICANVAS DIGITAL PVT. LTD"),
                        pw.Text(
                          "1858/1, Rajdanga Main Rd, 6th floor,\nMerlin Acropolis, Suit no: 02. East Kolkata Twp,Kolkata West Bengal 700107",
                          textAlign: pw.TextAlign.right,
                        ),
                        pw.Text("GST: 19AAHCI2838N1ZZ"),
                      //  pw.Text(ServiceManager.companyAddress, textAlign: pw.TextAlign.right),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Date and Invoice ID
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date: $currentDate'),
                  pw.Text('Invoice ID: $invoiceId'),
                ],
              ),
              pw.SizedBox(height: 20),

              // Invoice Details Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Subscription Charge',
                            style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                            '${kAmount(ServiceManager.registrationFee - totalTax)}',
                            style: pw.TextStyle(font: font)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('IGST/CGST',
                            style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${kAmount(totalTax / 2)}',
                            style: pw.TextStyle(font: font)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('SGST', style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${kAmount(totalTax / 2)}',
                            style: pw.TextStyle(font: font)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Coupon Discount',
                            style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${kAmount(totalDiscount)}',
                            style: pw.TextStyle(font: font)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Sub Total',
                            style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('${kAmount(payableAmount)}',
                            style: pw.TextStyle(font: font)),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Thank you for your business'),
                    pw.Text('customercare@khwahish.live | +917980765931'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
  return pdf.save();
}

  Future<File> savePdf(Uint8List pdfData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/invoice.pdf');
    await file.writeAsBytes(pdfData);
    print(file.path);

// OpenFile.open(file.path);
    return file;
  }

  Future<void> sendEmailWithAttachment(
      String recipientEmail, String subject, String text, File pdfFile) async {
    final smtpServer = gmail('noreply.khwahish@gmail.com', 'qgdboxgmxtlemwxj');

    final message = Message()
      ..from = Address(recipientEmail, 'Khwahish')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = text
      ..attachments.add(FileAttachment(pdfFile));

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  //-------------------------------invoice pdf--------------------------

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription'),
        // actions: [
        //   TextButton(
        //     onPressed: () => calculateTax(),
        //     child: Text('test'),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            kSpace(),
            Image.asset(
              'images/app_logo.png',
              height: 150,
            ),
            kSpace(),
            Text(kAmount(ServiceManager.registrationFee)),
            Text('Duration 1 Year'),
            kSpace(),
            StreamBuilder(
      stream: _firestore.collection('coupons').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var docs = snapshot.data!.docs;
          List couponList = docs;

          int itemCount = showAll ? couponList.length : (couponList.length > 2 ? 2 : couponList.length);

          return couponList.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: itemCount + (couponList.length > 2 ? 1 : 0), // Add one for the arrow icon
                  itemBuilder: (context, index) {
                    if (index < itemCount) {
                      return Padding(
                        padding: EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(
                                text: '${couponList[index]['couponCode']}'));
                            setState(() {
                              couponCode.text = couponList[index]['couponCode'];
                            });
                            toastMessage(message: 'Coupon Copied');
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: roundedShadedDesign(context),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${couponList[index]['title']}', style: kHeaderStyle()),
                                    Text('${couponList[index]['description']}', style: k14Style()),
                                  ],
                                ),
                                Spacer(),
                                Chip(
                                  label: Text(
                                    '${couponList[index]['couponCode']}',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Arrow icon
                      return IconButton(
                        icon: Icon(showAll ? Icons.arrow_drop_up : Icons.arrow_drop_down,size: 35,),
                        onPressed: () {
                          setState(() {
                            showAll = !showAll;
                          });
                        },
                      );
                    }
                  },
                )
              : EmptyScreen(message: 'No Coupons Available');
        }
        return Center(child: CircularProgressIndicator());
      },
    ),
            // StreamBuilder(
            //   stream: _firestore.collection('coupons').snapshots(),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       var docs = snapshot.data!.docs;
            //       List couponList = docs;
            //       // for (var item in docs) {
            //       //   if (!item['usedUser'].contains(ServiceManager.userID) &&
            //       //       item['allotted'].contains(ServiceManager.userID)) {
            //       //     if (item['count'] > 0) {
            //       //       couponList.add(item);
            //       //     }
            //       //   }
            //       // }
            //       return couponList.isNotEmpty
            //           ? ListView.builder(
            //               shrinkWrap: true,
            //               physics: BouncingScrollPhysics(),
            //               itemCount: couponList.length,
            //               itemBuilder: (context, index) {
            //                 return Padding(
            //                   padding: EdgeInsets.all(10.0),
            //                   child: GestureDetector(
            //                     onTap: () async {
            //                       await Clipboard.setData(ClipboardData(
            //                           text:
            //                               '${couponList[index]['couponCode']}'));
            //                       setState(() {
            //                         couponCode.text =
            //                             couponList[index]['couponCode'];
            //                       });
            //                       toastMessage(message: 'Coupon Copied');
            //                     },
            //                     child: Container(
            //                       padding: EdgeInsets.all(5),
            //                       decoration: roundedShadedDesign(context),
            //                       // color: Color.fromARGB(255, 247, 182, 113),
            //                       child: Row(
            //                         children: [
            //                           Column(
            //                             // mainAxisSize: MainAxisSize.min,
            //                             mainAxisAlignment:
            //                                 MainAxisAlignment.center,
            //                             crossAxisAlignment:
            //                                 CrossAxisAlignment.start,
            //                             children: [
            //                               Text('${couponList[index]['title']}',
            //                                   style: kHeaderStyle()),
            //                               Text(
            //                                   '${couponList[index]['description']}',
            //                                   style: k14Style()),
            //                             ],
            //                           ),
            //                           Spacer(),
            //                           Chip(
            //                             label: Text(
            //                               '${couponList[index]['couponCode']}',
            //                               style: TextStyle(
            //                                   fontWeight: FontWeight.w600,
            //                                   color: Colors.black),
            //                             ),
            //                             backgroundColor: Colors.transparent,
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ),
            //                 );
            //               },
            //             )
            //           : EmptyScreen(message: 'No Coupons Available');
            //     }
            //     return Center(child: CircularProgressIndicator());
            //   },
            // ),
            KTextField(
              title: 'Coupon Code',
              controller: couponCode,
              suffixButton: TextButton(
                onPressed: () {
                  if (couponCode.text != '') {
                    if (couponApplied != true) {
                      applyCoupon();
                    } else {
                      toastMessage(
                          message: 'Coupon Applied Already', colors: kRedColor);
                    }
                  } else {
                    toastMessage(
                        message: 'Enter coupon code', colors: kRedColor);
                  }
                },
                child: Text('Apply'),
              ),
            ),
            kSpace(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  kRowSpaceText('Subscription Charge: ',
                      kAmount(ServiceManager.registrationFee - totalTax)),
                  kRowSpaceText('IGST/CGST: ', kAmount(totalTax / 2)),
                  kRowSpaceText('SGST: ', kAmount(totalTax / 2)),
                  kRowSpaceText(
                      'Coupon Discount: ', '- ${kAmount(totalDiscount)}'),
                  kDivider(),
                  kRowSpaceText('Payable Amount: ', kAmount(payableAmount)),
                ],
              ),
            ),
            kSpace(),
            isLoading != true
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: K2Button(
                      title: 'Subscribe',
                      color: kLightGreen,
                      onClick: () async {
                        if (payableAmount > 0) {
                          if (!Platform.isIOS) {
                            setState(() {
                              isLoading = true;
                            });

                            startPayment(payableAmount);
                          } else {
                            print("IOs");
                            inAppPurchase(context);
                          }
                        } else {
                          print("sub 2222222");
                          subscribePlan2();
                        }
                       // subscribePlan2();
                      },
                    ),
                  )
                : LoadingButton(),
            kBottomSpace(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.black54),
                  children: <TextSpan>[
                    TextSpan(text: 'By Subscribing you agree to our '),
                    TextSpan(
                      text: 'Term & condition',
                      style: linkTextStyle(),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TermAndCondition()));
                        },
                    ),
                    TextSpan(text: ' and that you have read our '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: linkTextStyle(),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrivacyPolicy()));
                        },
                    ),
                  ],
                ),
              ),
            ),
            kBottomSpace(),
          ],
        ),
      ),
    );
  }

  String couponID = '';
  void applyCoupon() async {
    var collection = _firestore.collection('coupons');
    QuerySnapshot querySnapshot = await collection.get();
    bool validCouponFound = false;

    for (DocumentSnapshot doc in querySnapshot.docs) {
      if (doc['couponCode'] == couponCode.text) {
        if (!doc['usedUser'].contains(ServiceManager.userID)) {
          if (doc['expiryDate'].toDate().isAfter(DateTime.now())) {
            setState(() {
              totalDiscount = doc['value'];
              payableAmount -= totalDiscount;
              couponID = doc.reference.id;
              couponApplied = true;
            });
            validCouponFound = true;
            toastMessage(message: 'Coupon Applied');
          } else {
            validCouponFound = true;
            toastMessage(message: 'Coupon Expired', colors: kRedColor);
          }
        } else {
          validCouponFound = true;
          toastMessage(message: 'Coupon Applied Already', colors: kRedColor);
        }
        break; // Exit the loop once a valid coupon is found
      }
    }

    if (!validCouponFound) {
      toastMessage(message: 'Invalid Coupon code', colors: kRedColor);
    }
  }

  void subscribePlan2() async {
    print("Sub plan");
    var address = ServiceManager.companyAddress;

    print(ServiceManager.userEmail);

    String startDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String endDate = DateFormat('dd/MM/yyyy')
        .format(DateTime.now().add(Duration(days: 365)));

    try {
      _firestore.collection('provider').doc(ServiceManager.userID).update({
        'isSubscribed': true,
        'subscriptionStartDate': startDate,
        'subscriptionEndDate': endDate,
      }).then((value) async {
        updateData();

        Map<String, String> priceDetails = {
          'subscriptionCharge':
              (ServiceManager.registrationFee - totalTax).toStringAsFixed(0),
          'IGST/CGST': (totalTax / 2).toStringAsFixed(0),
          'SGST': (totalTax / 2).toStringAsFixed(0),
          'discount': '- $totalDiscount',
          'payableAmount': payableAmount.toStringAsFixed(0),
        };

        // Generate PDF
        print("generateInvoicePdf1");
        Uint8List pdfData = await generateInvoicePdf(priceDetails);
        print(pdfData.toString());
        print("generateInvoicePdf");
        print("save pdf");
        File pdfFile = await savePdf(pdfData);
        print("save pdf");

        // Send email to user
        // EmailController().sendSubscriptionMail(
        //   recipientEmail: ServiceManager.userEmail,
        //   price: priceDetails,
        // );
        // print("send mail without doc");
        await sendEmailWithAttachment(
          ServiceManager.userEmail,
          'Your Subscription Invoice',
          'Please find your subscription invoice attached.',
          pdfFile,
        );

        // Send email to admin
        String adminMessage =
            'User: ${ServiceManager.userID} whose ID: ${ServiceManager.userID}\n'
            'has successfully subscribed to the subscription.\n'
            'Subscription Charge:  ${(ServiceManager.registrationFee - totalTax).toStringAsFixed(0)}\n'
            'IGST/CGST: ${(totalTax / 2).toStringAsFixed(0)}\n'
            'SGST: ${(totalTax / 2).toStringAsFixed(0)}\n'
            'Discount: -$totalDiscount \n'
            'Subscription Charge: ${payableAmount.toStringAsFixed(0)}\n';

        await sendEmailWithAttachment(
          EmailController.adminEmail,
          'New Subscription',
          adminMessage,
          pdfFile,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => NavigationScreen()),
          (route) => false,
        );
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  void subscribePlan() async {
    String startDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String endDate = DateFormat('dd/MM/yyyy')
        .format(DateTime.now().add(Duration(days: 365)));

    try {
      _firestore.collection('provider').doc(ServiceManager.userID).update({
        'isSubscribed': true,
        'subscriptionStartDate': startDate,
        'subscriptionEndDate': endDate,
      }).then((value) => {
            updateData(),

            ///to User
            EmailController().sendSubscriptionMail(
              recipientEmail: ServiceManager.userEmail,
              price: {
                'subscriptionCharge':
                    (ServiceManager.registrationFee - totalTax)
                        .toStringAsFixed(0),
                'IGST/CGST': (totalTax / 2).toStringAsFixed(0),
                'SGST': (totalTax / 2).toStringAsFixed(0),
                'discount': '- $totalDiscount',
                'payableAmount': payableAmount.toStringAsFixed(0),
              },
            ),

            ///to admin
            EmailController().sendMail(
              recipientEmail: EmailController.adminEmail,
              mailMessage:
                  'User: ${ServiceManager.userID} whose ID: ${ServiceManager.userID}\n'
                  'has successfully subscribed to the subscription.\n'
                  'Subscription Charge:  ${(ServiceManager.registrationFee - totalTax).toStringAsFixed(0)}\n'
                  'IGST/CGST: ${(totalTax / 2).toStringAsFixed(0)}\n'
                  'SGST: ${(totalTax / 2).toStringAsFixed(0)}\n'
                  'Discount: -$totalDiscount \n'
                  'Subscription Charge: ${payableAmount.toStringAsFixed(0)}\n',
            ),
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => NavigationScreen()),
                (route) => false),
          });
    } catch (e) {
      print(e);
    }
  }

  void updateData() async {
    var collection = _firestore.collection('coupons');
    var docs = await collection.doc(couponID).get();
    if (docs.exists) {
      if (!docs['usedUser'].contains(ServiceManager.userID)) {
        _firestore.collection('coupons').doc(couponID).update({
          'usedUser': FieldValue.arrayUnion([ServiceManager.userID]),
          'count': docs['count'] - 1,
        });
      } else {
        toastMessage(message: 'Coupon Applied Already');
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    toastMessage(message: 'Payment Successful');
    subscribePlan();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    toastMessage(message: 'Payment failed', colors: Colors.red);
    setState(() {
      isLoading = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  void inAppPurchase(context) async {
    await Purchases.purchaseProduct('khwahish1');
    subscribePlan();
  }
}
