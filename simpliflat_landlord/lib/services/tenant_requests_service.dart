import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/dao/owner_tenant_dao.dart';
import 'package:simpliflat_landlord/dao/tenant_dao.dart';
import 'package:simpliflat_landlord/dao/tenant_requests_dao.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/tenant_flat.dart';
import 'package:simpliflat_landlord/model/tenant_request.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:cloud_functions/cloud_functions.dart';



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
    HttpsCallable func = CloudFunctions.instance.getHttpsCallable(
                      functionName: "acceptTenantRequest",
                  );

                  try {
                 HttpsCallableResult res = await func.call(<String, dynamic> {'requestId': request.getRequestId()});
                  if((res.data as Map)['code'] == 0) {
                    return request.getRequestId();
                  }
                  else {
                    return null;
                  }
                  }
                  catch(e) {
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
    req.setOwnerIdList(flat.getOwners().map((Owner o) => o.getOwnerId()).toList());
    
    return TenantRequestsDao.add(req.toJson());
  }

  static Future<bool> deleteRequestSentToTenant(String requestDocumentId) async {
    return TenantRequestsDao.delete(requestDocumentId);
  }
  

}