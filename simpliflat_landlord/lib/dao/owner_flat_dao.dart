import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class OwnerFlatDao {

  static Future<QuerySnapshot> getByOwnerId(String ownerId) async {
    return await Firestore.instance.collection(globals.ownerFlat).where('ownerIdList', arrayContains: ownerId).getDocuments();
  }

  static Future<QuerySnapshot> getAllVerifiedFlatsOfBuilding(String buildingId) async {
    return Firestore.instance.collection(globals.ownerFlat).where('buildingId', isEqualTo: buildingId)
    .where('verified', isEqualTo: false).getDocuments();
  }

  static DocumentReference getDocumentReference(String documentId) {
    return Firestore.instance.collection(globals.ownerFlat).document(documentId);
  }

  static Future<QuerySnapshot> getAnOwnerFlatForUser(String userId) async {
    return Firestore.instance.collection(globals.ownerFlat).where('ownerIdList', arrayContains: userId).limit(1).getDocuments();
  }

  static Future<DocumentSnapshot> getDocument(String documentId) async {
    return Firestore.instance.collection(globals.ownerFlat).document(documentId).get();
  }
  
}