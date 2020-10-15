import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/dao/tenant_requests_dao.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/services/tenant_requests_service.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';



///list of requests received from tenant
class TenantRequests extends StatelessWidget {

  
  final bool onlyNewRequests;

  TenantRequests(this.onlyNewRequests);

 
  @override
  Widget build(BuildContext context) {
    return
        ChangeNotifierProvider(
          create: (_) => LoadingModel(),
          child: Scaffold(
      appBar: this.onlyNewRequests?null:AppBar(
        title: Text('Tenant Requests'),
        centerTitle: true,
        backgroundColor: Colors.white,
        
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
         return getBody(scaffoldC);
      }),
    ));
  }

  Widget getBody(BuildContext scaffoldC) {
    User user = Provider.of<User>(scaffoldC, listen: false);
    return StreamBuilder(
      stream: TenantRequestsDao.getAllReceivedRequests(user.getUserId()),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snaphot) {
        if(!snaphot.hasData) {
          return LoadingContainerVertical(2);
        }
        return Consumer<LoadingModel>(
            builder: (BuildContext context, LoadingModel loadingModel, Widget child) {
              return loadingModel.load? LoadingContainerVertical(3):
                  ListView.separated(
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
            });
      },
    );
  }

  Future<bool> rejectRequest(Map<String, dynamic> request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Rejecting request');
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();
    bool ifSuccess = await TenantRequestsService.rejectTenantRequest(request);

    if(ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request rejected successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while rejecting request');
    }

    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();
    return ifSuccess;
    
  }

  void acceptRequest(Map<String, dynamic> request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();


    String docId = await TenantRequestsService.acceptTenantRequest(request);
    
    if(docId != null) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request accepted successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while accepting request');
    }

    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();


    
  }

  


}