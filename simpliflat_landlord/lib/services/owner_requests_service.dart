import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/dao/landlord_requests_dao.dart';
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/dao/owner_tenant_dao.dart';
import 'package:simpliflat_landlord/dao/tenant_requests_dao.dart';
import 'package:simpliflat_landlord/model/landlord_request.dart';
import 'package:simpliflat_landlord/model/tenant_request.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';

class OwnerRequestsService {


  static Future<bool> sendRequestToOwner(
      Building building, Block block, OwnerFlat flat, User user) async {
   
    LandlordRequest request = new LandlordRequest();
    request.setBuildingAddress(building.getBuildingAddress());
    request.setBuildingDisplayId(building.getBuildingDisplayId());
    request.setBuildingId(building.getBuildingId());
    request.setBuildingName(building.getBuildingName());
    request.setZipcode(building.getZipcode());
    request.setStatus(globals.RequestStatus.Pending.index);
    request.setRequesterPhone(user.getPhone());
    request.setRequesterId(user.getUserId());
    request.setRequestToOwner(true);
    request.setRequesterUserName(user.getName());
    request.setCreatedAt(Timestamp.now());

    
    request.setBlockName(block.getBlockName());
    request.setFlatId(flat.getFlatId());
    request.setFlatDisplayId(flat.getFlatDisplayId());
    request.setFlatNumber(flat.getFlatName());

    request.setOwnerIdList(flat.getOwnerIdList());
    

    Map<String, dynamic> data = request.toJson();
    return LandlordRequestsDao.add(data);
  }

  static Future<bool> sendRequestToCoOwner(OwnerFlat flat, User user, Owner toOwner) async {

    LandlordRequest request = new LandlordRequest();
    request.setBuildingAddress(flat.getBuildingAddress());
    request.setBuildingDisplayId(flat.getBuildingDisplayId());
    request.setBuildingId(flat.getBuildingId());
    request.setBuildingName(flat.getBuildingName());
    request.setZipcode(flat.getZipcode());
    request.setStatus(globals.RequestStatus.Pending.index);
    request.setRequesterPhone(user.getPhone());
    request.setRequesterId(user.getUserId());
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
    return await LandlordRequestsDao.add(data);
  }

  static Future<bool> acceptRequestFromOwner(LandlordRequest request) async {

    WriteBatch batch = Firestore.instance.batch();


    /** Accept request */
    Map<String, dynamic> reqUpdateData = LandlordRequest.toUpdateJson(status: globals.RequestStatus.Accepted.index);

    DocumentReference reqDoc = LandlordRequestsDao.getDocumentReference(request.getRequestId());
    batch.updateData(reqDoc, reqUpdateData);

    /** Add toUserId in ownerIdList of owner flat */

    DocumentReference propDoc;
    propDoc = OwnerFlatDao.getDocumentReference(request.getFlatId());
    
    
    Map<String, dynamic> propUpdateData = OwnerFlat.toUpdateJson(ownerIdList: FieldValue.arrayUnion([request.getToUserId()]), ownerRoleList: FieldValue.arrayUnion([request.getToUserId() + ':' + request.getToUsername() + ':' + globals.OwnerRoles.Manager.index.toString()]));
    batch.updateData(propDoc, propUpdateData);


    /** Delete all sent requests to that flat */

    QuerySnapshot s = await LandlordRequestsDao.getMySentRequestsToOwnerForFlat(request.getToUserId(), request.getFlatId());


    for(int i = 0; i < s.documents.length; i++) {
      if(s.documents[i].documentID != request.getRequestId()) {
        DocumentReference d = LandlordRequestsDao.getDocumentReference(s.documents[i].documentID);
        batch.delete(d);
      }
    }

    /** Add ownerId in ownerId List of all requests received for that flat */

    QuerySnapshot ts = await TenantRequestsDao.getRequestsForFlatD(request.getFlatId());

    Map<String, dynamic> updateTenReqData = TenantRequest.toUpdateJson(ownerIdList: FieldValue.arrayUnion([request.getToUserId()]));

    for(int i = 0; i < ts.documents.length; i++) {
      DocumentReference d =  TenantRequestsDao.getDocumentReference(ts.documents[i].documentID);
      batch.updateData(d, updateTenReqData);
    }

    /** Add toUserId in all incoming owner requests to flat */

    QuerySnapshot rs = await LandlordRequestsDao.getAllReceivedCoownerRequestsForFlatD(request.getFlatId());

    Map<String, dynamic> updateReqData = LandlordRequest.toUpdateJson(ownerIdList: FieldValue.arrayUnion([request.getToUserId()]));

    for(int i = 0; i < rs.documents.length; i++) {
      if(rs.documents[i].documentID != request.getRequestId()) {
        DocumentReference d = LandlordRequestsDao.getDocumentReference(rs.documents[i].documentID);
        batch.updateData(d, updateReqData);
      }
    }

    /** add owner in apartment tenant list if document present */
    QuerySnapshot otf = await OwnerTenantDao.getByOwnerFlatId(request.getFlatId());

    if(otf.documents != null && otf.documents.isNotEmpty) {
      DocumentSnapshot ld = await OwnerDao.getDocument(request.getToUserId());
      String otfId = otf.documents[0].documentID;
      DocumentReference otfdoc = OwnerTenantDao.getDocumentReference(otfId);
      Map<String, dynamic> data = {'o_' + ld.documentID: ld.data['name'] + '::' + ld.data['notification_token']};
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

    Map<String, dynamic> reqUpdateData = LandlordRequest.toUpdateJson(status: globals.RequestStatus.Accepted.index);
    DocumentReference reqDoc = LandlordRequestsDao.getDocumentReference(request.getRequestId());
    batch.updateData(reqDoc, reqUpdateData);

    /** Add requesterId in owner flat owner list */

    DocumentReference propDoc;
    propDoc = LandlordRequestsDao.getDocumentReference(request.getFlatId());
    
    
    Map<String, dynamic> propUpdateData = OwnerFlat.toUpdateJson(ownerIdList: FieldValue.arrayUnion([request.getRequesterId()]), ownerRoleList: FieldValue.arrayUnion([request.getRequesterId() + ':' + request.getRequesterUserName() + ':' + globals.OwnerRoles.Manager.index.toString()]));
    batch.updateData(propDoc, propUpdateData);

    
    /** Add requesterId in all incoming requests to flat */

    QuerySnapshot s = await LandlordRequestsDao.getAllReceivedCoownerRequestsForFlatD(request.getFlatId());

    Map<String, dynamic> updateReqData = LandlordRequest.toUpdateJson(ownerIdList: FieldValue.arrayUnion([request.getRequesterId()]));

    for(int i = 0; i < s.documents.length; i++) {
      if(s.documents[i].documentID != request.getRequestId()) {
        DocumentReference d = LandlordRequestsDao.getDocumentReference(s.documents[i].documentID);
        batch.updateData(d, updateReqData);
      }
    }


    /** Add requesterId in all tenant requests for this flat */

    QuerySnapshot ts = await TenantRequestsDao.getReceivedRequestsForFlatD(request.getFlatId());

    Map<String, dynamic> updateTenReqData = TenantRequest.toUpdateJson(ownerIdList: FieldValue.arrayUnion([request.getRequesterId()]));

    for(int i = 0; i < ts.documents.length; i++) {
      DocumentReference d = TenantRequestsDao.getDocumentReference(ts.documents[i].documentID);
      batch.updateData(d, updateTenReqData);
    }

    /** delete sent request to that coowner for this flat */

    QuerySnapshot qs = await LandlordRequestsDao.getAllSentRequestsToCoownerForFlatD(request.getRequesterId(), request.getFlatId());


    for(int i = 0; i < qs.documents.length; i++) {
      if(qs.documents[i].documentID != request.getRequestId()) {
        DocumentReference d = LandlordRequestsDao.getDocumentReference(qs.documents[i].documentID);
        batch.delete(d);
      }
    }

    /** add owner in apartment tenant list if document present */
    QuerySnapshot otf = await OwnerTenantDao.getByOwnerFlatId(request.getFlatId());

    if(otf.documents != null && otf.documents.isNotEmpty) {
      DocumentSnapshot ld = await OwnerDao.getDocument(request.getRequesterId());
      String otfId = otf.documents[0].documentID;
      DocumentReference otfdoc = OwnerTenantDao.getDocumentReference(otfId);
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
    Map<String, dynamic> updateData = LandlordRequest.toUpdateJson(status: globals.RequestStatus.Rejected.index);
    return await LandlordRequestsDao.update(request.getRequestId(), updateData);
  }

  static Future<bool> removeOwnerFromFlat(Owner owner, OwnerFlat flat) async {

    WriteBatch batch = Firestore.instance.batch();

    /** remove ownerId from owner flat */

    DocumentReference propDoc;
    propDoc = OwnerFlatDao.getDocumentReference(flat.getFlatId());
    
    
    Map<String, dynamic> propUpdateData = OwnerFlat.toUpdateJson(ownerIdList: FieldValue.arrayRemove([owner.getOwnerId()]), ownerRoleList: FieldValue.arrayRemove([owner.getOwnerId() + ':' + owner.getName() + ':' + globals.OwnerRoles.Manager.index.toString()]));
    batch.updateData(propDoc, propUpdateData);

    /** Remove ownerId in all incoming requests to flat */

    QuerySnapshot s = await LandlordRequestsDao.getAllReceivedCoownerRequestsForFlatD(flat.getFlatId());

    Map<String, dynamic> updateReqData = LandlordRequest.toUpdateJson(ownerIdList: FieldValue.arrayRemove([owner.getOwnerId()]));

    for(int i = 0; i < s.documents.length; i++) {
        DocumentReference d = LandlordRequestsDao.getDocumentReference(s.documents[i].documentID);
        batch.updateData(d, updateReqData);
    }

    /** delete requests sent by that owner for that flat */

    QuerySnapshot qs = await LandlordRequestsDao.getMySentReqToCoOwForFlatByIdD(owner.getOwnerId(), flat.getFlatId());


    for(int i = 0; i < qs.documents.length; i++) {
        DocumentReference d = LandlordRequestsDao.getDocumentReference(qs.documents[i].documentID);
        batch.delete(d);
    }

    /** remove ownerId from incoming requests for flat from tenant */

    QuerySnapshot ts = await TenantRequestsDao.getRequestsForFlatD(flat.getFlatId());

    Map<String, dynamic> updateTenReqData = TenantRequest.toUpdateJson(ownerIdList: FieldValue.arrayRemove([owner.getOwnerId()]));

    for(int i = 0; i < ts.documents.length; i++) {
        DocumentReference d = TenantRequestsDao.getDocumentReference(ts.documents[i].documentID);
        batch.updateData(d, updateTenReqData);
    }

    /** delete requests sent to tenant by this owner */

    QuerySnapshot tss = await TenantRequestsDao.getSentReqForFlatByIdD(owner.getOwnerId(), flat.getFlatId());

    for(int i = 0; i < tss.documents.length; i++) {
        DocumentReference d = TenantRequestsDao.getDocumentReference(tss.documents[i].documentID);
        batch.delete(d);
    }

    /** remove owner in apartment tenant list if document present */
    QuerySnapshot otf = await OwnerTenantDao.getByOwnerFlatId(flat.getFlatId());

    if(otf.documents != null && otf.documents.isNotEmpty) {
      String otfId = otf.documents[0].documentID;
      DocumentReference otfdoc = OwnerTenantDao.getDocumentReference(otfId);
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