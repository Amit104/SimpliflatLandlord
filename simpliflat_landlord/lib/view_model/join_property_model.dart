import 'package:flutter/foundation.dart';

class JoinPropertyModel extends ChangeNotifier {
  Map<String, bool> blocksExpanded = new Map();

  bool buildingExpanded = true;


  void expandBlock(String blockName) {
    blocksExpanded[blockName] = blocksExpanded[blockName] == null? true: !blocksExpanded[blockName];
    notifyListeners();
  }

  bool isBlockExpanded(String blockName) {
    return blocksExpanded[blockName] == null? false: blocksExpanded[blockName];
  }

  void expandBuilding() {
    buildingExpanded = !buildingExpanded;
    notifyListeners();
  }

  bool isBuildingExpanded() {
    return buildingExpanded;
  }

  @override
  void dispose() {
    super.dispose();
  }

  
}