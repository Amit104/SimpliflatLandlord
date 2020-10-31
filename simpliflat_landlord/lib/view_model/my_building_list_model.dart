import 'package:flutter/foundation.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';

class MyBuildingListModel extends ChangeNotifier{
  Map<String, List<OwnerFlat>> ownedFlatIds = new Map();

  Map<String, List<OwnerFlat>> getOwnedFlatIds() {
    return ownedFlatIds;
  }

  void setOwnedFlatIds(Map<String, List<OwnerFlat>> ownedFlats) {
    this.ownedFlatIds = ownedFlats;
  }
}