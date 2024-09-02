import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googleapis/connectors/v1.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceManager {
  // static String companyNumber = '+91 2537462624';
  static String companyNumber = '+917980765931';
  static String companyAddress = '';
  // static String supportEmail = 'support@khwahish.com';
  static String supportEmail = 'customercare@khwahish.live';
  static String razorPayKey = 'rzp_live_h5nwPTx2912ZJH';
  // static String razorPayKey = 'rzp_test_fx15BZenrqFdd1'; //test
  static String panIndiaID = 'tWkbzHNp0lm8ldfZmxoo';

  static String userID = '';
  static String profileURL = '';
  static String userName = 'Guest';
  static String userEmail = '';
  static String userMobile = '';
  static String userAddress = '';
  static bool isSubscribed = false;
  static bool isVerified = false;
  static String subscriptionStartDate = '';
  static String subscriptionEndDate = '';

  static String aboutUS = '';
  static int notificationNumber = 0;
  static int securityCharge = 1500;
  static int registrationFee = 1500;
  static List<LatLng> polylineCoordinates = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setUser(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userID', userID);
  }

  void getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID') ?? '';
    if (userID != '') {
      getUserData();
    }
  }

  void removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userID');
    userID = '';
  }

  void getSettings() async {
    var collection = _firestore.collection('settings');
    var querySnapshot = await collection.doc('main').get();
    var querySnapshot2 = await collection.doc('subscriptions').get();
    if (querySnapshot.exists) {
      aboutUS = querySnapshot.data()!['about'];
      securityCharge = querySnapshot['securityCharge'];
    }
    if (querySnapshot2.exists) {
      registrationFee = querySnapshot2['subscriptionCharge'] ?? 1000;
    }
  }

  Future<void> getUserData() async {
    var collection = _firestore.collection('provider');
    var docs = await collection.doc(ServiceManager.userID).get();

    if (docs.exists) {
      userID = docs.reference.id;
      profileURL = '${docs.data()!['logoServerPath']}';
      String middleName =
          docs['middleName'] != '' ? '${docs['middleName']} ' : '';
      userName = '${docs['firstName']} $middleName${docs['lastName']}';
      userEmail = '${docs.data()!['login']}';
      userMobile = '${docs.data()!['phone']}';
      userAddress = '${docs.data()!['address']}';
      isSubscribed = docs['isSubscribed'] ?? false;
      isVerified = docs['isVerified'] ?? false;
      subscriptionStartDate = '${docs.data()!['subscriptionStartDate']}';
      subscriptionEndDate = '${docs.data()!['subscriptionEndDate']}';
      if (docs.data()!['route'] != null || docs.data()!['route'].isNotEmpty) {
        polylineCoordinates = [];
        for (var data in docs.data()!['route']) {
          polylineCoordinates.add(LatLng(data['lat'], data['lng']));
        }
      }
    }
  }

  bool isUpcomingDate(String dateString) {
    try {
      // Split the date string into day, month, and year components
      List<String> dateComponents = dateString.split('/');

      // Ensure there are three components (day, month, year)
      if (dateComponents.length == 3) {
        int day = int.parse(dateComponents[0]);
        int month = int.parse(dateComponents[1]);
        int year = int.parse(dateComponents[2]);

        // Create a DateTime object from the components
        DateTime dateTime = DateTime(year, month, day);

        // Get the current date and time
        DateTime now = DateTime.now();

        // Compare the two dates
        return dateTime.isAfter(now);
      } else {
        // Invalid date format
        return false;
      }
    } catch (e) {
      // Error occurred during parsing
      return false;
    }
  }

  updateSubscriptionData() async {
    var collection = _firestore.collection('provider');
    var docs = await collection.doc(ServiceManager.userID).get();
    if (docs.exists) {
      if (docs['subscriptionEndDate'] != '') {
        if (isUpcomingDate(docs['subscriptionEndDate']) != true) {
          _firestore.collection('collectionPath').doc(userID).update({
            'isSubscribed': false,
          });
        } else {
          // print('subscription does not expires');
        }
      }
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // print("Error: ${e.code}");
        toastMessage(message: e.code, colors: kRedColor);
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verificationId somewhere.
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timed out.
      },
    );
  }

  Future<String> uploadImage(String imagePath, String folderName) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference storageRef = storage.ref().child(folderName);
    final String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference imageRef = storageRef.child(imageName);
    final UploadTask uploadTask = imageRef.putFile(File(imagePath));
    final TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
    final String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadVideo(String imagePath, String folderName) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference storageRef = storage.ref().child(folderName);
    final String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference imageRef = storageRef.child(imageName);
    final UploadTask uploadTask = imageRef.putFile(File(imagePath));
    final TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
    final String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadThumbnail(Uint8List thumbnailBytes) async {
    String thumbnailFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('thumbnails/$thumbnailFileName.jpg');
    UploadTask uploadTask = storageReference.putData(thumbnailBytes);
    await uploadTask.whenComplete(() => print('Thumbnail uploaded'));
    return await storageReference.getDownloadURL();
  }

  Future<void> deleteServicePriceAtIndex(
      {required String serviceID, required int priceIndex}) async {
    final CollectionReference collection = _firestore.collection('service');
    final DocumentReference docRef = collection.doc(serviceID);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          List<dynamic> priceData = docSnapshot['price'];
          priceData
              .removeAt(priceIndex); // Remove the item at the specified index
          transaction.update(docRef, {'price': priceData});
          toastMessage(message: 'Item removed from price List successfully');
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      toastMessage(message: 'Error deleting this item', colors: kRedColor);
    }
  }

  String getFirstName(String name) {
    List<String> nameParts = name.split(" ");
    String firstName = nameParts.length > 1 ? nameParts.first : name;
    // print(firstName);
    return firstName; // Tony Stark is
  }

  String getMiddleName(String name) {
    List<String> nameParts = name.split(" ");
    String middleName = nameParts.length > 2
        ? nameParts.sublist(1, nameParts.length - 1).join(" ")
        : '';
    // print(middleName);
    return middleName; // Tony Stark is
  }

  String getLastName(String name) {
    var names = name.split(' ');
    String lastName = names.length > 1 ? names.last : '';
    // print(lastName);
    return lastName;
  }

  void updateAll() async {
    QuerySnapshot snapshot = await _firestore.collection('provider').get();
    for (QueryDocumentSnapshot document in snapshot.docs) {
      // print(document['name'][0]['text']);
      // Map<String, dynamic> newData = {
      //   'name': '${document['name'][0]['text']}',
      // };
      // await _firestore.collection('category').doc(document.id).update(newData);
      await _firestore
          .collection('provider')
          .doc(document.id)
          .update({'wallet': 0});
    }

    print('All documents updated successfully');
  }

  // void updateAll() async {
  //   QuerySnapshot snapshot = await _firestore.collection('booking').get();
  //   for (QueryDocumentSnapshot document in snapshot.docs) {
  //     print(document['products'][0]['venueAddress']);
  //     // Map<String, dynamic> newData = {
  //     //   'vanueLatLang': '${document['products'][0]['vanueLatLang']}',
  //     // };
  //     // print(newData);
  //     GeoPoint newGeoPoint = GeoPoint(0, 0);
  //     Map<String, dynamic> newData = {
  //       'products': [
  //         {
  //           ...document['products'][0],
  //           'vanueLatLang': newGeoPoint,
  //         }
  //       ]
  //     };
  //     print(newData);

  //     try {
  //       await _firestore
  //           .collection('booking')
  //           .doc(document.id)
  //           .update(newData);
  //     } catch (e) {
  //       print(e);
  //     }

  //     // await _firestore.collection('provider').doc(document.id).update(newData);

  //     // try {
  //     //   await _firestore.collection('booking').doc(document.id).update({

  //     //   });
  //     // } catch (e) {
  //     //   print(e);
  //     // }
  //   }
  //   print('All documents updated successfully');
  // }

  Future<void> deleteGalleryImageAtIndex({required int index}) async {
    final CollectionReference collection = _firestore.collection('provider');
    final DocumentReference docRef = collection.doc(userID);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          List<dynamic> galleryList = docSnapshot['gallery'];
          galleryList.removeAt(index); // Remove the item at the specified index
          transaction.update(docRef, {'gallery': galleryList});
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      toastMessage(message: 'Error deleting this item', colors: kRedColor);
    }
  }

  Future<void> deleteGalleryVideoAtIndex({required int index}) async {
    final CollectionReference collection = _firestore.collection('provider');
    final DocumentReference docRef = collection.doc(userID);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          List<dynamic> galleryList = docSnapshot['galleryVideos'];
          galleryList.removeAt(index); // Remove the item at the specified index
          transaction.update(docRef, {'galleryVideos': galleryList});
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      toastMessage(message: 'Error deleting this item', colors: kRedColor);
    }
  }

  Future<void> deleteAddOnAtIndex(
      {required int index, required String serviceID}) async {
    final CollectionReference collection = _firestore.collection('service');
    final DocumentReference docRef = collection.doc(serviceID);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          List<dynamic> addOnList = docSnapshot['addon'];
          addOnList.removeAt(index); // Remove the item at the specified index
          transaction.update(docRef, {'addon': addOnList});
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      toastMessage(message: 'Error deleting this item', colors: kRedColor);
    }
  }

  Future<void> deleteTestimonialAtIndex({required int index}) async {
    final CollectionReference collection = _firestore.collection('provider');
    final DocumentReference docRef = collection.doc(userID);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          List<dynamic> testimonialList = docSnapshot['testimonial'];
          testimonialList
              .removeAt(index); // Remove the item at the specified index
          transaction.update(docRef, {'testimonial': testimonialList});
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      toastMessage(message: 'Error deleting this item', colors: kRedColor);
    }
  }

  Future<void> deleteEventPriceAtIndex(
      {required int index, required String serviceID}) async {
    final CollectionReference collection = _firestore.collection('service');
    final DocumentReference docRef = collection.doc(serviceID);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          List<dynamic> eventPriceList = docSnapshot['eventPrice'];
          eventPriceList
              .removeAt(index); // Remove the item at the specified index
          transaction.update(docRef, {'eventPrice': eventPriceList});
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      toastMessage(message: 'Error deleting this item', colors: kRedColor);
    }
  }
}
