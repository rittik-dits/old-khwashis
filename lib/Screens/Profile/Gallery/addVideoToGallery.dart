import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/textField.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AddVideoToGallery extends StatefulWidget {
  const AddVideoToGallery({super.key});

  @override
  State<AddVideoToGallery> createState() => _AddVideoToGalleryState();
}

class _AddVideoToGalleryState extends State<AddVideoToGallery> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _urlController = TextEditingController();
  String _videoUrl = '';
  String _thumbnailUrl = '';
  Future<void> _fetchVideoInfo() async {
  RegExp regExp = RegExp(
      r"(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})");

  Match? match = regExp.firstMatch(_urlController.text);

  if (match != null && match.groupCount > 0) {
    String? videoId = match.group(1);

    var yt = YoutubeExplode();
    var video = await yt.videos.get(videoId!);

    setState(() {
      _videoUrl = 'https://www.youtube.com/watch?v=${video.id}';
      // _thumbnailUrl = "https://i.gadgets360cdn.com/large/youtube_logo_small_1500034605558.jpg";
      //https://thethemefoundry.com/wp-content/themes/ttf-site/images/single-theme/video-thumbnail.png";//
      _thumbnailUrl = 'https://i.ytimg.com/vi/${video.id}/maxresdefault.jpg';
    });

    yt.close();
  } else {
    setState(() {
      _videoUrl = '';
      _thumbnailUrl = '';
    });
    toastMessage(message: 'Invalid YouTube URL', colors: kRedColor);
  }
}


  Future<void> _fetchVideoInfo2() async {
    RegExp regExp = RegExp(
        r"(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})");

    Match match = regExp.firstMatch(_urlController.text) as Match;

    if (match != null && match.groupCount > 0) {
      String? videoId = match.group(1);

      var yt = YoutubeExplode();
      var video = await yt.videos.get(videoId);

      setState(() {
        _videoUrl = 'https://www.youtube.com/watch?v=${video.id}';
        _thumbnailUrl = 'https://i.ytimg.com/vi/${video.id}/maxresdefault.jpg';
      });

      yt.close();
    }
  }

  bool isLoading = false;
  String categoryID = '';
  String categoryValue = '';

  final ImagePicker _picker = ImagePicker();
  File? _video;
  void pickVideoFromGallery() async {
    var pickedImage = await _picker.pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      File videoFile = File(pickedImage.path);
      int videoSize = await videoFile.length();

      if (videoSize <= 35 * 1024 * 1024) {
        setState(() {
          _video = videoFile;
          _generateThumbnail(pickedImage.path);
        });
      } else {
        toastMessage(message: 'Video size exceeds the limit', colors: kRedColor);
      }
    }
    // if(pickedImage != null){
    //   setState(() {
    //     _video = File(pickedImage.path);
    //     _generateThumbnail(pickedImage.path);
    //   });
    // }
  }

  // void pickVideoFromCamera() async {
  //   var pickedImage = await _picker.pickVideo(source: ImageSource.camera);
  //   if(pickedImage != null){
  //     setState(() {
  //       _video = File(pickedImage.path);
  //       // _generateThumbnail(pickedImage.path);
  //     });
  //   }
  // }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Video'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                StreamBuilder(
                    stream: _firestore.collection('category').orderBy('name').snapshots(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        List categoryList = [];
                        var mainCategory = snapshot.data!.docs;
                        for(var category in mainCategory){
                          categoryList.add(category);
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 5.0, left: 10.0),
                              child: Text('Select Category',
                                  style: kSmallText().copyWith(
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                              child: Container(
                                height: 45,
                                width: MediaQuery.of(context).size.width,
                                decoration: dropTextFieldDesign(context),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    alignedDropdown: true,
                                    child: DropdownButton(
                                      borderRadius: BorderRadius.circular(10.0),
                                      value: categoryValue != '' ? categoryValue : null,
                                      hint: Text('Category', style: hintTextStyle(context)),
                                      items: categoryList
                                          .map<DropdownMenuItem>((value) {
                                        return DropdownMenuItem(
                                          value: value['name'],
                                          child: Text(value['name']),
                                          onTap: (){
                                            setState(() {
                                              categoryID = value.reference.id;
                                            });
                                          },
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          categoryValue = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return Container();
                    }
                ),
                SizedBox(height: 10),
                _thumbnail.isNotEmpty ? Column(
                  children: [
                    Image.memory(_thumbnail),
                  ],
                ) : SizedBox.shrink(),
                KButton(
                  onClick: (){
                    pickVideoFromGallery();
                  },
                  title: _thumbnail.isEmpty ? 'Add Video' : 'Change Video',
                ),
                Text('The video must be less than 35 MB', style: k10Text().copyWith(
                  color: kRedColor,
                )),
              ],
            ),

            ///Youtube URL
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: const [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                ),
                KTextField(
                  controller: _urlController,
                  title: 'Enter YouTube URL',
                  onChanged: (value) async {
                    await _fetchVideoInfo();
                  },
                ),
                SizedBox(height: 16.0),
                KButton(
                  onClick: () async {
                    await _fetchVideoInfo();
                  },
                  title: 'Fetch Thumbnail',
                ),
                SizedBox(height: 16.0),
                if (_thumbnailUrl.isNotEmpty)
                  Image.network(_thumbnailUrl),
                SizedBox(height: 16.0),
                if (_videoUrl.isNotEmpty)
                  Text('YouTube Video URL: $_videoUrl'),
              ],
            ),
            kBottomSpace(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoading != true ? KButton(
        title: 'Save Video',
        onClick: (){
          if(categoryID != ''){
            if(_video != null && _urlController.text == ''){
              setState(() {
                isLoading = true;
              });
              addVideos(context);
            } else if(_urlController.text != '') {
              addYoutubeVideo();
            } else {
              toastMessage(message: 'Upload Video', colors: kRedColor);
            }
          } else {
            toastMessage(message: 'Select category', colors: kRedColor);
          }
        },
      ) : LoadingButton(),
    );
  }

  void addVideos(context) async {
    String videoPath = await ServiceManager().uploadVideo(_video!.path, 'artistGallery');
    String thumbnailPath = await ServiceManager().uploadThumbnail(_thumbnail);

    try {
      _firestore.collection('provider').doc(ServiceManager.userID).update({
        'galleryVideos': FieldValue.arrayUnion([{
          'categoryID': categoryID,
          'thumbnail': thumbnailPath,
          'videoUrl': videoPath,
        }]),
      });
      Navigator.pop(context);
      toastMessage(message: 'Video Added');
    } catch (e) {
      toastMessage(message: 'Please try later', colors: kRedColor);
      setState(() {
        isLoading = false;
      });
    }

  }

  void addYoutubeVideo() async {
    if(_thumbnailUrl != ''){
      String videoPath = _videoUrl;
      String thumbnailPath = _thumbnailUrl;
      _firestore.collection('provider').doc(ServiceManager.userID).update({
        'galleryVideos': FieldValue.arrayUnion([{
          'categoryID': categoryID,
          'thumbnail': thumbnailPath,
          'videoUrl': videoPath,
        }]),
      }).then((value) => {
        Navigator.pop(context),
        toastMessage(message: 'Video Added'),
      });
    } else {
      toastMessage(message: 'Get the video thumbnail', colors: kRedColor);
      setState(() {
        isLoading = false;
      });
    }
  }
}
