import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/screens/models/LandlordRequest.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/service/OwnerRequestsService.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';


/// list of requests sent by an owner requesting a user to be co-owner of a flat
class LandlordRequests extends StatefulWidget {

  final Owner user;

  final bool onlyNewRequests;



  LandlordRequests(this.user, this.onlyNewRequests);

  @override
  State<StatefulWidget> createState() {
    return LandlordRequestsState(this.user, this.onlyNewRequests);
  }

}

class LandlordRequestsState extends State<LandlordRequests> {

  final Owner user;

  bool loadingState = false;

  final bool onlyNewRequests;


  List<LandlordRequest> landlordRequests = new List();



  LandlordRequestsState(this.user, this.onlyNewRequests);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: this.onlyNewRequests?null: AppBar(
        title: Text('Owner Requests'),
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

  Stream<QuerySnapshot> getFlatList() {
    return Firestore.instance.collection(globals.ownerOwnerJoin)
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('toUserId', isEqualTo: this.user.getOwnerId()).snapshots();
  }

  Widget getBody(BuildContext scaffoldC) {
    return StreamBuilder (
      stream: getFlatList(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData) {
          return LoadingContainerVertical(2);
        }
        List<DocumentSnapshot> documents = snapshot.data.documents;
        return ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos){
            return Divider(height: 1.0);
          },
          itemCount: documents.length,
          itemBuilder: (BuildContext context, int position) {
            Map<String, dynamic> request = documents[position].data;
            LandlordRequest req = LandlordRequest.fromJson(request, documents[position].documentID);
            
            if(position == 0) {
              this.landlordRequests = new List();
            }

            this.landlordRequests.add(req);
            
            return Dismissible(
              key: Key(documents[position].documentID),
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
    bool ifSuccess = await OwnerRequestsService.rejectRequest(request);

    if(ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request rejected successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while rejecting request');
    }

    return ifSuccess;
    
  }

  void acceptRequest(LandlordRequest request, BuildContext scaffoldC) async {
    setState(() {
              this.loadingState = true;
            });
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');
    
    bool ifSuccess = await OwnerRequestsService.acceptRequestFromOwner(request);

    if(ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request accepted successfully');
      setState(() {
              this.loadingState = false;
            });
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while accepting request');
      setState(() {
              this.loadingState = false;
            });
    }

    
  }

  


}