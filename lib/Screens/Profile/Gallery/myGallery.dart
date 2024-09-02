import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khwahish_provider/Components/DialogueBox/deletePopUp.dart';
import 'package:khwahish_provider/Components/buttons.dart';
import 'package:khwahish_provider/Components/util.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/Audio/addAudio.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/Audio/audioPage.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/addGallery.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/addVideoToGallery.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/galleryViewer.dart';
import 'package:khwahish_provider/Screens/Profile/Gallery/videoPlayerScreen.dart';
import 'package:khwahish_provider/Screens/emptyScreen.dart';
import 'package:khwahish_provider/Services/serviceManager.dart';
import 'package:khwahish_provider/Theme/colors.dart';

class MyGallery extends StatefulWidget {
  const MyGallery({super.key});

  @override
  State<MyGallery> createState() => _MyGalleryState();
}

class _MyGalleryState extends State<MyGallery> with SingleTickerProviderStateMixin {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Gallery'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'Photo'),
            Tab(text: 'Video'),
            Tab(text: 'Recording'),
          ],
          onTap: (index){
            setState(() {});
          },
        ),
      ),
      body: NotificationListener(
        onNotification: (scrollNotification){
          if (scrollNotification is ScrollEndNotification) setState(() {});
          return false;
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            StreamBuilder(
              stream: _firestore.collection('provider').doc(ServiceManager.userID).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  var items = snapshot.data;
                  return items!['gallery'].isNotEmpty ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: items['gallery'].length,
                    itemBuilder: (context, index){
                      var gallery = items['gallery'][index];
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => GalleryViewer(
                                  index: index, snapshot: items['gallery'])));
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: kMainColor.withOpacity(0.2),
                                image: DecorationImage(
                                  image: NetworkImage(gallery['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.black.withOpacity(0.2),
                              child: IconButton(
                                onPressed: (){
                                  deletePopUp(context, onClickYes: (){
                                    ServiceManager().deleteGalleryImageAtIndex(index: index);
                                    Navigator.pop(context);
                                  });
                                },
                                icon: Icon(Icons.delete_forever_outlined, color: kWhiteColor,),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ) : EmptyScreen(message: 'No Image uploaded');
                }
                return LoadingIcon();
              }
            ),///images
        
            StreamBuilder(
                stream: _firestore.collection('provider').doc(ServiceManager.userID).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    var items = snapshot.data;
                    return items!['galleryVideos'].isNotEmpty ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      itemCount: items['galleryVideos'].length,
                      itemBuilder: (context, index){
                        var gallery = items['galleryVideos'][index];
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => VideoPlayerScreen(
                                    videoUrl: '${gallery['videoUrl']}',
                                )));
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                
                                  color: kMainColor.withOpacity(0.2),
                                  image: DecorationImage(
                                    image: NetworkImage(gallery['thumbnail'],),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black.withOpacity(0.2),
                                child: IconButton(
                                  onPressed: (){
                                    deletePopUp(context, onClickYes: (){
                                      ServiceManager().deleteGalleryVideoAtIndex(index: index);
                                      Navigator.pop(context);
                                    });
                                  },
                                  icon: Icon(Icons.delete_forever_outlined, color: kWhiteColor,),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ) : EmptyScreen(message: 'No Video uploaded');
                  }
                  return LoadingIcon();
                }
            ),///Videos
        
            AudioPage(),///Links
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _tabController.index == 0 ? KButton(
        title: 'Add Images',
        onClick: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddGallery()));
        },
      ) : _tabController.index == 1 ? KButton(
        title: 'Add Video',
        onClick: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddVideoToGallery()));
        },
      ) : _tabController.index == 2 ? KButton(
        title: 'Add Audio Recording',
        onClick: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddAudio()));
        },
      ) :  null,
    );
  }
}
