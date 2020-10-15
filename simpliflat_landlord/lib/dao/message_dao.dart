import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class MessageDao {
  static Stream<QuerySnapshot> getAllForFlat(String flatId) {
    return Firestore.instance
                      .collection(globals.ownerTenantFlat)
                      .document(flatId)
                      .collection(globals.messageBoard)
                      .snapshots();
  }

  static DocumentReference getDocumentReference(String ownerTenantFlatId, String documentId) {
    return Firestore.instance
                      .collection(globals.ownerTenantFlat)
                      .document(ownerTenantFlatId)
                      .collection(globals.messageBoard).document(documentId);
  }

  static Future<DocumentSnapshot> getMessage(String messageId, String ownerTenantFlatId) async {
    return Firestore.instance
                      .collection(globals.ownerTenantFlat)
                      .document(ownerTenantFlatId)
                      .collection(globals.messageBoard).document(messageId).get();
  }

  static Future<bool> update(String ownerTenantFlatId, String documentId, Map<String, dynamic> data) async {
     return Firestore.instance
              .collection(globals.ownerTenantFlat)
              .document(ownerTenantFlatId)
              .collection(globals.messageBoard)
              .document(documentId)
              .updateData(data)
              .then((ret) {return true;}).catchError((e) {return false;});
  }

  static Future<bool> delete(String ownerTenantFlatId, String documentId) async {
    return Firestore.instance
            .collection(globals.ownerTenantFlat)
            .document(ownerTenantFlatId)
            .collection(globals.messageBoard)
            .document(documentId)
            .delete().then((ret) {return true;}).catchError((e) {return false;});
  }
}