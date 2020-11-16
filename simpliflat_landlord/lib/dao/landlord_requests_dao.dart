import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;

class LandlordRequestsDao {
  static Stream<QuerySnapshot> getRequestsSentToMeByOwner(String userId) {
    return Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .snapshots();
  }

  static Future<QuerySnapshot> getRequestsSentByMe(String userId, String buildingId) async {
    return Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .where('requesterId', isEqualTo: userId)
        .where('buildingId', isEqualTo: buildingId)
        .getDocuments();
  }

  static Future<QuerySnapshot> getRequestsSentByMeToOwnerForBuilding(String userId, String buildingId) async {
    return Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .where('requesterId', isEqualTo: userId)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('requestToOwner', isEqualTo: true)
        .where('buildingId', isEqualTo: buildingId).getDocuments();
  }

  static Stream<QuerySnapshot> getAllReceivedRequestsFromCoowners(String userId) {
    return Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('ownerIdList', arrayContains: userId)
    .where('requestToOwner', isEqualTo: true).snapshots();
  }

  static Future<QuerySnapshot> getCoownerRequestsSentByMeForBuildingD(String buildingId, String toOwnerId) async {
    return Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .where('toUserId', isEqualTo: toOwnerId)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('requestToOwner', isEqualTo: false)
        .where('buildingId', isEqualTo: buildingId).getDocuments();
  }

  static Future<bool> add(Map<String, dynamic> data) async {
    return await Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .add(data)
        .then((value) {
      return true;
    }).catchError((e) {
      return false;
    });
  }

  static DocumentReference getDocumentReference(String documentId) {
    return Firestore.instance.collection(globals.ownerOwnerJoin).document(documentId);
  }

  static Future<QuerySnapshot> getMySentRequestsToOwnerForFlat(String userId, String flatId) async {
    return Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('flatId', isEqualTo: flatId)
    .where('requesterId', isEqualTo: userId)
    .where('requestToOwner', isEqualTo: true).getDocuments();

  }


  static Future<QuerySnapshot> getAllOwnerRequestsForFlatD(String flatId) async {
    return Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('flatId', isEqualTo: flatId).getDocuments();
  }

  static Future<QuerySnapshot> getAllSentRequestsToCoownerForFlatD(String requesterId, String flatId) async {
    return Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('flatId', isEqualTo: flatId)
    .where('toUserId', isEqualTo: requesterId)
    .where('requestToOwner', isEqualTo: false).getDocuments();
  }

  static Future<bool> update(String documentId, Map<String, dynamic> data) async {
    return Firestore.instance.collection(globals.ownerOwnerJoin).document(documentId).updateData(data).then((ret){
      return true;
    }).catchError((e){
      return false;
    });
  }

  static Future<QuerySnapshot> getMySentReqToCoOwForFlatByIdD(String userId, String flatId) async {
    return Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('flatId', isEqualTo: flatId)
    .where('requestToOwner', isEqualTo: false)
    .where('requesterId', isEqualTo: userId).getDocuments();
  }

}
