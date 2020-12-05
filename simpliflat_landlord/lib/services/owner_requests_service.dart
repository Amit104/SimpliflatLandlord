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
    request.setUpdatedAt(Timestamp.now());

    request.setBlockName(block.getBlockName());
    request.setFlatId(flat.getFlatId());
    request.setFlatDisplayId(flat.getFlatDisplayId());
    request.setFlatNumber(flat.getFlatName());

    request.setOwnerIdList(flat.getOwnerIdList());

    Map<String, dynamic> data = request.toJson();
    return LandlordRequestsDao.add(data);
  }

  static Future<bool> sendRequestToCoOwner(
      OwnerFlat flat, User user, Owner toOwner) async {
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
    request.setUpdatedAt(Timestamp.now());

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
      HttpsCallableResult res = await func
          .call(<String, dynamic>{'requestId': request.getRequestId()});
      if ((res.data as Map)['code'] == 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> acceptRequestFromCoOwner(LandlordRequest request) async {
    HttpsCallable func = CloudFunctions.instance.getHttpsCallable(
      functionName: "acceptRequestFromCoOwner",
    );

    try {
      HttpsCallableResult res = await func
          .call(<String, dynamic>{'requestId': request.getRequestId()});
      if ((res.data as Map)['code'] == 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> rejectRequest(LandlordRequest request) async {
    Map<String, dynamic> updateData = LandlordRequest.toUpdateJson(
        status: globals.RequestStatus.Rejected.index);
    return await LandlordRequestsDao.update(request.getRequestId(), updateData);
  }

  static Future<bool> removeOwnerFromFlat(Owner owner, OwnerFlat flat) async {
    HttpsCallable func = CloudFunctions.instance.getHttpsCallable(
      functionName: "removeOwnerFromFlat",
    );

    try {
      HttpsCallableResult res = await func.call(<String, dynamic>{
        'ownerId': owner.getOwnerId(),
        'ownerFlatId': flat.getFlatId()
      });
      if ((res.data as Map)['code'] == 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
