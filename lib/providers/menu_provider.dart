import 'package:flutter/material.dart';

class MenuProvider with ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;



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
