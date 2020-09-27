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
    
    
    Map<String, dynamic> propUpdateData = {'ownerIdList': FieldValue.arrayUnion([request.getToUserId()]), 'ownerRoleList': FieldValue.arrayUnion([request.getToUserId() + ':' + request.getToUsername() + ':' + globals.OwnerRoles.Manager.index.toString()])};
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

    QuerySnapshot ts = await Firestore.instance.collection(globals.joinFlatLandlordTenant)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('owner_flat_id', isEqualTo: request.getFlatId())
    .where('request_to_tenant', isEqualTo: false).getDocuments();

    Map<String, dynamic> updateTenReqData = {'ownerIdList': FieldValue.arrayUnion([request.getToUserId()])};

    for(int i = 0; i < ts.documents.length; i++) {
      DocumentReference d = Firestore.instance.collection(globals.joinFlatLandlordTenant).document(ts.documents[i].documentID);
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

    /** add owner in apartment tenant list if document present */
    QuerySnapshot otf = await Firestore.instance.collection(globals.ownerTenantFlat)
    .where('status', isEqualTo: 0)
    .where('ownerFlatId', isEqualTo: request.getFlatId())
    .getDocuments();

    if(otf.documents != null && otf.documents.isNotEmpty) {
      DocumentSnapshot ld = await Firestore.instance.collection(globals.landlord).document(request.getToUserId()).get();
      String otfId = otf.documents[0].documentID;
      DocumentReference otfdoc = Firestore.instance.collection(globals.ownerTenantFlat).document(otfId);
      Map data = {'o_' + ld.documentID: ld.data['name'] + '::' + ld.data['notification_token']};
      otfdoc.updateData(data);
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
    
    
    Map<String, dynamic> propUpdateData = {'ownerIdList': FieldValue.arrayUnion([request.getRequesterId()]), 'ownerRoleList': FieldValue.arrayUnion([request.getRequesterId() + ':' + request.getRequesterUserName() + ':' + globals.OwnerRoles.Manager.index.toString()])};
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

    QuerySnapshot ts = await Firestore.instance.collection(globals.joinFlatLandlordTenant)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('owner_flat_id', isEqualTo: request.getFlatId())
    .where('request_to_tenant', isEqualTo: false).getDocuments();

    Map<String, dynamic> updateTenReqData = {'ownerIdList': FieldValue.arrayUnion([request.getRequesterId()])};

    for(int i = 0; i < ts.documents.length; i++) {
      DocumentReference d = Firestore.instance.collection(globals.joinFlatLandlordTenant).document(ts.documents[i].documentID);
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

    /** add owner in apartment tenant list if document present */
    QuerySnapshot otf = await Firestore.instance.collection(globals.ownerTenantFlat)
    .where('status', isEqualTo: 0)
    .where('ownerFlatId', isEqualTo: request.getFlatId())
    .getDocuments();

    if(otf.documents != null && otf.documents.isNotEmpty) {
      DocumentSnapshot ld = await Firestore.instance.collection(globals.landlord).document(request.getRequesterId()).get();
      String otfId = otf.documents[0].documentID;
      DocumentReference otfdoc = Firestore.instance.collection(globals.ownerTenantFlat).document(otfId);
      Map data = {'o_' + ld.documentID: ld.data['name'] + '::' + ld.data['notification_token']};
      otfdoc.updateData(data);
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

  static Future<bool> removeOwnerFromFlat(Owner owner, OwnerFlat flat) async {

    WriteBatch batch = Firestore.instance.batch();

    /** remove ownerId from owner flat */

    DocumentReference propDoc;
    propDoc = Firestore.instance.collection(globals.ownerFlat).document(flat.getFlatId());
    
    
    Map<String, dynamic> propUpdateData = {'ownerIdList': FieldValue.arrayRemove([owner.getOwnerId()]), 'ownerRoleList': FieldValue.arrayRemove([owner.getOwnerId() + ':' + owner.getName() + ':' + globals.OwnerRoles.Manager.index.toString()])};
    batch.updateData(propDoc, propUpdateData);

    /** Remove ownerId in all incoming requests to flat */

    QuerySnapshot s = await Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('flatId', isEqualTo: flat.getFlatId())
    .where('requestToOwner', isEqualTo: true).getDocuments();

    Map<String, dynamic> updateReqData = {'ownerIdList': FieldValue.arrayRemove([owner.getOwnerId()])};

    for(int i = 0; i < s.documents.length; i++) {
        DocumentReference d = Firestore.instance.collection(globals.ownerOwnerJoin).document(s.documents[i].documentID);
        batch.updateData(d, updateReqData);
    }

    /** delete requests sent by that owner for that flat */

    QuerySnapshot qs = await Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('flatId', isEqualTo: flat.getFlatId())
    .where('requestToOwner', isEqualTo: false)
    .where('requesterId', isEqualTo: owner.getOwnerId()).getDocuments();


    for(int i = 0; i < qs.documents.length; i++) {
        DocumentReference d = Firestore.instance.collection(globals.ownerOwnerJoin).document(qs.documents[i].documentID);
        batch.delete(d);
    }

    /** remove ownerId from incoming requests for flat from tenant */

    QuerySnapshot ts = await Firestore.instance.collection(globals.joinFlatLandlordTenant)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('owner_flat_id', isEqualTo: flat.getFlatId())
    .where('request_from_tenant', isEqualTo: true)
    .getDocuments();

    Map<String, dynamic> updateTenReqData = {'ownerIdList': FieldValue.arrayRemove([owner.getOwnerId()])};

    for(int i = 0; i < ts.documents.length; i++) {
        DocumentReference d = Firestore.instance.collection(globals.joinFlatLandlordTenant).document(ts.documents[i].documentID);
        batch.updateData(d, updateTenReqData);
    }

    /** delete requests sent to tenant by this owner */

    QuerySnapshot tss = await Firestore.instance.collection(globals.joinFlatLandlordTenant)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('owner_flat_id', isEqualTo: flat.getFlatId())
    .where('request_from_tenant', isEqualTo: false)
    .where('created_by.user_id', isEqualTo: owner.getOwnerId())
    .getDocuments();

    for(int i = 0; i < tss.documents.length; i++) {
        DocumentReference d = Firestore.instance.collection(globals.joinFlatLandlordTenant).document(tss.documents[i].documentID);
        batch.delete(d);
    }

    /** remove owner in apartment tenant list if document present */
    QuerySnapshot otf = await Firestore.instance.collection(globals.ownerTenantFlat)
    .where('status', isEqualTo: 0)
    .where('ownerFlatId', isEqualTo: flat.getFlatId())
    .getDocuments();

    if(otf.documents != null && otf.documents.isNotEmpty) {
      String otfId = otf.documents[0].documentID;
      DocumentReference otfdoc = Firestore.instance.collection(globals.ownerTenantFlat).document(otfId);
      Map data = {'o_' + owner.getOwnerId(): FieldValue.delete()};
      otfdoc.updateData(data);
    }

    bool ifSuccess = await batch.commit().then((ret){
      return true;
    }).catchError((e){
     return false;
    });

    return ifSuccess;

  }


}