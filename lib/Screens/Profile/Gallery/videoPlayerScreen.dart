import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {

  String videoUrl;
  VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  YoutubePlayerController _controller = YoutubePlayerController(initialVideoId: '');
  late FlickManager flickManager;
  late VideoPlayerController _videoController;
  bool isShowPlaying = false;
  int sourceType = 1;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);

    filterUrl(widget.videoUrl);
  }

  void filterUrl(String videoPath) {
    if (videoPath.toLowerCase().contains("https://www.youtube.com/watch?v=")) {
      videoPath = videoPath.replaceAll('https://www.youtube.com/watch?v=', '');
      setState(() {
        sourceType = 1;
      });
      initializeVideo(videoPath);
    } else if (videoPath.toLowerCase().contains("https://youtu.be/")) {
      videoPath = videoPath.replaceAll("https://youtu.be/", "");
      setState(() {
        sourceType = 1;
      });
      initializeVideo(videoPath);
    } else {
      setState(() {
        sourceType = 2;
      });
      flickManager = FlickManager(
        videoPlayerController:
        VideoPlayerController.network(widget.videoUrl),
      );
    }
    // initializeVideo(videoPath);
  }

  void initializeVideo(String videoPath){
    _controller = YoutubePlayerController(
      initialVideoId: videoPath,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller.dispose();
    flickManager.dispose();
    _videoController.dispose();
  }
  Widget isPlaying(){
    return _videoController.value.isPlaying && !isShowPlaying  ? Container() : Icon(Icons.play_arrow,size: 80,color: Colors.white.withOpacity(0.5),);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: sourceType == 1 ? playYoutubeVideo() :
          sourceType == 2 ? videoPlayer() :
          Text('Video Not Supported'),
        ),
      ),
    );
    // return VideoPlayer(_videoController);
  }

  YoutubePlayer playYoutubeVideo() {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
    );
  }

  FlickVideoPlayer videoPlayer() {
    return FlickVideoPlayer(
      // preferredDeviceOrientation: const [
      //   DeviceOrientation.landscapeRight,
      //   DeviceOrientation.landscapeLeft,
      // ],
      flickManager: flickManager,
    );
  }
}
