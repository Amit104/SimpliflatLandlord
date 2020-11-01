import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/dao/owner_tenant_dao.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/ui/common_screens/my_building_list.dart';
import 'package:simpliflat_landlord/ui/create_or_join/flat_list.dart';
import 'package:simpliflat_landlord/ui/flat_setup/add_tenant.dart';
import 'package:simpliflat_landlord/ui/home/all_incoming_requests.dart';
import 'package:simpliflat_landlord/ui/owner_requests/coowner_requests.dart';
import 'package:simpliflat_landlord/ui/owner_requests/landlord_requests.dart';
import 'package:simpliflat_landlord/ui/owner_requests/search_owner.dart';
import 'package:simpliflat_landlord/ui/tenant_portal/tenant_portal.dart';
import 'package:simpliflat_landlord/ui/tenant_requests.dart/search_tenant.dart';
import 'package:simpliflat_landlord/ui/tenant_requests.dart/tenant_requests.dart';
import 'package:simpliflat_landlord/view_model/home_model.dart';

class Home extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    
          return Scaffold(
        drawer: getDrawer(context),
        appBar: AppBar(
          title: Text('Home', style: CommonWidgets.getAppBarTitleStyle(),),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext scaffoldC) {
          return SingleChildScrollView(child: getBody(context));
        }),
      
    );
  }

  Widget getBody(BuildContext context) {
    return Container();
  }

  Widget getDrawer(BuildContext context) {
    return Container(
          width: 300,
          child: Drawer(
        elevation: 0,
          child: ListView(
        children: <Widget>[
          Container(
            color: Colors.blue,
            child: DrawerHeader(
              margin: EdgeInsets.all(0),
              child: CircleAvatar(
                            backgroundColor: Colors.indigo[900],
                            radius: 30.0,
                            child: Icon(Icons.home,
                                color: Colors.white, size: 50.0)),
            ),
          ),
          Container(
              decoration: BoxDecoration(color: Colors.white),
                    child: ListTile(
            title: Text('Add Owner'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SearchOwner(null);
                }),
              );
            },
          )),
          Container(
              decoration: BoxDecoration(color: Colors.white),
                    child: 
          ListTile(
            title: Text('Create property'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return FlatList(false);
                }),
              );
            },
          )),
          Container(
              decoration: BoxDecoration(color: Colors.white),
                    child: 
          ListTile(
            title: Text('Join property'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return FlatList(true);
                }),
              );
            },
          )),
          Container(
              decoration: BoxDecoration(color: Colors.white),
                    child: ListTile(
              title: Text('Add Tenant'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SearchTenant(null);
                  }),
                );
              },
            ),
          ),
          Container(
              decoration: BoxDecoration(color: Colors.white),
                    child: ListTile(
              title: Text('Incoming Requests'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AllIncomingRequests();
                  }),
                );
              },
            ),
          ),
          Container(
              decoration: BoxDecoration(color: Colors.white),
                    child: ListTile(
              title: Text('My flats'),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return MyBuildingList(null, null, true);
                  }),
                );
              },
            ),
          ),
        ],
      )),
    );
  }
}
