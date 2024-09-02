import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khwahish_provider/Components/DialogueBox/videoPickerPopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddReels extends StatefulWidget {
  const AddReels({super.key});

  @override
  State<AddReels> createState() => _AddReelsState();
}

class _AddReelsState extends State<AddReels> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController caption = TextEditingController();

  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();
  File? _video;
  void pickVideoFromGallery() async {
    var pickedImage = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: 240),
    );

    if (pickedImage != null) {
      File videoFile = File(pickedImage.path);
      int videoSize = await videoFile.length();
      print(videoSize.toString());

      if (videoSize <= 35 * 1024 * 1024) {
        setState(() {
          _video = videoFile;
          _generateThumbnail(pickedImage.path);
        });
      } else {
        toastMessage(message: 'Video size exceeds the limit', colors: kRedColor);
      }
    }

    // setState(() {
    //   _video = File(pickedImage!.path);
    //   _generateThumbnail(pickedImage.path);
    // });
  }

  void pickVideoFromCamera() async {
    var pickedImage = await _picker.pickVideo(source: ImageSource.camera);
    if(pickedImage != null){
      setState(() {
        _video = File(pickedImage.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // pickVideoFromGallery();
    caption.addListener(_formatText);
  }

  Uint8List _thumbnail = Uint8List(0);
  Future<void> _generateThumbnail(String path) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // Adjust as needed
      quality: 25, // Adjust as needed
    );

    setState(() {
      _thumbnail = thumbnail!;
    });
  }

  void pickVideo(){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return VideoPickerPopUp(
          onCameraClick: (){
            Navigator.pop(context);
            pickVideoFromCamera();
          },
          onGalleryClick: (){
            Navigator.pop(context);
            pickVideoFromGallery();
          },
        );
      },
    );
  }

  ///form hashtag
  List<String> _allHashtags = ['#fun', '#summer', '#travel', '#adventure', '#flutter', '#coding'];
  List<String> _filteredHashtags = [];
  void _formatText() {
    String text = caption.text;
    List<String> words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      if (words[i].startsWith('#')) {
        words[i] = '#${words[i].substring(1)}';  // Ensures hashtags start with '#'
      }
    }

    String formattedText = words.join(' ');
    if (formattedText != text) {
      caption.value = caption.value.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
  }

  void _addHashtag(String hashtag) {
    List<String> words = caption.text.split(' ');
    words[words.length - 1] = hashtag;
    setState(() {
      caption.text = words.join(' ') + ' ';
      caption.selection = TextSelection.fromPosition(TextPosition(offset: caption.text.length));
      _filteredHashtags = [];
    });
  }

  @override
  void dispose() {
    caption.removeListener(_formatText);
    caption.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Reel'),
        bottom: isLoading ? PreferredSize(
          preferredSize: Size.fromHeight(4.0), // Set the height of the progress indicator
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ) : null,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _thumbnail.isNotEmpty ? Image.memory(_thumbnail)
                  : SizedBox.shrink(),
              kSpace(),
              KButton(
                title:  _thumbnail.isNotEmpty ? 'Change Video' : 'Upload Gallery Video',
                onClick: (){
                  pickVideoFromGallery();
                },
              ),
              Text('The video must be less than 35 MB', style: k10Text().copyWith(
                color: kRedColor,
              )),
              kSpace(),
              KTextField(title: 'Write a Caption', controller: caption,),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoading != true ? KButton(
        title: 'Save',
        onClick: (){
          if(_formKey.currentState!.validate()){
            if(_video != null){
              setState(() {
                isLoading = true;
              });
              addVideoToReel(context);
            } else {
              toastMessage(message: 'Upload Video');
            }
          }
        },
      ) : LoadingButton(),
    );
  }

  void addVideoToReel(context) async {
    print("cccdc9090");
    String videoPath = await ServiceManager().uploadVideo(_video!.path, 'reels');
    print("ccsdssdcdc");
    String thumbnailPath = await ServiceManager().uploadThumbnail(_thumbnail);
    print("cccdc");
    try {
      _firestore.collection('reels').add({
        'albumImg': 'https://firebasestorage.googleapis.com/v0/b/talaash-399c8.appspot.com/o/util%2Falbum.jpeg?alt=media&token=96d5b3da-3590-4014-87c2-6d5495c7ef0e',
        'caption': caption.text,
        'comments': '0',
        'likedBy': [],
        'likes': '0',
        'name': ServiceManager.userName,
        'profileImg': ServiceManager.profileURL,
        'shares': '0',
        'songName': 'Original Sound',
        'thumbnail': thumbnailPath,
        'time': DateTime.now(),
        'userID': ServiceManager.userID,
        'videoUrl': videoPath,
        'offReels':false,
        'reportBy':[]
      });
      Navigator.pop(context);
      toastMessage(message: 'Reel Uploaded');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toastMessage(message: 'Something went wrong');
    }
  }
}
