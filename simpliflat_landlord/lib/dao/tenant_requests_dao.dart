import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class TenantRequestsDao {
  static Stream<QuerySnapshot> getReceivedRequestsForFlat(String flatId) {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('owner_flat_id', isEqualTo: flatId)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('request_from_tenant', isEqualTo: true)
        .snapshots();
  }

  static Future<QuerySnapshot> getReceivedRequestsForFlatD(String flatId) {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('owner_flat_id', isEqualTo: flatId)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('request_from_tenant', isEqualTo: true)
        .getDocuments();
  }

  static Stream<QuerySnapshot> getSentRequestsForFlat(String flatId) {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('owner_flat_id', isEqualTo: flatId)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('request_from_tenant', isEqualTo: false)
        .snapshots();
  }

  static Future<QuerySnapshot> getSentRequestsForFlatD(String flatId) async {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('owner_flat_id', isEqualTo: flatId)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('request_from_tenant', isEqualTo: false)
        .getDocuments();
  }

  static Stream<QuerySnapshot> getReceivedRequestsForBuilding(
      String buildingId) {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('building_id', isEqualTo: buildingId)
        .where('status', isEqualTo: 0)
        .snapshots();
  }

  static Stream<QuerySnapshot> getAllReceivedRequests(String userId) {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('owner_id_list', arrayContains: userId)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('request_from_tenant', isEqualTo: true)
        .snapshots();
  }

  static DocumentReference getDocumentReference(String documentId) {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .document(documentId);
  }

  static Future<QuerySnapshot> getSentReqForFlatByIdD(
      String userId, String flatId) async {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('owner_flat_id', isEqualTo: flatId)
        .where('request_from_tenant', isEqualTo: false)
        .where('created_by.user_id', isEqualTo: userId)
        .getDocuments();
  }

  static Future<bool> update(String documentId, Map<String, dynamic> data) {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .document(documentId)
        .updateData(data)
        .then((ret) {
      return true;
    }).catchError(() {
      return false;
    });
  }

  static Future<bool> add(Map<String, dynamic> data) async {
    return  Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .add(data)
        .then((value) {
      return true;
    }).catchError((e) {
      return false;
    });
  }

  static Future<bool> delete(String documentId) async {
    return getDocumentReference(documentId).delete().then((ret) {
      return true;
    }).catchError(() {
      return false;
    });
  }
}
