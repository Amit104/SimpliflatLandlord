import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class TenantFlatDao {
  static Future<QuerySnapshot> getByDisplayId(String displayId) async {
    return Firestore.instance.collection(globals.flat).where('display_id', isEqualTo: displayId).getDocuments();
  }
}