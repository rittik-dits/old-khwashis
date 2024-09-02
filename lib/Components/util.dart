import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:fluttertoast/fluttertoast.dart';

void toastMessage({required String message, Color? colors}){
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: colors ?? Colors.green,
    textColor: kWhiteColor,
    fontSize: 16.0,
  );
}

Column kIconDesign(context, {required String image, required String title}) {
  return Column(
    children: [
      Expanded(
        child: Container(
          width: MediaQuery.of(context).size.width*0.3,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: k4Color.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: image != '' ? Image.network(image) : SizedBox.shrink(),
        ),
      ),
      SizedBox(height: 5.0),
      Text(title, style: kSmallText(), overflow: TextOverflow.ellipsis),
    ],
  );
}

Color toColor(String? boardColor){
  if (boardColor == null) {
    return Colors.red;
  }
  var t = int.tryParse(boardColor);
  if (t != null) {
    return Color(t);
  }
  return Colors.red;
}

class LoadingIcon extends StatelessWidget {
  const LoadingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    // return Center(child: CircularProgressIndicator());
    return Center(child: Image.asset('images/khwahish_gif.gif'));
  }
}

Expanded k2Design(BuildContext context, {
  required String title,
  required String desc,
}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Container(
        height: 150.0,
        padding: EdgeInsets.all(10.0),
        decoration: roundedContainerDesign(context).copyWith(
          // color: kButtonColor.withOpacity(0.4),
          color:Color.fromARGB(255, 149, 166, 107),// Color.fromARGB(255, 168, 198, 158),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: kLargeStyle(),
              textAlign: TextAlign.center,
            ),
            Text(desc, style: kBoldStyle(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

Row kRating({
  required String title,
  required double kValue,
  required String percent
}) {
  return Row(
    children: [
      Text(title),
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: LinearProgressIndicator(
            value: kValue,
          ),
        ),
      ),
      Text(percent),
    ],
  );
}

Widget dashLines() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Row(
      children: List.generate(300~/5, (index) => Expanded(
        child: Container(
          color: index % 2 != 0? Colors.transparent :Colors.grey,
          height: 1,
        ),
      )),
    ),
  );
}

String kAmount(num amount) {
  NumberFormat indianCurrencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  return indianCurrencyFormat.format(amount) ?? 'NAN';
}
