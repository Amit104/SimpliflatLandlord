import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class OwnerDao {
  static Future<QuerySnapshot> getOwnerByPhoneNumber(String phoneNumber) { 
    return Firestore.instance.collection(globals.landlord).where('phone', isEqualTo: phoneNumber).limit(1).getDocuments();
  }

  static DocumentReference getDocumentReference(String documentId) {
    return Firestore.instance.collection(globals.landlord).document(documentId);
  }

  static Future<DocumentSnapshot> getDocument(String documentId) async {
    return Firestore.instance.collection(globals.landlord).document(documentId).get();
  }

  static Future<bool> update(String documentId, Map<String, dynamic> data) async {
    return Firestore.instance
        .collection(globals.landlord)
        .document(documentId)
        .updateData(data).then((ret) {
          return true;
        }).catchError((e) {
          return false;
        });
  }
}