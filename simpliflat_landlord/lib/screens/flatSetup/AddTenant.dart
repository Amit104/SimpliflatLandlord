import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/models/OwnerFlat.dart';
import 'package:simpliflat_landlord/screens/tenantRequests/SearchTenant.dart';
import 'package:simpliflat_landlord/screens/tenant_portal/tenant_portal.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import 'package:simpliflat_landlord/service/TenantRequestsService.dart';


/// page displayed when no tenant flat is present for an owner flat
class AddTenant extends StatefulWidget {
  final Owner user;

  final OwnerFlat flat;

  AddTenant(this.user, this.flat);

  @override
  State<StatefulWidget> createState() {
    return AddTenantState(this.user, this.flat);
  }
}

class AddTenantState extends State<AddTenant> {
  @override
  void initState() {
    super.initState();
  }

  final Owner user;

  final OwnerFlat flat;

  AddTenantState(this.user, this.flat);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flat'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        return getBody(scaffoldC);
      }),
    );
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

  Stream<QuerySnapshot> getRequestsReceivedList() {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('owner_flat_id', isEqualTo: this.flat.getFlatId())
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('request_from_tenant', isEqualTo: true)
        .snapshots();
  }

  Widget getRequestsReceivedListWidget(BuildContext scaffoldC) {
    return StreamBuilder(
      stream: getRequestsReceivedList(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snaphot) {
        if (!snaphot.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.separated(
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
              return SearchTenant(this.user, this.flat);
            }),
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> getRequestsSentList() {
    return Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('owner_flat_id', isEqualTo: this.flat.getFlatId())
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('request_from_tenant', isEqualTo: false)
        .snapshots();
  }

  Widget getRequestsSentListWidget(BuildContext scaffoldC) {
    return StreamBuilder(
      stream: getRequestsSentList(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.builder(
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
      },
    );
  }

  void deleteRequestSentToTenant(
      DocumentSnapshot doc, BuildContext scaffoldC) async {

    bool ifSuccess = await TenantRequestsService.deleteRequestSentToTenant(doc.documentID);
    if(ifSuccess) {
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Request deleted successfully');
    } else {
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Error while deleting request');
    }
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

    return ifSuccess;
  }

  void acceptRequest(
      Map<String, dynamic> request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');

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
          return LandlordPortal(this.flat, this.user);
        }),
      );
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Error while accepting request');
    }
  }
}
