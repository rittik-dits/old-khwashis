import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Theme/style.dart';

class VideoPickerPopUp extends StatelessWidget {

  Function() onCameraClick;
  Function() onGalleryClick;
  VideoPickerPopUp({
    required this.onCameraClick,
    required this.onGalleryClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15.0, top: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pick Video'.toUpperCase(), style: kHeaderStyle()),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.cancel),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          KButton(
            title: 'From Camera',
            onClick: onCameraClick,
          ),
          SizedBox(height: 10.0),
          KButton(
            title: 'From Gallery',
            onClick: onGalleryClick,
          ),
        ],
      ),
    );
  }
}
