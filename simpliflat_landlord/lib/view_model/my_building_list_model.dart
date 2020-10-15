import 'package:simpliflat_landlord/model/owner_flat.dart';

class MyBuildingListModel {
  Map<String, List<OwnerFlat>> ownedFlatIds = new Map();

  Map<String, List<OwnerFlat>> getOwnedFlatIds() {
    return ownedFlatIds;
  }
}