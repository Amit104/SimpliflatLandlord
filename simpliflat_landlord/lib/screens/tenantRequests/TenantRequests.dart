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

  final Building building;

  final List<String> flatIds;

  //TODO: when changes are made in tenant app of adding owner ids in request. Then over here search using owner id.


  TenantRequests(this.user, this.building, this.flatIds);

  @override
  State<StatefulWidget> createState() {
    return TenantRequestsState(this.user, this.building, this.flatIds);
  }

}

class TenantRequestsState extends State<TenantRequests> {

  final Owner user;

  bool loadingState = false;

  final List<String> flatIds;

  final Building building;

  TenantRequestsState(this.user, this.building, this.flatIds);

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
    QuerySnapshot q = await Firestore.instance.collection(globals.joinFlatLandlordTenant).where('building_id', isEqualTo: this.building.getBuildingId())
    .where('status', isEqualTo: globals.RequestStatus.Pending.index)
    .where('request_from_tenant', isEqualTo: 1).getDocuments();

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

    bool ifSuccess = await TenantRequestsService.acceptTenantRequest(request);
    
    if(ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request accepted successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while accepting request');
    }

    
  }

  


}