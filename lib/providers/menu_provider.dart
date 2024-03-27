import 'package:flutter/material.dart';
import 'package:jetpack/views/home/home.dart';
import 'package:jetpack/views/profile/profile.dart';
import 'package:jetpack/views/widgets/default_screen.dart';

class MenuProvider with ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;

  List<Map<String, dynamic>> screens = [
    {'title': "", "icon": Icons.home, 'screen': const HomeScreen()},
    {
      'title': "Tasks",
      "icon": Icons.search,
      'screen': const DefaultScreen(
        title: '',
        appbar: false,
      )
    },
    {
      'title': "Notifications",
      "icon": Icons.search,
      'screen': const DefaultScreen(
        title: '',
        appbar: false,
      )
    },
    {
      'title': "Profile",
      "icon": Icons.search,
      'screen': const DefaultScreen(
        title: '',
        appbar: false,
      )
    },
  ];

  void updateCurrentPage(int index) {
    if (index != currentPage) {
      _currentPage = index;
      notifyListeners();
    }
  }

  void init() {
    _currentPage = 0;
  }
}
