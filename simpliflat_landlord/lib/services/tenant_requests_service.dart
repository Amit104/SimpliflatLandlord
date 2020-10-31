import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/dao/owner_tenant_dao.dart';
import 'package:simpliflat_landlord/dao/tenant_dao.dart';
import 'package:simpliflat_landlord/dao/tenant_requests_dao.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/tenant_flat.dart';
import 'package:simpliflat_landlord/model/tenant_request.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/utility/utility.dart';



class TenantRequestsService {
  static Future<bool> rejectTenantRequest(TenantRequest request) async {
    Map<String, dynamic> updateData = TenantRequest.toUpdateJson(status: globals.RequestStatus.Rejected.index);
    return Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentReference ref = TenantRequestsDao.getDocumentReference(request.getRequestId());
      DocumentSnapshot doc = await transaction.get(ref);
      TenantRequest req = TenantRequest.fromJson(doc.data, request.getRequestId());
      Utility.assertThis(req.getStatus() == globals.RequestStatus.Pending.index);
        
      transaction.update(ref, updateData); 
        
    }).then((ret) {
      return true;
    }).catchError((e) {return false;});
  }

  static Future<String> acceptTenantRequest(TenantRequest request) async {
    /** accept request */

    Map<String, dynamic> reqUpdateData = TenantRequest.toUpdateJson(status: globals.RequestStatus.Accepted.index);

    WriteBatch batch = Firestore.instance.batch();

    DocumentReference reqDoc = TenantRequestsDao.getDocumentReference(request.getRequestId());
    batch.updateData(reqDoc, reqUpdateData);

    /** create document in owner_tenant_flat */

    DocumentReference propDoc = OwnerTenantDao.getDocumentReference(null);
    
    
    Map<String, dynamic> reqData = {'ownerFlatId': request.getOwnerFlatId(), 'tenantFlatId': request.getTenantFlatId(), 'status': 0, 'tenantFlatName': request.getTenantFlatName(), 'building_name': request.getBuildingName(), 'building_address': request.getBuildingAddress(), 'zipcode': request.getBuildingZipcode()};
    
      /** add all owners and tenants */
    DocumentSnapshot ofd = await OwnerFlatDao.getDocument(request.getOwnerFlatId());
    if(ofd.exists) {
        OwnerFlat ownerFlatTemp = OwnerFlat.fromJson(ofd.data,ofd.documentID);
        if(ownerFlatTemp.getOwnerIdList() != null) {
          for (String ownerId in ownerFlatTemp.getOwnerIdList()) {
              DocumentSnapshot landlordSnapshot = await OwnerDao.getDocument(ownerId);
              if (landlordSnapshot.exists) {
                reqData['o_' + landlordSnapshot.documentID] = landlordSnapshot.data['name'] + '::' + landlordSnapshot.data['notification_token'];
              }
          }
        }
    }

    QuerySnapshot tenants = await TenantDao.getTenantsUsingTenantFlatId(request.getTenantFlatId());
    if(tenants.documents != null && tenants.documents.length > 0) {
      for(DocumentSnapshot tenant in tenants.documents) {
        reqData['t_' + tenant.documentID] = tenant.data['name'] + '::' + tenant.data['notification_token'];
      }
    }
    
    batch.setData(propDoc, reqData);


    /** reject all other pending received requests for that flat */

    QuerySnapshot s = await TenantRequestsDao.getReceivedRequestsForFlatD(request.getOwnerFlatId());

    Map<String, dynamic> reqRejectData = TenantRequest.toUpdateJson(status: globals.RequestStatus.Rejected.index);

    for(int i = 0; i < s.documents.length; i++) {
      if(s.documents[i].documentID != request.getRequestId()) {
        DocumentReference d = TenantRequestsDao.getDocumentReference(s.documents[i].documentID);
        batch.updateData(d, reqRejectData);
      }
    }

    /** delete all pending sent requests */

    QuerySnapshot del = await TenantRequestsDao.getSentRequestsForFlatD(request.getOwnerFlatId());

    for(int i = 0; i < del.documents.length; i++) {
      if(del.documents[i].documentID != request.getRequestId()) {
        DocumentReference delDoc = TenantRequestsDao.getDocumentReference(del.documents[i].documentID);
        batch.delete(delDoc);
      }
    }

    bool ifSuccess = await batch.commit().then((ret){
      return true;
    }).catchError((e){
      return false;
    });

    if(ifSuccess) {
      return reqDoc.documentID;
    }
    else {
      return null;
    }
  }

  static Future<bool> createTenantRequest(OwnerFlat flat, User user, TenantFlat tenantFlat) async {
    TenantRequest req = new TenantRequest();
    req.setBuildingId(flat.getBuildingId());
    req.setBlockName(flat.getBlockName());
    req.setOwnerFlatId(flat.getFlatId());
    req.setTenantFlatId(tenantFlat.getFlatId());
    req.setRequestFromTenant(false);
    req.setStatus(globals.RequestStatus.Pending.index);
    req.setCreatedByUserId(user.getUserId());
    req.setCreatedByUserName(user.getName());
    req.setCreatedByUserPhone(user.getPhone());
    req.setTenantFlatName(tenantFlat.getFlatName());
    req.setBuildingName(flat.getBuildingName());
    req.setBuildingZipcode(flat.getZipcode());
    req.setBuildingAddress(flat.getBuildingAddress());
    req.setOwnerFlatName(flat.getFlatName());
    
    return TenantRequestsDao.add(req.toJson());
  }

  static Future<bool> deleteRequestSentToTenant(String requestDocumentId) async {
    return TenantRequestsDao.delete(requestDocumentId);
  }
  

}