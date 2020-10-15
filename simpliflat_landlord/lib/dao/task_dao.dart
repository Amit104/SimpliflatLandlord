import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class TaskDao {
  static Stream<DocumentSnapshot> getTask(String ownerTenantFlatId, String taskId) {
    return Firestore.instance
                          .collection(globals.ownerTenantFlat)
                          .document(ownerTenantFlatId)
                          .collection(globals.tasksLandlord)
                          .document(taskId)
                          .snapshots();
  }

  static Future<bool> delete(String ownerTenantFlatId, String taskId) async {
    return Firestore.instance
      .collection(globals.ownerTenantFlat)
      .document(ownerTenantFlatId)
      .collection(globals.tasksLandlord)
      .document(taskId)
      .delete().then((ret) {return true;}).catchError((e) {return false;});
  }

  static Stream<QuerySnapshot> getAllByFlat(String ownerTenantFlatId, bool isCompleted) {
    return Firestore.instance
                  .collection(globals.ownerTenantFlat)
                  .document(ownerTenantFlatId)
                  .collection(globals.tasksLandlord)
                  .where("completed", isEqualTo: isCompleted)
                  .snapshots();
  }

  static Future<bool> update(String ownerTenantFlatId, String taskId, Map<String, dynamic> data) async {
    return Firestore.instance
                                        .collection(globals.ownerTenantFlat)
                                        .document(ownerTenantFlatId)
                                        .collection(globals.tasksLandlord)
                                        .document(taskId)
                                        .updateData(data).then((ret) {return true;}).catchError((e) {return false;});
  }
}