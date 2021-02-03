import 'package:VideoFeature/Screens/camera.dart';
import 'package:VideoFeature/Widgets/Download/download.dart';
import 'package:VideoFeature/Widgets/Files/file.dart';
import 'package:VideoFeature/Widgets/Home/home/home.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Widget getScreen(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return Home();
      case 1:
        Navigator.of(context).pushNamed(Camera.routeName);
        break;
      case 2:
        return Download();
      case 3:
        return File();
      default:
        return Container(
          child: Text('Nothing to show'),
        );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: getScreen(context),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.yellow,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.redAccent,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.download_rounded),
              label: 'Download',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.file_present),
              label: 'Files',
            ),
          ],
          onTap: (index) {
            if (index != 1) {
              setState(() {
                _currentIndex = index;
              });
            } else {
              Navigator.of(context).pushNamed(Camera.routeName);
            }
          },
        ),
      ),
    );
  }
}
