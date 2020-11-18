import 'package:flutter/foundation.dart';

class DashboardEmptyCheckModel extends ChangeNotifier {
  bool noticesExist = false;
  bool tasksExist = false;

  void noticesChange(noticesExist) {
    this.noticesExist = noticesExist;
    notifyListeners();
  }

  void tasksChange(taskExists) {
    this.tasksExist = taskExists;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}