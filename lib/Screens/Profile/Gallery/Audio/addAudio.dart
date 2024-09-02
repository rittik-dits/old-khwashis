import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Profile/verifyAccount.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';
import 'package:khwahish_provider/Theme/style.dart';
import 'package:permission_handler/permission_handler.dart';

class AddAudio extends StatefulWidget {
  const AddAudio({super.key});

  @override
  State<AddAudio> createState() => _AddAudioState();
}

class _AddAudioState extends State<AddAudio> {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if(status != PermissionStatus.granted){
      throw 'Microphone Permission not grunted';
    }

    await recorder.openRecorder();

    isRecorderReady = true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    if(!isRecorderReady) return;

    await recorder.startRecorder(toFile: 'audio');
  }

  File? audioFile;
  Future stop() async {
    if(!isRecorderReady) return;

    final path = await recorder.stopRecorder();
    audioFile = File(path!);

    print('Record Audio: $audioFile');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Audio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<RecordingDisposition>(
              stream: recorder.onProgress,
              builder: (context, snapshot){
                final duration = snapshot.hasData
                    ? snapshot.data!.duration
                    : Duration.zero;

                String twoDigits(int n) => n.toString().padLeft(2, '0');
                final twoDigitMinutes =
                    twoDigits(duration.inMinutes.remainder(60));
                final twoDigitSeconds =
                    twoDigits(duration.inSeconds.remainder(60));

                return Text('$twoDigitMinutes:$twoDigitSeconds',
                  style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                );
              },
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () async {
                    if(recorder.isRecording){
                      await stop();
                    } else {
                      await record();
                    }
                    setState(() {});
                  },
                  icon: Icon(recorder.isRecording ? Icons.stop : Icons.mic, size: 60,),
                ),
                Text(recorder.isRecording ? 'Pause' : 'Record'),
              ],
            ),
            kBottomSpace(),
          ],
        ),
      ),
      floatingActionButton: audioFile != null ? isLoading != true ? KButton(
        title: 'Save',
        onClick: (){
          if(audioFile != null){
            setState(() {
              isLoading = true;
            });
            addAudioToDatabase(context);
          } else {
            toastMessage(message: 'Record your audio', colors: kRedColor);
          }
        },
      ) : LoadingButton() : disabledButton(title: 'Record Audio'),
    );
  }

  void addAudioToDatabase(context) async {
    try {
      Uint8List audioBytes = Uint8List.fromList(await audioFile!.readAsBytes());
      String fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      Reference ref = FirebaseStorage.instance.ref().child('audio').child(fileName);
      UploadTask uploadTask = ref.putData(audioBytes);
      await uploadTask;
      String downloadUrl = await ref.getDownloadURL();

      _firestore.collection('provider').doc(ServiceManager.userID).update({
        'audioGallery': FieldValue.arrayUnion([downloadUrl]),
      });
      Navigator.pop(context);
      toastMessage(message: 'Audio Added');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      toastMessage(message: 'Something went wrong', colors: kRedColor);
    }
  }
}
