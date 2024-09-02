import 'package:flutter/material.dart';
import 'package:khwahish_provider/Theme/style.dart';

Future<String?> cancelPopUp(BuildContext context, {required Function() onClickYes}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      title: Text('Cancel?', style: kHeaderStyle()),
      content: Text('Are you sure you want to cancel this order?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onClickYes,
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}