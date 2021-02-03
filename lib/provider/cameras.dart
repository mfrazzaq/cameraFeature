import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class Cameras with ChangeNotifier {
  List<CameraDescription> _cameras = [];

  Future<List<CameraDescription>> setAvailableCameras() async {
    _cameras = await availableCameras();
    notifyListeners();
    return [..._cameras];
  }

  List<CameraDescription> get cameras {
    return [..._cameras];
  }

  bool get isEmpty {
    return _cameras.length > 0 ? false : true;
  }
}
