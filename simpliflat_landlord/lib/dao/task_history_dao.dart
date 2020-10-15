import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class TaskHistoryDao {
  static Future<bool> add(String ownerTenantFlatId, String taskId, Map<String, dynamic> data) async {
    return Firestore.instance
                                        .collection(globals.ownerTenantFlat)
                                        .document(ownerTenantFlatId)
                                        .collection(globals.tasksLandlord)
                                        .document(taskId)
                                        .collection(globals.taskHistory)
                                        .add(data).then((ret) {return true;}).catchError((e) {return false;});
  }
}