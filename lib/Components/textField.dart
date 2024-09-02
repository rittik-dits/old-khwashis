import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khwahish_provider/Theme/colors.dart';

class KTextField extends StatelessWidget {

  TextEditingController? controller;
  String title;
  TextInputType? textInputType;
  int? textLimit;
  String? prefixText;
  Widget? suffixButton;
  Function(String)? onChanged;
  bool? obscureText;
  bool? readOnly;
  bool? fillColor;
  Function()? onClick;
  String? Function(String?)? validate;
  KTextField({Key? key,
    required this.title,
    this.controller,
    this.textInputType,
    this.textLimit,
    this.prefixText,
    this.suffixButton,
    this.onChanged,
    this.obscureText,
    this.readOnly,
    this.onClick,
    this.validate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
      child: TextFormField(
        onTap: onClick ?? (){},
        readOnly: readOnly ?? false,
        obscureText: obscureText ?? false,
        keyboardType: textInputType,
        controller: controller,
        inputFormatters: [
          LengthLimitingTextInputFormatter(textLimit),
          if (textInputType == TextInputType.number || textInputType == TextInputType.phone)
            FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChanged,
        style: TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          border: outlineBorderStyle(),
          focusedBorder: focusBorderStyle(),
          enabledBorder: enableBorderStyle(),
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          // filled: fillColor ?? true,
          // fillColor: Theme.of(context).scaffoldBackgroundColor,
          hintText: title,
          hintStyle: hintTextStyle(context),
          labelText: title,
          prefixIcon: textLimit == 10 ?
          Padding(padding: EdgeInsets.only(left: 5, top: 12.0),
              child: Text(' +91 ')) : null,
          suffixIcon: suffixButton,
          prefixText: prefixText ?? '',
          suffixIconColor: Colors.grey,
        ),
        validator: validate ?? (value) {
          if (value == null || value.isEmpty || textLimit == 10 && value.length != 10) {
            return textLimit == 10 ? 'Please enter 10 digit mobile number'
                : 'Please enter some text';
          }
          return null;
        },
      ),
    );
  }
}

TextStyle hintTextStyle(BuildContext context) {
  return TextStyle(
    color: Theme.of(context).scaffoldBackgroundColor != Colors.black ? Colors.black : Colors.white,
    fontWeight: FontWeight.w400,
  );
}

OutlineInputBorder outlineBorderStyle() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
  );
}

OutlineInputBorder focusBorderStyle() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: BorderSide(width: 1, color: Colors.grey),
  );
}

OutlineInputBorder enableBorderStyle() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: BorderSide(width: 0.5, color: Colors.grey.shade400),
  );
}

class SearchTextField extends StatelessWidget {

  TextEditingController? controller;
  Function()? onClear;
  Function(String)? onChanged;
  bool? readOnly;
  Function()? onClick;
  SearchTextField({Key? key,
    this.controller,
    this.onClear,
    this.onChanged,
    this.readOnly,
    this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 1,
            color: kMainColor.withOpacity(0.2),
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onTap: onClick ?? (){},
        controller: controller,
        onChanged: onChanged,
        readOnly: readOnly ?? false,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: kMainColor, size: 30),
          hintText: 'Search',
          hintStyle: TextStyle(color: kMainColor),
          suffixIcon: onClear != null ? IconButton(
            onPressed: onClear,
            icon: Icon(Icons.clear),
          ) : SizedBox.shrink(),
        ),
      ),
    );
  }
}

class MessageTextField extends StatelessWidget {

  String title;
  bool? validate;
  TextEditingController? controller;
  Function(String)? onChanged;
  MessageTextField({Key? key,
    this.controller,
    this.validate,
    required this.title,
    this.onChanged
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
      child: TextField(
        maxLines: 3,
        keyboardType: TextInputType.text,
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: outlineBorderStyle(),
          focusedBorder: focusBorderStyle(),
          labelText: title,
          errorText: validate == true ? 'Fill the required field' : null,
        ),
      ),
    );
  }
}

class SmallTextField extends StatelessWidget {

  String title;
  String label;
  TextEditingController? controller;
  SmallTextField({super.key, required this.title, required this.label, this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title)),
        SizedBox(
          width: MediaQuery.of(context).size.width*0.4,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.end,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: label,
            ),
          ),
        ),
      ],
    );
  }
}
