import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';

class CameraResultScreen extends StatefulWidget {
  static const routeName = "/camera-result";

  @override
  _CameraResultScreenState createState() => _CameraResultScreenState();
}

class _CameraResultScreenState extends State<CameraResultScreen> {
  VideoPlayerController videoPlayerController;
  Map<String, dynamic> image;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    image = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

    if (!(image['isImage'] as bool)) {
      XFile file = image['file'];
      videoPlayerController = VideoPlayerController.file(File(file.path));
      videoPlayerController.initialize().then((_) {
        setState(() {});
      });
      videoPlayerController.setLooping(true);
      videoPlayerController.play();
    }
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            image['isImage']
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image(
                      image: AssetImage(image['file'].path),
                      fit: BoxFit.cover,
                    ),
                  )
                : (videoPlayerController.value.initialized)
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: VideoPlayer(videoPlayerController),
                      )
                    : Container(),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  if (image['isImage']) {
                    GallerySaver.saveImage(image['file'].path).then((value) =>
                        print("file is Saved at ${image['file'].path}"));
                  } else {
                    GallerySaver.saveVideo(image['file'].path).then((value) =>
                        print("File is saved at ${image['file'].path}"));
                  }
                },
                child: Container(
                  height: 50,
                  width: 50,
                  margin: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                  child: Icon(
                    Icons.thumb_up_rounded,
                    color: Colors.black,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
