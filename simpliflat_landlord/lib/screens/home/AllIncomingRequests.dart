import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/screens/models/Block.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/ownerRequests/CoOwnerRequests.dart';
import 'package:simpliflat_landlord/screens/ownerRequests/LandlordRequests.dart';
import 'package:simpliflat_landlord/screens/tenantRequests/TenantRequests.dart';


class AllIncomingRequests extends StatefulWidget {

  final Owner owner;

  AllIncomingRequests(this.owner);

  @override
  State<StatefulWidget> createState() {
    return AllIncomingRequestsState(this.owner);
  }
}

class AllIncomingRequestsState extends State<AllIncomingRequests> {

  @override
  void initState() {
    super.initState();
    
  }

  final Owner owner;

  

  AllIncomingRequestsState(this.owner);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
          child: Scaffold(
        appBar: AppBar(title: Text('Received requests'), 
        centerTitle: true, 
        backgroundColor: Colors.white,
        bottom: TabBar(
          indicatorColor: Colors.green,
          isScrollable: true,
          tabs: <Widget>[
            Tab(text: 'Owner Requests'),
            Tab(text: 'Co-owner Requests'),
            Tab(text: 'Tenant Requests'),
          ],
        ),),
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext scaffoldC) {
          return getBody();
        }),
      ),
    );
  }

  Widget getBody() {
    return TabBarView(
      children: <Widget>[
        LandlordRequests(this.owner, true),
        CoOwnerRequests(this.owner, true),
        TenantRequests(this.owner, true),
      ],
    );
  }

}