import 'package:VideoFeature/Screens/camera_result.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:VideoFeature/provider/cameras.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as pp;

class Camera extends StatefulWidget {
  static const String routeName = "/Camera";
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  bool _doneGettingCamera = false;
  CameraController controller;
  XFile imageFile;
  List<CameraDescription> cameras;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _maxAvailableZoom;
  double _minAvailableZoom;
  int isFrontCamera = 0;
  double _baseScale = 1.0;
  double _currentScale = 1.0;
  bool _makePicture = true;

  //Counting pointers (Number of user fingers)
  int _pointers = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration.zero, () async {
      cameras = await Provider.of<Cameras>(context, listen: false)
          .setAvailableCameras();
      controller = CameraController(
        cameras[isFrontCamera],
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        } else {
          setState(() {
            _doneGettingCamera = true;
          });
          getCameraExposureAndZoom();
        }
      });
    });
  }

  //Take a pictures with the following two methods
  void onTakePicturePressed(BuildContext context) {
    pp.getApplicationDocumentsDirectory().then((value) {
      takePicture().then((file) {
        if (mounted) {
          setState(() {
            imageFile = file;
          });
          if (file != null) {
            Navigator.of(context).pushNamed(CameraResultScreen.routeName,
                arguments: {'file': imageFile, 'isImage': true});
          }
        }
      });
    });
  }

  Future<XFile> takePicture() async {
    if (!controller.value.isInitialized) {
      print("Controller value is not initialized");
      return null;
    }
    if (controller.value.isTakingPicture) {
      print("Controller is already taking the picture");
      return null;
    }
    try {
      XFile file = await controller.takePicture();
      return file;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Get icons according to selected camera front/back/external
  IconData getCameraLensIcon(CameraLensDirection cameraLensDirection) {
    if (cameraLensDirection == CameraLensDirection.back) {
      return Icons.camera_front;
    } else if (cameraLensDirection == CameraLensDirection.front) {
      return Icons.camera_rear;
    } else if (cameraLensDirection == CameraLensDirection.external) {
      return Icons.camera;
    } else {
      throw ArgumentError("Unknown lens direction");
    }
  }

  //Change camera direction with the following method
  void changeCameraDirection(int i) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameras[i], ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg);
    try {
      controller.initialize().then((value) {
        if (!mounted) {
          return;
        } else {
          setState(() {
            _doneGettingCamera = true;
            if (isFrontCamera == 0) {
              isFrontCamera = 1;
            } else {
              isFrontCamera = 0;
            }
          });
          getCameraExposureAndZoom();
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //Getting initial zoom and exposure levels
  Future<void> getCameraExposureAndZoom() async {
    await Future.wait([
      controller
          .getMinExposureOffset()
          .then((value) => _minAvailableExposureOffset = value),
      controller
          .getMaxExposureOffset()
          .then((value) => _maxAvailableExposureOffset = value),
      controller.getMinZoomLevel().then((value) => _minAvailableZoom = value),
      controller.getMaxZoomLevel().then((value) => _maxAvailableZoom = value)
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  //For zooming in and out
  void _handleScaleStart(ScaleStartDetails details) {
    _currentScale = _baseScale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);
    print("HandleScaleUpdate" + details.scale.toString());
    await controller.setZoomLevel(_currentScale);
  }

  //Video recording

  void onVideoButtonPressed() {
    startVideoRecording().then((value) {
      if (mounted) {
        setState(() {
          print('State set');
        });
      }
    });
  }

  void onStopVideoRecording() {
    stopVideoRecording().then((value) {
      if (mounted) setState(() {});
      imageFile = value;
      if (imageFile != null) {
        Navigator.of(context).pushNamed(CameraResultScreen.routeName,
            arguments: {'file': imageFile, 'isImage': false});
      }
    });
  }

  Future<void> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      return;
    }
    if (controller.value.isRecordingVideo) {
      return;
    }
    try {
      await controller.startVideoRecording();
    } on CameraException catch (e) {
      print("Camera Exception: ${e.toString()}");
    } catch (e) {
      print('Not a Camera Exeption ${e.toString()}');
    }
  }

  //Stop video Recording
  Future<XFile> stopVideoRecording() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    if (!controller.value.isRecordingVideo) {
      return null;
    }
    try {
      return controller.stopVideoRecording();
    } on CameraException catch (e) {
      print("Camera Exception: ${e.toString()}");
    } catch (e) {
      print("Not a camera exception: ${e.toString()}");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // final mediaQuery = MediaQuery.of(context);
    return SafeArea(
      child: Scaffold(
        body: !_doneGettingCamera
            ? Center(
                child: Container(
                  child: Text("Please wait"),
                ),
              )
            : Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Listener(
                      onPointerUp: (_) => _pointers--,
                      onPointerDown: (_) => _pointers++,
                      child: CameraPreview(
                        controller,
                        child: LayoutBuilder(
                          builder: (context, constraints) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onScaleStart: _handleScaleStart,
                            onScaleUpdate: _handleScaleUpdate,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () =>
                          controller != null && controller.value.isInitialized
                              ? (_makePicture)
                                  ? onTakePicturePressed(context)
                                  : (!controller.value.isRecordingVideo)
                                      ? onVideoButtonPressed()
                                      : onStopVideoRecording()
                              : null,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: Icon(
                          _makePicture
                              ? Icons.camera
                              : controller.value.isRecordingVideo
                                  ? Icons.videocam_outlined
                                  : Icons.videocam,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _makePicture = !_makePicture;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 10,
                        ),
                        child: Icon(
                          _makePicture ? Icons.videocam : Icons.camera,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () =>
                          changeCameraDirection(isFrontCamera == 0 ? 1 : 0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 10,
                        ),
                        child: Icon(
                          getCameraLensIcon(
                              cameras[isFrontCamera].lensDirection),
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
