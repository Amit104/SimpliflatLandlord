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
    Map<String, dynamic> reqUpdateData = {'status': globals.RequestStatus.Accepted.index};

    WriteBatch batch = Firestore.instance.batch();

    DocumentReference reqDoc = Firestore.instance.collection(globals.ownerOwnerJoin).document(request.getRequestId());
    batch.updateData(reqDoc, reqUpdateData);

    DocumentReference propDoc;
    propDoc = Firestore.instance.collection(globals.ownerFlat).document(request.getFlatId());
    
    
    Map<String, dynamic> propUpdateData = {'ownerIdList': FieldValue.arrayUnion([request.getToUserId()]), 'ownerRoleList': FieldValue.arrayUnion([request.getToUserId() + ':' + globals.OwnerRoles.Manager.index.toString()])};
    batch.updateData(propDoc, propUpdateData);
    bool ifSuccess = await batch.commit().then((ret){
      return true;
    }).catchError((e){
     return false;
    });

    return ifSuccess;

  }

  static Future<bool> acceptRequestFromCoOwner(LandlordRequest request) async {
    Map<String, dynamic> reqUpdateData = {'status': globals.RequestStatus.Accepted.index};

    WriteBatch batch = Firestore.instance.batch();

    DocumentReference reqDoc = Firestore.instance.collection(globals.ownerOwnerJoin).document(request.getRequestId());
    batch.updateData(reqDoc, reqUpdateData);

    DocumentReference propDoc;
    propDoc = Firestore.instance.collection(globals.ownerFlat).document(request.getFlatId());
    
    
    Map<String, dynamic> propUpdateData = {'ownerIdList': FieldValue.arrayUnion([request.getRequesterId()]), 'ownerRoleList': FieldValue.arrayUnion([request.getRequesterId() + ':' + globals.OwnerRoles.Manager.index.toString()])};
    batch.updateData(propDoc, propUpdateData);
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