import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/models/Block.dart';
import 'package:simpliflat_landlord/screens/models/Building.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/models/OwnerFlat.dart';
import 'package:simpliflat_landlord/screens/models/TenantFlat.dart';



class TenantRequestsService {
  static Future<bool> rejectTenantRequest(Map<String, dynamic> request) async {
    Map<String, dynamic> updateData = {
      'status': globals.RequestStatus.Rejected.index
    };
    bool ifSuccess = await Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .document(request['documentID'].toString())
        .updateData(updateData)
        .then((ret) {

      return true;
    }).catchError(() {
      return false;
    });

    return ifSuccess;
  }

  static Future<String> acceptTenantRequest(Map<String, dynamic> request) async {
    /** accept request */

    Map<String, dynamic> reqUpdateData = {'status': globals.RequestStatus.Accepted.index};

    WriteBatch batch = Firestore.instance.batch();

    DocumentReference reqDoc = Firestore.instance.collection(globals.joinFlatLandlordTenant).document(request['documentID'].toString());
    batch.updateData(reqDoc, reqUpdateData);

    /** create document in owner_tenant_flat */

    DocumentReference propDoc = Firestore.instance.collection(globals.ownerTenantFlat).document();
    
    
    Map<String, dynamic> reqData = {'ownerFlatId': request['owner_flat_id'].toString(), 'tenantFlatId': request['tenant_flat_id'].toString(), 'status': 0, 'tenantFlatName': request['tenant_flat_name'], 'building_name': request['building_details']['building_name'], 'building_address': request['building_details']['building_address'], 'zipcode': request['building_details']['building_zipcode']};
    batch.setData(propDoc, reqData);


    /** reject all other pending received requests for that flat */

    QuerySnapshot s = await Firestore.instance.collection(globals.joinFlatLandlordTenant).where('owner_flat_id', isEqualTo: request['owner_flat_id'].toString())
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('request_from_tenant', isEqualTo: true).getDocuments();

    Map<String, dynamic> reqRejectData = {'status': globals.RequestStatus.Rejected.index};

    for(int i = 0; i < s.documents.length; i++) {
      if(s.documents[i].documentID != request['documentID'].toString()) {
        DocumentReference d = Firestore.instance.collection(globals.joinFlatLandlordTenant).document(s.documents[i].documentID);
        batch.updateData(d, reqRejectData);
      }
    }

    /** delete all pending sent requests */

    QuerySnapshot del = await Firestore.instance.collection(globals.joinFlatLandlordTenant).where('owner_flat_id', isEqualTo: request['owner_flat_id'].toString())
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('request_from_tenant', isEqualTo: false).getDocuments();

    for(int i = 0; i < del.documents.length; i++) {
      if(del.documents[i].documentID != request['documentID'].toString()) {
        DocumentReference delDoc = Firestore.instance.collection(globals.joinFlatLandlordTenant).document(del.documents[i].documentID);
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

  static Future<bool> createTenantRequest(OwnerFlat flat, Owner user, TenantFlat tenantFlat) async {
    Map<String, dynamic> newReq = {
          'building_id' : flat.getBuildingId(),
          'block_id' : flat.getBlockName(),
          'owner_flat_id' : flat.getFlatId(),
          'tenant_flat_id': tenantFlat.getFlatId(),
          'request_from_tenant': false,
          'status': 0,
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
          'created_by' : { "user_id" : user.getOwnerId(), 'name' : user.getName(), 'phone' : user.getPhone() },
          'tenant_flat_name' : tenantFlat.getFlatName(),
          'building_details' : {'building_name' : flat.getBuildingName(),'building_zipcode' : flat.getZipcode(),'building_address' : flat.getBuildingAddress()} ,
        };


    bool ifSuccess = await Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .add(newReq)
        .then((value) {
      return true;
    }).catchError((e) {
      return false;
    });


    return ifSuccess;
  }

  static Future<bool> deleteRequestSentToTenant(String requestDocumentId) async {
    
    DocumentReference ref = Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .document(requestDocumentId);
    bool ifSuccess = await ref.delete().then((ret) {
      return true;
    }).catchError(() {
      return false;
    });

    return ifSuccess;
  }
  

}