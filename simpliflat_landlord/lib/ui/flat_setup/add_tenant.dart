import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/dao/owner_tenant_dao.dart';
import 'package:simpliflat_landlord/dao/tenant_requests_dao.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/owner_tenant.dart';
import 'package:simpliflat_landlord/model/tenant.dart';
import 'package:simpliflat_landlord/model/tenant_flat.dart';
import 'package:simpliflat_landlord/model/tenant_request.dart';
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
        getRequestsSentListWidget(scaffoldC),
        SizedBox(height:20.0),
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

        if(snaphot.data.documents.length == 0) {
          return Container();
        }
        return Consumer<LoadingModel>(
          builder: (BuildContext context, LoadingModel loadingModel, Widget child) {
            if(loadingModel.load) return LoadingContainerVertical(3);

            List<TenantRequest> tenantRequests = snaphot.data.documents.map((DocumentSnapshot doc) => TenantRequest.fromJson(doc.data, doc.documentID)).toList();
            return Column(children: [
                Container(alignment: Alignment.center, child: Text('Requests by you')),

                  ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (BuildContext ctx, int pos) {
              return Divider(height: 1.0);
            },
            itemCount: tenantRequests.length,
            itemBuilder: (BuildContext context, int position) {
              
              return Dismissible(
                key: Key(tenantRequests[position].getRequestId()),
                confirmDismiss: (direction) {
                  return rejectRequest(tenantRequests[position], scaffoldC);
                },
                child: Card(
                  child: ListTile(
                    title: Text(tenantRequests[position].getCreatedByUserName() +
                        ' - ' + 
                        tenantRequests[position].getCreatedByUserPhone()),
                    subtitle: Text('Request by ' + tenantRequests[position].getTenantFlatName()),
                    trailing: IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        acceptRequest(tenantRequests[position], scaffoldC);
                      },
                    ),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          )]);
          });
      },
    );
  }

  Widget getAddTenantTile() {
    return Container(
      color: Color(0xff2079FF),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(40.0),
      child: GestureDetector(
        child: Text('Add Tenant', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20.0, color: Colors.white)),
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
        if(snapshot.data.documents.length == 0) {
          return Container();
        }

        List<TenantRequest> tenantRequests = snapshot.data.documents.map((DocumentSnapshot doc) => TenantRequest.fromJson(doc.data, doc.documentID)).toList();

        return Consumer<LoadingModel>(
          builder: (BuildContext context, LoadingModel loadingModel, Widget child) {
            return loadingModel.load? LoadingContainerVertical(3):

        Column(children: [
                Container(alignment: Alignment.center, child: Text('Requests by you')),

        ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos) {
              return Divider(height: 1.0);
            },
          shrinkWrap: true,
          itemCount: tenantRequests.length,
          itemBuilder: (BuildContext context, int pos) {
            return Card(
                          child: Dismissible(
                key: Key(tenantRequests[pos].getRequestId()),
                child: ListTile(
                  title:
                      Text(tenantRequests[pos].getTenantFlatName()),
                ),
                onDismissed: (var dir) {
                  deleteRequestSentToTenant(
                      tenantRequests[pos], scaffoldC);
                },
              ),
            );
          },
        )]);
          });
      },
    );
  }

  void deleteRequestSentToTenant(
      TenantRequest req, BuildContext scaffoldC) async {
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();

    bool ifSuccess = await TenantRequestsService.deleteRequestSentToTenant(req.getRequestId());
    if(ifSuccess) {
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Request deleted successfully');
    } else {
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Error while deleting request');
    }
    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();

  }

  Future<bool> rejectRequest(
      TenantRequest request, BuildContext scaffoldC) async {
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
      TenantRequest request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();

    String docId = await TenantRequestsService.acceptTenantRequest(request);

    if (docId != null) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Request accepted successfully');

      QuerySnapshot q = await OwnerTenantDao.getByOwnerFlatId(this.flat.getFlatId());
    if (q != null && q.documents.length > 0) {
      TenantFlat tenantFlat = new TenantFlat();
      tenantFlat.setFlatId(q.documents[0].data['tenantFlatId']);
      tenantFlat.setFlatName(q.documents[0].data['tenantFlatName']);
      tenantFlat.setTenants(getTenants(q));
      OwnerTenant ownerTenantFlat = new OwnerTenant();
      ownerTenantFlat.setOwnerFlat(this.flat);
      ownerTenantFlat.setStatus(0);
      ownerTenantFlat.setTenantFlat(tenantFlat);
      ownerTenantFlat.setOwnerTenantId(q.documents[0].documentID);      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return LandlordPortal(ownerTenantFlat);
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

  List<Tenant> getTenants(QuerySnapshot snapshot) {
    Map<String, dynamic> doc = snapshot.documents[0].data;
    List<Tenant> tenants = new List();
    doc.forEach((String key, dynamic value) {
      if(key.startsWith("t_")) {
        String tenantId = key.substring(2);
        Tenant tenant = new Tenant();
        tenant.setTenantId(tenantId);
        tenant.setName(value.toString().split("::")[0]);
        tenants.add(tenant);
      }
    });
    return tenants;

  }
}
