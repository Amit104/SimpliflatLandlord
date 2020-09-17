import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/models/Building.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import 'package:simpliflat_landlord/service/TenantRequestsService.dart';



///list of requests received from tenant
class TenantRequests extends StatefulWidget {

  final Owner user;
  
  final bool onlyNewRequests;

  TenantRequests(this.user, this.onlyNewRequests);

  @override
  State<StatefulWidget> createState() {
    return TenantRequestsState(this.user, this.onlyNewRequests);
  }

}

class TenantRequestsState extends State<TenantRequests> {

  final Owner user;

  bool loadingState = false;

  final bool onlyNewRequests;


  TenantRequestsState(this.user, this.onlyNewRequests);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: this.onlyNewRequests?null:AppBar(
        title: Text('Tenant Requests'),
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
    return Firestore.instance.collection(globals.joinFlatLandlordTenant).where('owner_id_list', arrayContains: this.user.getOwnerId())
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('request_from_tenant', isEqualTo: true).snapshots();

    
  }

  Widget getBody(BuildContext scaffoldC) {
    return StreamBuilder(
      stream: getFlatList(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snaphot) {
        if(!snaphot.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos){
            return Divider(height: 1.0);
          },
          itemCount: snaphot.data.documents.length,
          itemBuilder: (BuildContext context, int position) {
            Map<String, dynamic> request = snaphot.data.documents[position].data;
            
          
            request['documentID'] = snaphot.data.documents[position].documentID;
            return Dismissible(
              key: Key(snaphot.data.documents[position].documentID),
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
    
    bool ifSuccess = await TenantRequestsService.rejectTenantRequest(request);

    if(ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request rejected successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while rejecting request');
    }

    return ifSuccess;
    
  }

  void acceptRequest(Map<String, dynamic> request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');

    String docId = await TenantRequestsService.acceptTenantRequest(request);
    
    if(docId != null) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request accepted successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while accepting request');
    }

    
  }

  


}