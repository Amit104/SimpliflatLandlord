import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class UploadDocumentDao {
  static Stream<QuerySnapshot> getAllDocuments(String ownerTenantFlatId) {
    return Firestore.instance
          .collection(globals.ownerTenantFlat)
          .document(ownerTenantFlatId)
          .collection(globals.documentManager)
          .snapshots();
  }

  static Future<DocumentSnapshot> getDocument(String ownerTenantFlatId, String documentId) async {
    return Firestore.instance
          .collection(globals.ownerTenantFlat)
          .document(ownerTenantFlatId)
          .collection(globals.documentManager).document(documentId).get();
  }

  static DocumentReference getDocumentReference(String ownerTenantFlatId, String documentId) {
    return Firestore.instance
          .collection(globals.ownerTenantFlat)
          .document(ownerTenantFlatId)
          .collection(globals.documentManager).document(documentId);
  }

  static Future<bool> delete(String ownerTenantFlatId, String documentId) async {
    return Firestore.instance
              .collection(globals.ownerTenantFlat)
              .document(ownerTenantFlatId)
              .collection(globals.documentManager)
              .document(documentId)
              .delete().then((ret) {return true;}).catchError((e) {return false;});
  }
}