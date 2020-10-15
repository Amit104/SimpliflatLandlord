import 'package:flutter/foundation.dart';

class LoadingModel extends ChangeNotifier {
  bool load = false;

  void startLoading() {
    this.load = true;
    notifyListeners();
  }

  void stopLoading() {
    this.load = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}