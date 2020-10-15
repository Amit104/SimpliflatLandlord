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



class TenantRequestsService {
  static Future<bool> rejectTenantRequest(Map<String, dynamic> request) async {
    Map<String, dynamic> updateData = TenantRequest.toUpdateJson(status: globals.RequestStatus.Rejected.index);
    return TenantRequestsDao.update(request['documentId'], updateData);
  }

  static Future<String> acceptTenantRequest(Map<String, dynamic> request) async {
    /** accept request */

    Map<String, dynamic> reqUpdateData = TenantRequest.toUpdateJson(status: globals.RequestStatus.Accepted.index);

    WriteBatch batch = Firestore.instance.batch();

    DocumentReference reqDoc = TenantRequestsDao.getDocumentReference(request['documentID'].toString());
    batch.updateData(reqDoc, reqUpdateData);

    /** create document in owner_tenant_flat */

    DocumentReference propDoc = OwnerTenantDao.getDocumentReference(null);
    
    
    Map<String, dynamic> reqData = {'ownerFlatId': request['owner_flat_id'].toString(), 'tenantFlatId': request['tenant_flat_id'].toString(), 'status': 0, 'tenantFlatName': request['tenant_flat_name'], 'building_name': request['building_details']['building_name'], 'building_address': request['building_details']['building_address'], 'zipcode': request['building_details']['building_zipcode']};
    
      /** add all owners and tenants */
    DocumentSnapshot ofd = await OwnerFlatDao.getDocument(request['owner_flat_id'].toString());
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

    QuerySnapshot tenants = await TenantDao.getTenantsUsingTenantFlatId(request['tenant_flat_id'].toString());
    if(tenants.documents != null && tenants.documents.length > 0) {
      for(DocumentSnapshot tenant in tenants.documents) {
        reqData['t_' + tenant.documentID] = tenant.data['name'] + '::' + tenant.data['notification_token'];
      }
    }
    
    batch.setData(propDoc, reqData);


    /** reject all other pending received requests for that flat */

    QuerySnapshot s = await TenantRequestsDao.getReceivedRequestsForFlatD(request['owner_flat_id'].toString());

    Map<String, dynamic> reqRejectData = TenantRequest.toUpdateJson(status: globals.RequestStatus.Rejected.index);

    for(int i = 0; i < s.documents.length; i++) {
      if(s.documents[i].documentID != request['documentID'].toString()) {
        DocumentReference d = TenantRequestsDao.getDocumentReference(s.documents[i].documentID);
        batch.updateData(d, reqRejectData);
      }
    }

    /** delete all pending sent requests */

    QuerySnapshot del = await TenantRequestsDao.getSentRequestsForFlatD(request['owner_flat_id'].toString());

    for(int i = 0; i < del.documents.length; i++) {
      if(del.documents[i].documentID != request['documentID'].toString()) {
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
    Map<String, dynamic> newReq = {
          'building_id' : flat.getBuildingId(),
          'block_id' : flat.getBlockName(),
          'owner_flat_id' : flat.getFlatId(),
          'tenant_flat_id': tenantFlat.getFlatId(),
          'request_from_tenant': false,
          'status': 0,
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
          'created_by' : { "user_id" : user.getUserId(), 'name' : user.getName(), 'phone' : user.getPhone() },
          'tenant_flat_name' : tenantFlat.getFlatName(),
          'building_details' : {'building_name' : flat.getBuildingName(),'building_zipcode' : flat.getZipcode(),'building_address' : flat.getBuildingAddress()} ,
        };


    return TenantRequestsDao.add(newReq);
  }

  static Future<bool> deleteRequestSentToTenant(String requestDocumentId) async {
    return TenantRequestsDao.delete(requestDocumentId);
  }
  

}