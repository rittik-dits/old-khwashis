import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/responsive.dart';
import 'package:khwahish_provider/Theme/colors.dart';

TextStyle kHeaderStyle() => TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
TextStyle kWhiteHeaderStyle() => TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
TextStyle kBoldStyle() => TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
TextStyle k12BoldStyle() => TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
TextStyle kSmallText() => TextStyle(fontSize: 12);
TextStyle k10Text() => TextStyle(fontSize: 10);
TextStyle k8Text() => TextStyle(fontSize: 8);
TextStyle k14Style() => TextStyle(fontSize: 14);
TextStyle kLargeStyle() => TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
TextStyle linkTextStyle() => TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 12);
TextStyle kWhiteTextStyle() => TextStyle(color: kWhiteColor);

double kIconSize() => 18.0;
SizedBox kSpace() => SizedBox(height: 15.0);
Divider kDivider() => Divider(thickness: 1);
SizedBox kBottomSpace() => SizedBox(height: 90);

RoundedRectangleBorder materialButtonDesign() {
  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(5));
}

RoundedRectangleBorder bottomSheetRoundedDesign() {
  return RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(15.0),
      )
  );
}

BoxDecoration containerDesign(context) {
  return BoxDecoration(
    color: Theme.of(context).scaffoldBackgroundColor != Colors.black ? Colors.white : kDarkColor,
  );
}

BoxDecoration roundedContainerDesign(context) {
  return BoxDecoration(
    color: Theme.of(context).scaffoldBackgroundColor != Colors.black ? Colors.white : kDarkColor,
    borderRadius: BorderRadius.circular(5.0),
  );
}

BoxDecoration roundedShadedDesign(context) {
  return BoxDecoration(
    color: Theme.of(context).scaffoldBackgroundColor != Colors.black ? Colors.white : kDarkColor,
    borderRadius: BorderRadius.circular(5.0),
    boxShadow: boxShadowDesign(),
  );
}

BoxDecoration blurCurveDecor(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).scaffoldBackgroundColor != Colors.black ?
    Colors.white.withOpacity(0.6) : kDarkColor.withOpacity(0.7),
    borderRadius: BorderRadius.circular(0),
  );
}

List<BoxShadow> boxShadowDesign() {
  return [
    BoxShadow(
      color: kMainColor.withOpacity(0.4),
      spreadRadius: 2.0,
      blurRadius: 2.0,
      offset: Offset(1,2),
    ),
  ];
}

LinearGradient shadedTopGradient() {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: FractionalOffset.bottomCenter,
    stops: const [0.0, 1.0],
    // colors: [Color(0xffA66DD4).withOpacity(0.5), Colors.transparent],
    colors: [kMainColor.withOpacity(0.5), Colors.transparent],
  );
}

LinearGradient kBottomShadedShadow() {
  return LinearGradient(
    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: const [0.0, 1.0],
    tileMode: TileMode.clamp,
  );
}

BoxDecoration dropTextFieldDesign(context) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    // color: Theme.of(context).scaffoldBackgroundColor,
    border: Border.all(width: 0.5, color: Colors.grey),
  );
}

Widget kWhiteRowText(String title, String detail) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
           style: kBoldStyle(),
          ),
          Spacer(),
          Text(detail,
            // style: kWhiteTextStyle(),
          ),
        ],
      ),
    ],
  );
}
EdgeInsets kResponsive(BuildContext context) {
  return EdgeInsets.symmetric(
    horizontal: Responsive.isMobile(context) ? 0 :
    Responsive.isTablet(context) ? 80 : 200,
  );
}

Column kColumnText(context, String title, String desc) {
  return Column(
    children: [
      Text(title, style: kBoldStyle()),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey.withOpacity(0.4),
        ),
        child: Text(desc),
      ),
    ],
  );
}

Row kRowText(String title, String desc){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: kBoldStyle()),
      Expanded(child: Text(desc)),
    ],
  );
}

Row kRowSpaceText(String title, String desc){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: kBoldStyle()),
      SizedBox(width: 10.0),
      Expanded(
        child: Text(desc, style: kSmallText(), textAlign: TextAlign.end),
      ),
    ],
  );
}

BoxDecoration kBackgroundDesign(BuildContext context) {
  return BoxDecoration(
    image: DecorationImage(
      image: AssetImage('images/bg2.png'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Theme.of(context).scaffoldBackgroundColor != Colors.black ?
        Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
        BlendMode.srcATop,
      ),
    ),
  );
}
