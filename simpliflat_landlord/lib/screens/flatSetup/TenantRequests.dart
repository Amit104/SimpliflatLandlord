import 'package:flutter/material.dart';
import '../models/Building.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/utility.dart';
import 'dart:math';
import '../models/OwnerFlat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import './createProperty.dart';
import './PropertyRequests.dart';
import '../models/Block.dart';
import '../models/Owner.dart';
import '../models/LandlordRequest.dart';



class TenantRequests extends StatefulWidget {

  final String userId;

  final List<String> flatIds;

  final String buildingId;


  TenantRequests(this.userId, this.flatIds, this.buildingId);

  @override
  State<StatefulWidget> createState() {
    return TenantRequestsState(this.userId, this.flatIds, this.buildingId);
  }

}

class TenantRequestsState extends State<TenantRequests> {

  final String userId;

  bool loadingState = false;

  final List<String> flatIds;

  final String buildingId;



  TenantRequestsState(this.userId, this.flatIds, this.buildingId);

  @override
  Widget build(BuildContext context) {
    debugPrint(this.buildingId);
    debugPrint(this.flatIds.length.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('All Flats'),
        centerTitle: true,
        backgroundColor: Colors.white,
        
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        return loadingState == true?Container(alignment: Alignment.center, child: CircularProgressIndicator()):
        getBody(scaffoldC);
      }),
    );
  }

  Future<List<DocumentSnapshot>> getFlatList() async {
    debugPrint(this.buildingId);
    QuerySnapshot q = await Firestore.instance.collection(globals.joinFlatLandlordTenant).where('building_id', isEqualTo: this.buildingId).where('status', isEqualTo: globals.RequestStatus.Pending.index).getDocuments();

    List<DocumentSnapshot> documents = new List();

    debugPrint(q.documents.length.toString());
    q.documents.forEach((DocumentSnapshot d) {
      debugPrint(d.data['owner_flat_id']);
      if(this.flatIds.contains(d.data['owner_flat_id'])) {
        documents.add(d);
      }
    });


    return documents;
  }

  Widget getBody(BuildContext scaffoldC) {
    return FutureBuilder(
      future: getFlatList(),
      builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snaphot) {
        if(!snaphot.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos){
            return Divider(height: 1.0);
          },
          itemCount: snaphot.data.length,
          itemBuilder: (BuildContext context, int position) {
            Map<String, dynamic> request = snaphot.data[position].data;
            
          
            request['documentID'] = snaphot.data[position].documentID;
            return Dismissible(
              key: Key(snaphot.data[position].documentID),
              confirmDismiss: (direction) { return rejectRequest(request, scaffoldC);},
                          child: Card(
                child: ListTile(
                  title: Text(request['created_by']['name'] + '-' + request['created_by']['phone']),
                  subtitle: Text('Request for ' +  request['owner_flat_id']),
                  trailing: IconButton(icon:Icon(Icons.check), onPressed: () {acceptRequest(request, scaffoldC);},),
                  isThreeLine: true,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> rejectRequest(Map<String, dynamic> request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Rejecting request');
    Map<String, dynamic> updateData = {'status': globals.RequestStatus.Rejected.index};
    bool ret = await Firestore.instance.collection(globals.joinFlatLandlordTenant).document(request['documentID'].toString()).updateData(updateData).then((ret){
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request rejected successfully');
      return true;
    }).catchError((){
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while rejecting request');
      return false;
    });

    return ret;
    
  }

  void acceptRequest(Map<String, dynamic> request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');

    Map<String, dynamic> reqUpdateData = {'status': globals.RequestStatus.Accepted.index};

    WriteBatch batch = Firestore.instance.batch();

    DocumentReference reqDoc = Firestore.instance.collection(globals.joinFlatLandlordTenant).document(request['documentID'].toString());
    batch.updateData(reqDoc, reqUpdateData);


    DocumentReference propDoc;
    propDoc = Firestore.instance.collection(globals.ownerTenantFlat).document();
    
    
    Map<String, dynamic> reqData = {'owner_flat_id': request['owner_flat_id'].toString(), 'tenant_flat_id': request['tenant_flat_id'].toString(), 'status': 0};
    batch.setData(propDoc, reqData);

    QuerySnapshot s = await Firestore.instance.collection(globals.joinFlatLandlordTenant).where('owner_flat_id', isEqualTo: request['owner_flat_id'].toString()).where('status', isEqualTo: globals.RequestStatus.Pending.index).getDocuments();

    Map<String, dynamic> reqRejectData = {'status': globals.RequestStatus.Rejected.index};

    for(int i = 0; i < s.documents.length; i++) {
      if(s.documents[i].documentID != request['documentID'].toString()) {
        DocumentReference d = Firestore.instance.collection(globals.joinFlatLandlordTenant).document(s.documents[i].documentID);
        batch.updateData(d, reqRejectData);
      }
    }

    await batch.commit().then((ret){
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request accepted successfully');
    }).catchError((e){
      debugPrint(e.toString());
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while accepting request');
    });

    
  }

  


}