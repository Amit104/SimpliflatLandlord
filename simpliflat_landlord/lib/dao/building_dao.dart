import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class BuildingDao {
  static Future<Building> getById(String buildingId) async {
    DocumentSnapshot buildingDs = await Firestore.instance.collection(globals.building).document(buildingId).get();
    return Building.fromJson(buildingDs.data, buildingDs.documentID);
  }

  static Stream<QuerySnapshot> getAll() {
    return Firestore.instance.collection(globals.building).snapshots();
  }

  static Future<DocumentReference> insert(Building building) async {
    return await Firestore.instance.collection(globals.building).add(building.toJson());
  }

  static void setForBatch(Building building, WriteBatch wb) {
    DocumentReference ds = Firestore.instance.collection(globals.building).document();
    wb.setData(ds, building.toJson());
  }
}