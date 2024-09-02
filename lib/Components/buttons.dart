import 'package:flutter/material.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';

class KButton extends StatelessWidget {

  String title;
  Function() onClick;
  Color? color;
  KButton({Key? key, required this.title, required this.onClick, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 40,
      minWidth: MediaQuery.of(context).size.width*0.92,
      shape: materialButtonDesign(),
      color: color ?? kButtonColor,
      textColor: kBTextColor,
      onPressed: onClick,
      child: Text(title, style: k14Style(),),
    );
  }
}

class K2Button extends StatelessWidget {

  String title;
  Function() onClick;
  Color? color;
  K2Button({Key? key, required this.title, required this.onClick, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        side: MaterialStateProperty.all(BorderSide(color: color ?? kRedColor)),
        foregroundColor: MaterialStateProperty.all(color ?? kRedColor),
      ),
      onPressed: onClick,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
        ],
      ),
    );
  }
}

class LoadingButton extends StatelessWidget {

  Color? color;
  LoadingButton({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 40,
      minWidth: MediaQuery.of(context).size.width*0.92,
      shape: materialButtonDesign(),
      color: color ?? kButtonColor,
      textColor: kBTextColor,
      onPressed: (){},
      child: CircularProgressIndicator(
        color: kWhiteColor,
      ),
    );
  }
}

class LoginButton extends StatelessWidget {

  String title, image;
  Function() onClick;
  LoginButton({required this.title, required this.image, required this.onClick,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 45,
      color: kMainColor,
      textColor: kWhiteColor,
      shape: materialButtonDesign(),
      minWidth: MediaQuery.of(context).size.width*0.92,
      onPressed: onClick,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          SizedBox(width: 10.0),
          Image.asset(image, height: 25),
        ],
      ),
    );
  }
}

Widget profileButton(IconData iconData, String title, Function() onClicked) {
  return ListTile(
    dense: true,
    leading: Icon(iconData, color: kMainColor),
    title: Text(title, style: TextStyle(fontFamily: 'Roboto', fontSize: 14),),
    trailing: Icon(Icons.chevron_right_outlined),
    onTap: onClicked,
  );
}

class BorderButton extends StatelessWidget {

  String title;
  Function() onClick;
  BorderButton({super.key, required this.title, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(width: 1,
          color: Theme.of(context).brightness != Brightness.dark ? Colors.black : Colors.white,
        ),
      ),
      child: MaterialButton(
        minWidth: 70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        onPressed: onClick,
        child: Text(title),
      ),
    );
  }
}
