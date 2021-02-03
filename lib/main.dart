import 'package:VideoFeature/Screens/camera_result.dart';
import 'package:VideoFeature/Screens/home.dart';
import 'package:VideoFeature/provider/cameras.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:VideoFeature/Screens/camera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => Cameras())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
        routes: {
          Camera.routeName: (context) => Camera(),
          CameraResultScreen.routeName: (context) => CameraResultScreen()
        },
      ),
    );
  }
}
