import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/models/Block.dart';
import 'package:simpliflat_landlord/screens/models/Building.dart';
import 'package:simpliflat_landlord/screens/models/LandlordRequest.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/models/OwnerFlat.dart';

class OwnerRequestsService {


  static Future<bool> sendRequestToOwner(
      Building building, Block block, OwnerFlat flat, Owner user) async {
   
    LandlordRequest request = new LandlordRequest();
    request.setBuildingAddress(building.getBuildingAddress());
    request.setBuildingDisplayId(building.getBuildingDisplayId());
    request.setBuildingId(building.getBuildingId());
    request.setBuildingName(building.getBuildingName());
    request.setZipcode(building.getZipcode());
    request.setStatus(globals.RequestStatus.Pending.index);
    request.setRequesterPhone(user.getPhone());
    request.setRequesterId(user.getOwnerId());
    request.setRequestToOwner(true);
    request.setRequesterUserName(user.getName());
    request.setCreatedAt(Timestamp.now());

    
    request.setBlockName(block.getBlockName());
    request.setFlatId(flat.getFlatId());
    request.setFlatDisplayId(flat.getFlatDisplayId());
    request.setFlatNumber(flat.getFlatName());

    request.setOwnerIdList(flat.getOwnerIdList());
    

    Map<String, dynamic> data = request.toJson();
    bool ifSuccess = await Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .add(data)
        .then((value) {
      
      return true;
    }).catchError((e) {
    return false;
    });

    return ifSuccess;
  }

  static Future<bool> sendRequestToCoOwner(OwnerFlat flat, Owner user, Owner toOwner) async {

    LandlordRequest request = new LandlordRequest();
    request.setBuildingAddress(flat.getBuildingAddress());
    request.setBuildingDisplayId(flat.getBuildingDisplayId());
    request.setBuildingId(flat.getBuildingId());
    request.setBuildingName(flat.getBuildingName());
    request.setZipcode(flat.getZipcode());
    request.setStatus(globals.RequestStatus.Pending.index);
    request.setRequesterPhone(user.getPhone());
    request.setRequesterId(user.getOwnerId());
    request.setRequestToOwner(false);
    request.setRequesterUserName(user.getName());
    request.setCreatedAt(Timestamp.now());

    
      request.setBlockName(flat.getBlockName());
      request.setFlatId(flat.getFlatId());
      request.setFlatDisplayId(flat.getFlatDisplayId());
      request.setFlatNumber(flat.getFlatName());
    

      request.setToUserId(toOwner.getOwnerId());
      request.setToPhoneNumber(toOwner.getPhone());
      request.setToUsername(toOwner.getName());
    

    Map<String, dynamic> data = request.toJson();
    bool ifSuccess = await Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .add(data)
        .then((value) {
      return true;
    }).catchError((e) {
      return false;
    });

    return ifSuccess;
  }

  static Future<bool> acceptRequestFromOwner(LandlordRequest request) async {

    WriteBatch batch = Firestore.instance.batch();


    /** Accept request */
    Map<String, dynamic> reqUpdateData = {'status': globals.RequestStatus.Accepted.index};

    DocumentReference reqDoc = Firestore.instance.collection(globals.ownerOwnerJoin).document(request.getRequestId());
    batch.updateData(reqDoc, reqUpdateData);

    /** Add toUserId in ownerIdList of owner flat */

    DocumentReference propDoc;
    propDoc = Firestore.instance.collection(globals.ownerFlat).document(request.getFlatId());
    
    
    Map<String, dynamic> propUpdateData = {'ownerIdList': FieldValue.arrayUnion([request.getToUserId()]), 'ownerRoleList': FieldValue.arrayUnion([request.getToUserId() + ':' + globals.OwnerRoles.Manager.index.toString()])};
    batch.updateData(propDoc, propUpdateData);


    /** Delete all sent requests to that flat */

    QuerySnapshot s = await Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('flatId', isEqualTo: request.getFlatId())
    .where('requesterId', isEqualTo: request.getToUserId())
    .where('requestToOwner', isEqualTo: true).getDocuments();


    for(int i = 0; i < s.documents.length; i++) {
      if(s.documents[i].documentID != request.getRequestId()) {
        DocumentReference d = Firestore.instance.collection(globals.ownerOwnerJoin).document(s.documents[i].documentID);
        batch.delete(d);
      }
    }

    /** Add ownerId in ownerId List of all requests received for that flat */

    QuerySnapshot ts = await Firestore.instance.collection(globals.ownerTenantFlat)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('owner_flat_id', isEqualTo: request.getFlatId())
    .where('request_to_tenant', isEqualTo: false).getDocuments();

    Map<String, dynamic> updateTenReqData = {'ownerIdList': FieldValue.arrayUnion([request.getToUserId()])};

    for(int i = 0; i < ts.documents.length; i++) {
      DocumentReference d = Firestore.instance.collection(globals.ownerTenantFlat).document(ts.documents[i].documentID);
      batch.updateData(d, updateTenReqData);
    }

    /** Add toUserId in all incoming owner requests to flat */

    QuerySnapshot rs = await Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('flatId', isEqualTo: request.getFlatId())
    .where('requestToOwner', isEqualTo: true).getDocuments();

    Map<String, dynamic> updateReqData = {'ownerIdList': FieldValue.arrayUnion([request.getToUserId()])};

    for(int i = 0; i < rs.documents.length; i++) {
      if(rs.documents[i].documentID != request.getRequestId()) {
        DocumentReference d = Firestore.instance.collection(globals.ownerOwnerJoin).document(rs.documents[i].documentID);
        batch.updateData(d, updateReqData);
      }
    }

    bool ifSuccess = await batch.commit().then((ret){
      return true;
    }).catchError((e){
     return false;
    });

    return ifSuccess;

  }

  static Future<bool> acceptRequestFromCoOwner(LandlordRequest request) async {

    WriteBatch batch = Firestore.instance.batch();

    /** Accept request */

    Map<String, dynamic> reqUpdateData = {'status': globals.RequestStatus.Accepted.index};
    DocumentReference reqDoc = Firestore.instance.collection(globals.ownerOwnerJoin).document(request.getRequestId());
    batch.updateData(reqDoc, reqUpdateData);

    /** Add requesterId in owner flat owner list */

    DocumentReference propDoc;
    propDoc = Firestore.instance.collection(globals.ownerFlat).document(request.getFlatId());
    
    
    Map<String, dynamic> propUpdateData = {'ownerIdList': FieldValue.arrayUnion([request.getRequesterId()]), 'ownerRoleList': FieldValue.arrayUnion([request.getRequesterId() + ':' + globals.OwnerRoles.Manager.index.toString()])};
    batch.updateData(propDoc, propUpdateData);

    
    /** Add requesterId in all incoming requests to flat */

    QuerySnapshot s = await Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('flatId', isEqualTo: request.getFlatId())
    .where('requestToOwner', isEqualTo: true).getDocuments();

    Map<String, dynamic> updateReqData = {'ownerIdList': FieldValue.arrayUnion([request.getRequesterId()])};

    for(int i = 0; i < s.documents.length; i++) {
      if(s.documents[i].documentID != request.getRequestId()) {
        DocumentReference d = Firestore.instance.collection(globals.ownerOwnerJoin).document(s.documents[i].documentID);
        batch.updateData(d, updateReqData);
      }
    }


    /** Add requesterId in all tenant requests for this flat */

    QuerySnapshot ts = await Firestore.instance.collection(globals.ownerTenantFlat)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('owner_flat_id', isEqualTo: request.getFlatId())
    .where('request_to_tenant', isEqualTo: false).getDocuments();

    Map<String, dynamic> updateTenReqData = {'ownerIdList': FieldValue.arrayUnion([request.getRequesterId()])};

    for(int i = 0; i < ts.documents.length; i++) {
      DocumentReference d = Firestore.instance.collection(globals.ownerTenantFlat).document(ts.documents[i].documentID);
      batch.updateData(d, updateTenReqData);
    }

    /** delete sent request to that coowner for this flat */

    QuerySnapshot qs = await Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('flatId', isEqualTo: request.getFlatId())
    .where('toUserId', isEqualTo: request.getRequesterId())
    .where('requestToOwner', isEqualTo: false).getDocuments();


    for(int i = 0; i < qs.documents.length; i++) {
      if(qs.documents[i].documentID != request.getRequestId()) {
        DocumentReference d = Firestore.instance.collection(globals.ownerOwnerJoin).document(qs.documents[i].documentID);
        batch.delete(d);
      }
    }

    bool ifSuccess = await batch.commit().then((ret){
      return true;
    }).catchError((e){
     return false;
    });

    return ifSuccess;

  }

  static Future<bool> rejectRequest(LandlordRequest request) async {
    Map<String, dynamic> updateData = {'status': globals.RequestStatus.Rejected.index};
    bool ifSuccess = await Firestore.instance.collection(globals.ownerOwnerJoin).document(request.getRequestId()).updateData(updateData).then((ret){
      return true;
    }).catchError((){
      return false;
    });

    return ifSuccess;

  }


}