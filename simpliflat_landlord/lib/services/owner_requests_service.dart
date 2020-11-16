import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

      request.setOwnerIdList(flat.getOwnerIdList());

    

    Map<String, dynamic> data = request.toJson();
    return await LandlordRequestsDao.add(data);
  }

  static Future<bool> acceptRequestFromOwner(LandlordRequest request) async {

    HttpsCallable func = CloudFunctions.instance.getHttpsCallable(
                      functionName: "acceptRequestFromOwner",
                  );

                  try {
                 HttpsCallableResult res = await func.call(<String, dynamic> {'requestId': request.getRequestId()});
                  if((res.data as Map)['code'] == 0) {
                    return true;
                  }
                  else {
                    return false;
                  }
                  }
                  catch(e) {
                    return false;
                  }
  }

  static Future<bool> acceptRequestFromCoOwner(LandlordRequest request) async {

    HttpsCallable func = CloudFunctions.instance.getHttpsCallable(
                      functionName: "acceptRequestFromCoOwner",
                  );

                  try {
                 HttpsCallableResult res = await func.call(<String, dynamic> {'requestId': request.getRequestId()});
                  if((res.data as Map)['code'] == 0) {
                    return true;
                  }
                  else {
                    return false;
                  }
                  }
                  catch(e) {
                    return false;
                  }
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

    /** Remove ownerId in all incoming and outgoing requests to flat */

    QuerySnapshot s = await LandlordRequestsDao.getAllOwnerRequestsForFlatD(flat.getFlatId());

    Map<String, dynamic> updateReqData = LandlordRequest.toUpdateJson(ownerIdList: FieldValue.arrayRemove([owner.getOwnerId()]));

    for(int i = 0; i < s.documents.length; i++) {
        DocumentReference d = LandlordRequestsDao.getDocumentReference(s.documents[i].documentID);
        batch.updateData(d, updateReqData);
    }

    /** remove ownerId from incoming and outgoing requests for flat from tenant */

    QuerySnapshot ts = await TenantRequestsDao.getRequestsForFlatD(flat.getFlatId());

    Map<String, dynamic> updateTenReqData = TenantRequest.toUpdateJson(ownerIdList: FieldValue.arrayRemove([owner.getOwnerId()]));

    for(int i = 0; i < ts.documents.length; i++) {
        DocumentReference d = TenantRequestsDao.getDocumentReference(ts.documents[i].documentID);
        batch.updateData(d, updateTenReqData);
    }

    /** remove owner in apartment tenant list if document present */
    QuerySnapshot otf = await OwnerTenantDao.getByOwnerFlatId(flat.getFlatId());

    if(otf.documents != null && otf.documents.isNotEmpty) {
      String otfId = otf.documents[0].documentID;
      DocumentReference otfdoc = OwnerTenantDao.getDocumentReference(otfId);
      DocumentReference ntfnDoc = Firestore.instance.collection('notification_tokens').document(otfId);
      Map data = {'o_' + owner.getOwnerId(): FieldValue.delete()};
      batch.updateData(otfdoc, data);
      batch.updateData(ntfnDoc, data);

    }

    bool ifSuccess = await batch.commit().then((ret){
      return true;
    }).catchError((e){
     return false;
    });

    return ifSuccess;

  }


}