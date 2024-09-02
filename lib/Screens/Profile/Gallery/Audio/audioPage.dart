import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/DialogueBox/deletePopUp.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/style.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String playingIndex = '';

  @override
  void initState() {
    super.initState();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _firestore.collection('provider').doc(ServiceManager.userID).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            var items = snapshot.data;
            return items!['audioGallery'].isNotEmpty ? ListView.separated(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              itemCount: items['audioGallery'].length,
              itemBuilder: (context, index){
                return GestureDetector(
                  onTap: () async {
                    if(isPlaying){
                      await audioPlayer.pause();
                    } else {
                      await audioPlayer.play(UrlSource('${items['audioGallery'][index]}'));
                    }
                    playingIndex = '$index';
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    decoration: roundedContainerDesign(context),
                    child: Row(
                      children: [
                        Icon((isPlaying &&  playingIndex == '$index') ? Icons.pause : Icons.play_arrow),
                        Expanded(
                          child: Text('${items['audioGallery'][index]}',
                            overflow: TextOverflow.ellipsis, maxLines: 1,
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            deletePopUp(context, onClickYes: (){
                              deleteAudioAtIndex(index: index);
                              Navigator.pop(context);
                            });
                          },
                          icon: Icon(Icons.delete_forever_outlined),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 10);
              },
            ) : EmptyScreen(message: 'No Audio Found');
          }
          return LoadingIcon();
        }
      ),
    );
  }

  Future<void> deleteAudioAtIndex({required int index}) async {
    final CollectionReference collection = _firestore.collection('provider');
    final DocumentReference docRef = collection.doc(ServiceManager.userID);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          List<dynamic> linkList = docSnapshot['audioGallery'];
          linkList.removeAt(index); // Remove the item at the specified index
          transaction.update(docRef, {'audioGallery': linkList});
        } else {
          print('Document does not exist');
        }
      });
    } catch (e) {
      toastMessage(message: 'Error deleting this item');
    }
  }
}
