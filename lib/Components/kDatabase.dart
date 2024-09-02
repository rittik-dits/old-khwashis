
import 'package:googleapis/dfareporting/v4.dart';

List<String> priceUnitList = [
  'Hourly', 'Fixed'
];

class Week {
  String weekName, fromTime, toTime;
  Week({required this.weekName, required this.fromTime, required this.toTime});
}

List<Week> weekDays = [
  Week(weekName: 'Monday', fromTime: '9:00', toTime: '4:00'),
  Week(weekName: 'Tuesday', fromTime: '9:00', toTime: '4:00'),
  Week(weekName: 'Wednesday', fromTime: '9:00', toTime: '4:00'),
  Week(weekName: 'Thursday', fromTime: '9:00', toTime: '4:00'),
  Week(weekName: 'Friday', fromTime: '9:00', toTime: '4:00'),
  Week(weekName: 'Saturday', fromTime: '9:00', toTime: '4:00'),
  Week(weekName: 'Sunday', fromTime: '9:00', toTime: '4:00'),
];

class WorkTime {
  String fromTime, toTime;
  WorkTime({required this.fromTime, required this.toTime});
}

class Name {
  String code, text;
  Name({
    required this.code,
    required this.text,
  });
}

class ImageField {
  String localFile, serverPath;
  ImageField({
    required this.localFile,
    required this.serverPath,
  });
}

class Price {
  int discPrice;
  Map<dynamic, String> image;
  List<Name> name;
  int price;
  String priceUnit;
  bool selected;
  int stock;
  Price({
    required this.discPrice,
    required this.image,
    required this.name,
    required this.price,
    required this.priceUnit,
    required this.selected,
    required this.stock,
  });
}

List<String> genderList = [
  'Male',
  'Female',
  'Other',
  'Prefer not to specify',
];

class AddOn {
  String name;
  int interCityPrice;
  int interStatePrice;
  int outsideStatePrice;
  // int internationalPrice;
  AddOn({
    required this.name,
    required this.interCityPrice,
    required this.interStatePrice,
    required this.outsideStatePrice,
    // required this.internationalPrice,
  });
}

List<AddOn> addOnList = [
  AddOn(name: 'Hands', interCityPrice: 0, interStatePrice: 0,
      outsideStatePrice: 0),
  AddOn(name: 'Sound And Transport', interCityPrice: 0, interStatePrice: 0,
      outsideStatePrice: 0),
];
