import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/dao/landlord_requests_dao.dart';
import 'package:simpliflat_landlord/model/landlord_request.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/services/owner_requests_service.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';


/// list of requests sent by users requesting owners of a flat to add them as a co-owner
class CoOwnerRequests extends StatelessWidget {

  final bool onlyNewRequests;

  CoOwnerRequests(this.onlyNewRequests);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
          create: (_) => LoadingModel(),
          child: Scaffold(
      appBar: this.onlyNewRequests?null:AppBar(
        title: Text('Co-owner requests'),
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
    return StreamBuilder (
      stream: LandlordRequestsDao.getAllReceivedRequestsFromCoowners(user.getUserId()),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData) {
          return LoadingContainerVertical(2);
        }
        List<DocumentSnapshot> documents = snapshot.data.documents;
        return Consumer<LoadingModel>(
            builder: (BuildContext context, LoadingModel loadingModel, Widget child) {
              return loadingModel.load? LoadingContainerVertical(3):
                  ListView.separated(
            separatorBuilder: (BuildContext ctx, int pos){
              return Divider(height: 1.0);
            },
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int position) {
              Map<String, dynamic> request = documents[position].data;
              LandlordRequest req = LandlordRequest.fromJson(request, documents[position].documentID);
              
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
            });
      },
    );
  }

  String getSubtitleText(LandlordRequest request) {
    return 'Request for flat ' + request.getFlatNumber() == null?'':request.getFlatNumber();
  }

  Future<bool> rejectRequest(LandlordRequest request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Rejecting request');
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();
    bool ifSuccess = await OwnerRequestsService.rejectRequest(request);

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

  void acceptRequest(LandlordRequest request, BuildContext scaffoldC) async {
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');
    
    bool ifSuccess = await OwnerRequestsService.acceptRequestFromCoOwner(request);

    if(ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request accepted successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while accepting request');
    }

    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();

    
  }

  


}