import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryViewer extends StatefulWidget {

  int index;
  List snapshot;
  GalleryViewer({Key? key, required this.index, required this.snapshot}) : super(key: key);

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    var items = widget.snapshot;
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            Navigator.pop(context);
          }
        },
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              // minScale: 0.48,
              imageProvider: NetworkImage('${items[index]['image']}'),
              initialScale: PhotoViewComputedScale.contained * 1,
              heroAttributes: PhotoViewHeroAttributes(tag: '${items[index]['image']}'),
            );
          },
          itemCount: widget.snapshot.length,
          loadingBuilder: (context, event) => Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(),
            ),
          ),
          pageController: pageController,
        ),
      ),
    );
  }
}

class ProductGallery extends StatefulWidget {

  int index;
  List snapshot;
  ProductGallery({super.key, required this.index, required this.snapshot});

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    var items = widget.snapshot;
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            Navigator.pop(context);
          }
        },
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              // minScale: 0.48,
              imageProvider: NetworkImage('${items[index]}'),
              initialScale: PhotoViewComputedScale.contained * 1,
              heroAttributes: PhotoViewHeroAttributes(tag: '${items[index]}'),
            );
          },
          itemCount: widget.snapshot.length,
          loadingBuilder: (context, event) => Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(),
            ),
          ),
          pageController: pageController,
        ),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {

  String imageURL;
  ImageViewer({Key? key, required this.imageURL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 0) {
          Navigator.pop(context);
        }
      },
      child: Stack(
        children: [
          Center(child: Image.network(imageURL)),
          Positioned(
            top: 30.0,
            left: 10.0,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.highlight_off_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
