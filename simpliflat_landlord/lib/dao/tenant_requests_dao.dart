import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/model/tenant_request.dart';

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

  static Future<QuerySnapshot> getRequestsForFlatD(String flatId) {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('owner_flat_id', isEqualTo: flatId)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
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

  static Future<bool> update(String documentId, Map<String, dynamic> data) async{ //method not used
    return Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentReference ref = Firestore.instance.collection(globals.joinFlatLandlordTenant).document(documentId);
      DocumentSnapshot doc = await transaction.get(ref);
      TenantRequest req = TenantRequest.fromJson(doc.data, documentId);
      if(req.getStatus() == globals.RequestStatus.Pending.index) {
        return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .document(documentId)
        .updateData(data)
        .then((ret) {
        return;
      }).catchError(() {
        throw Exception;
      });
      }
      else {
        throw Exception;
      }
    }).then((ret) {
      return true;
    }).catchError((e) {return false;});
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
