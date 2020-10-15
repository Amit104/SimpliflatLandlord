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
import 'package:simpliflat_landlord/view_model/landlord_requests_model.dart';


/// list of requests sent by an owner requesting a user to be co-owner of a flat
class LandlordRequests extends StatelessWidget {

  
  

  final bool onlyNewRequests;


  LandlordRequests(this.onlyNewRequests);

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    debugPrint('user in landlord requests - ' + user.getUserId());
    return ChangeNotifierProvider(
        create: (_) => LandlordRequestsModel(),
          child: Scaffold(
        appBar: this.onlyNewRequests?null: AppBar(
          title: Text('Owner Requests'),
          centerTitle: true,
          backgroundColor: Colors.white,
          
        ),
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext scaffoldC) {
          
          return getBody(scaffoldC, user);
        }),
      ),
    );
  }

  Widget getBody(BuildContext scaffoldC, User user) {
    return StreamBuilder (
      stream: LandlordRequestsDao.getRequestsSentToMeByOwner(user.getUserId()),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData) {
          return LoadingContainerVertical(2);
        }
        List<DocumentSnapshot> documents = snapshot.data.documents;
        return Consumer<LandlordRequestsModel>(
          builder: (BuildContext context, LandlordRequestsModel landlordRequestsModel, Widget child) {
            return landlordRequestsModel.load? LoadingContainerVertical(5):
            ListView.separated(
            separatorBuilder: (BuildContext ctx, int pos){
              return Divider(height: 1.0);
            },
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int position) {
              Map<String, dynamic> request = documents[position].data;
              LandlordRequest req = LandlordRequest.fromJson(request, documents[position].documentID);
              
              return Dismissible( //TODO: Dismissible giving error. Dont use it
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
          }   
        );
      },
    );
  }

  String getSubtitleText(LandlordRequest request) {
    return 'Request for flat ' + request.getFlatNumber();
  }

  Future<bool> rejectRequest(LandlordRequest request, BuildContext scaffoldC) async {

    Provider.of<LandlordRequestsModel>(scaffoldC, listen: false).startLoading();
    Utility.createErrorSnackBar(scaffoldC, error: 'Rejecting request');

    bool ifSuccess = await OwnerRequestsService.rejectRequest(request);

    if(ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request rejected successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while rejecting request');
    }

    Provider.of<LandlordRequestsModel>(scaffoldC, listen: false).stopLoading();
    return ifSuccess;
    
  }

  void acceptRequest(LandlordRequest request, BuildContext scaffoldC) async {

    Provider.of<LandlordRequestsModel>(scaffoldC, listen: false).startLoading();
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');
    
    bool ifSuccess = await OwnerRequestsService.acceptRequestFromOwner(request);

    if(ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request accepted successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while accepting request');
    }

    Provider.of<LandlordRequestsModel>(scaffoldC, listen: false).stopLoading();
    
  }

  


}