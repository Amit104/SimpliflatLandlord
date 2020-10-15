import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class OwnerTenantDao {
  static DocumentReference getDocumentReference(String documentId) {
    return Firestore.instance.collection(globals.ownerTenantFlat).document(documentId);
  }

  static Future<QuerySnapshot> getByOwnerFlatId(String ownerFlatId) async {
    return Firestore.instance.collection(globals.ownerTenantFlat)
    .where('status', isEqualTo: 0)
    .where('ownerFlatId', isEqualTo: ownerFlatId)
    .getDocuments();
  }
}