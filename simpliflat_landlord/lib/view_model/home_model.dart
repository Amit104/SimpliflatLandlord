import 'package:flutter/foundation.dart';

class HomeModelBuildingList extends ChangeNotifier {
  Map<String, bool> buildingExpanded = new Map();

  Map<String, bool> blocksExpanded = new Map();

  void expandBuilding(String buildingId) {
    buildingExpanded[buildingId] = buildingExpanded[buildingId] == null? true: !buildingExpanded[buildingId];
    notifyListeners();
  }

  void expandBlock(String buildingId, String blockName) {
    String key = buildingId + '-' + blockName;
    blocksExpanded[key] = blocksExpanded[key] == null? true: !blocksExpanded[key];
    notifyListeners();
  }

  bool isBlockExpanded(String buildingId, String blockName) {
    String key = buildingId + '-' + blockName;
    return blocksExpanded[key] == null? false: blocksExpanded[key];
  }

  bool isBuildingExpanded(String buildingId) {
    return buildingExpanded[buildingId] == null? false: buildingExpanded[buildingId];
  }

  @override
  void dispose() {
    super.dispose();
  }
}