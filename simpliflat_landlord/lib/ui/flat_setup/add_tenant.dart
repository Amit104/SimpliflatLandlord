import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/dao/tenant_requests_dao.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/ui/tenant_portal/tenant_portal.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/ui/tenant_requests.dart/search_tenant.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/services/tenant_requests_service.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';


/// page displayed when no tenant flat is present for an owner flat
class AddTenant extends StatefulWidget {

  final OwnerFlat flat;

  AddTenant(this.flat);

  @override
  State<StatefulWidget> createState() {
    return AddTenantState(this.flat);
  }
}

class AddTenantState extends State<AddTenant> {
  @override
  void initState() {
    super.initState();
  }


  final OwnerFlat flat;

  AddTenantState(this.flat);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
          create: (_) => LoadingModel(),
          child: Scaffold(
      appBar: AppBar(
        title: Text('Flat'),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getAddTenantTile(),
        SizedBox(height:20.0),
        Container(alignment: Alignment.center, child: Text('Requests by you')),
        getRequestsSentListWidget(scaffoldC),
        SizedBox(height:20.0),
        Container(alignment: Alignment.center, child: Text('Requests for you')),
        getRequestsReceivedListWidget(scaffoldC),
      ],
    );
  }

  Widget getRequestsReceivedListWidget(BuildContext scaffoldC) {
    return StreamBuilder(
      stream: TenantRequestsDao.getReceivedRequestsForFlat(this.flat.getFlatId()),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snaphot) {
        if (!snaphot.hasData) {
          return LoadingContainerVertical(2);
        }
        return Consumer<LoadingModel>(
          builder: (BuildContext context, LoadingModel loadingModel, Widget child) {
            return loadingModel.load? LoadingContainerVertical(3):
                  ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (BuildContext ctx, int pos) {
              return Divider(height: 1.0);
            },
            itemCount: snaphot.data.documents.length,
            itemBuilder: (BuildContext context, int position) {
              Map<String, dynamic> request =
                  snaphot.data.documents[position].data;

              request['documentID'] = snaphot.data.documents[position].documentID;
              return Dismissible(
                key: Key(snaphot.data.documents[position].documentID),
                confirmDismiss: (direction) {
                  return rejectRequest(request, scaffoldC);
                },
                child: Card(
                  child: ListTile(
                    title: Text(request['created_by']['name'] +
                        ' - ' + '+916722626266'+
                        request['created_by']['phone']),
                    subtitle: Text('Request by ' + request['tenant_flat_name']),
                    trailing: IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        acceptRequest(request, scaffoldC);
                      },
                    ),
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

  Widget getAddTenantTile() {
    return Container(
      decoration: getGradientBackground(),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40.0),
      child: GestureDetector(
        child: Text('Add Tenant'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return SearchTenant(this.flat);
            }),
          );
        },
      ),
    );
  }

  Widget getRequestsSentListWidget(BuildContext scaffoldC) {
    return StreamBuilder(
      stream: TenantRequestsDao.getSentRequestsForFlat(this.flat.getFlatId()),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData) {
          return LoadingContainerVertical(2);
        }

        return Consumer<LoadingModel>(
          builder: (BuildContext context, LoadingModel loadingModel, Widget child) {
            return loadingModel.load? LoadingContainerVertical(3):
        ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (BuildContext context, int pos) {
            return Card(
                          child: Dismissible(
                key: Key(snapshot.data.documents[pos].documentID),
                child: ListTile(
                  title:
                      Text(snapshot.data.documents[pos].data['tenant_flat_name']),
                ),
                onDismissed: (var dir) {
                  deleteRequestSentToTenant(
                      snapshot.data.documents[pos], scaffoldC);
                },
              ),
            );
          },
        );
          });
      },
    );
  }

  void deleteRequestSentToTenant(
      DocumentSnapshot doc, BuildContext scaffoldC) async {
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();

    bool ifSuccess = await TenantRequestsService.deleteRequestSentToTenant(doc.documentID);
    if(ifSuccess) {
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Request deleted successfully');
    } else {
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Error while deleting request');
    }
    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();

  }

  BoxDecoration getGradientBackground() {
    return new BoxDecoration(
      gradient: new LinearGradient(
          colors: [
            const Color(0xFF00CCFF),
            const Color(0xFF00CCFF),
          ],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp),
    );
  }

  Future<bool> rejectRequest(
      Map<String, dynamic> request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Rejecting request');
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();
    
    bool ifSuccess = await TenantRequestsService.rejectTenantRequest(request);

    if(ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Request rejected successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Error while rejecting request');
    }
    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();

    return ifSuccess;
  }

  void acceptRequest(
      Map<String, dynamic> request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();

    String docId = await TenantRequestsService.acceptTenantRequest(request);

    if (docId != null) {
      flat.setBuildingAddress(request['building_details']['building_address']);
      flat.setTenantFlatId(request['tenant_flat_id']);
      flat.setTenantFlatName(request['tenant_flat_name']);
      flat.setApartmentTenantId(docId);
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Request accepted successfully');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return LandlordPortal(this.flat);
        }),
      );
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Error while accepting request');
    }

    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();

  }
}
