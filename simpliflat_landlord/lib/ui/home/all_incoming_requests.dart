import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/ui/owner_requests/coowner_requests.dart';
import 'package:simpliflat_landlord/ui/owner_requests/landlord_requests.dart';
import 'package:simpliflat_landlord/ui/tenant_requests.dart/tenant_requests.dart';


class AllIncomingRequests extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
          child: Scaffold(
        appBar: AppBar(title: Text('Received requests', style: CommonWidgets.getAppBarTitleStyle()),
        elevation: 0, 
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
          User user = Provider.of<User>(context, listen: false);
          debugPrint('user id in incoming req - ' + user.getUserId());
          return getBody();
        }),
      ),
    );
  }

  Widget getBody() {
    return TabBarView(
      children: <Widget>[
        LandlordRequests(true),
        CoOwnerRequests(true),
        TenantRequests(true),
      ],
    );
  }

}