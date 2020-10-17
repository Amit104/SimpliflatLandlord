import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class TenantDao {
  static Future<QuerySnapshot> getTenantsUsingTenantFlatId(String tenantFlatId) async {
    return Firestore.instance.collection(globals.user).where('flat_id', isEqualTo: tenantFlatId).getDocuments();
  }
}