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



class LandlordRequests extends StatefulWidget {

  final String userId;



  LandlordRequests(this.userId);

  @override
  State<StatefulWidget> createState() {
    return LandlordRequestsState(this.userId);
  }

}

class LandlordRequestsState extends State<LandlordRequests> {

  final String userId;

  bool loadingState = false;


  List<LandlordRequest> landlordRequests = new List();



  LandlordRequestsState(this.userId);

  @override
  Widget build(BuildContext context) {
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
    QuerySnapshot q = await Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('toUserId', isEqualTo: this.userId).getDocuments();

 
    debugPrint(q.documents.length.toString());

    



    return q.documents;
  }

  Widget getBody(BuildContext scaffoldC) {
    return FutureBuilder(
      future: getFlatList(),
      builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if(!snapshot.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos){
            return Divider(height: 1.0);
          },
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int position) {
            Map<String, dynamic> request = snapshot.data[position].data;
            LandlordRequest req = LandlordRequest.fromJson(request, snapshot.data[position].documentID);
            
            if(position == 0) {
              this.landlordRequests = new List();
            }

            this.landlordRequests.add(req);
            
            return Dismissible(
              key: Key(snapshot.data[position].documentID),
              confirmDismiss: (direction) { return rejectRequest(req, scaffoldC);},
                          child: Card(
                child: ListTile(
                  title: Text(req.getRequesterUserName() + ' ' + req.getRequesterPhone()),
                  subtitle: Text(getSubtitleText(req)),
                  trailing: IconButton(icon:Icon(Icons.check), onPressed: () {acceptRequest(req, scaffoldC);},),
                  isThreeLine: true,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String getSubtitleText(LandlordRequest request) {
    return 'Request for flat ' + request.getFlatNumber();
  }

  Future<bool> rejectRequest(LandlordRequest request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Rejecting request');
    Map<String, dynamic> updateData = {'status': globals.RequestStatus.Rejected.index};
    bool ret = await Firestore.instance.collection(globals.ownerOwnerJoin).document(request.getRequestId()).updateData(updateData).then((ret){
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

  void acceptRequest(LandlordRequest request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');
    Map<String, dynamic> reqUpdateData = {'status': globals.RequestStatus.Accepted.index};

    WriteBatch batch = Firestore.instance.batch();

    DocumentReference reqDoc = Firestore.instance.collection(globals.ownerOwnerJoin).document(request.getRequestId());
    batch.updateData(reqDoc, reqUpdateData);

    DocumentReference propDoc;
    propDoc = Firestore.instance.collection(globals.ownerFlat).document(request.getFlatId());
    
    
    Map<String, dynamic> propUpdateData = {'ownerIdList': FieldValue.arrayUnion([request.getToUserId()]), 'ownerRoleList': FieldValue.arrayUnion([request.getToUserId() + ':' + globals.OwnerRoles.Manager.index.toString()])};
    batch.updateData(propDoc, propUpdateData);
    await batch.commit().then((ret){
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request accepted successfully');
      setState(() {
              this.loadingState = false;
            });
    }).catchError((e){
      debugPrint(e.toString());
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while accepting request');
      this.loadingState = false;
    });

    
  }

  


}