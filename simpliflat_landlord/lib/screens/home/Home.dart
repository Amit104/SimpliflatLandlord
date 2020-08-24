  import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/utility.dart';
import '../flatSetup/SearchOwner.dart';
import '../flatSetup/LandlordRequests.dart';
import '../flatSetup/createProperty.dart';
import '../flatSetup/FlatList.dart';
import '../flatSetup/TenantRequests.dart';
import '../models/OwnershipDetailsDBHandler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import '../flatSetup/TenantRequestsBuildingList.dart';


class Home extends StatefulWidget {

  final String userId;
 

  Home(this.userId);

  @override
  State<StatefulWidget> createState() {
    return HomeState(this.userId);
  }
}

class HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();
    
  }

  
  final String userId;

  bool loadingState = false;


  HomeState(this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(),
      appBar: AppBar(title: Text('Home'), centerTitle: true, backgroundColor: Colors.white,),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        return this.loadingState?Container(alignment: Alignment.center, child: CircularProgressIndicator(),):getBody();
      }),
    );
  }

  Widget getBody() {
    return Container(
      child: FutureBuilder(
        future: OwnershipDetailsDBHelper.instance.queryAllOwnerFlats(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> flats) {
          if(!flats.hasData)
            return LoadingContainerVertical(2);

          return ListView.builder(
            itemCount: flats.data.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(flats.data[index]['flatName'].toString()),
              );
            },
          );
        }
      ),
    );
  }

  Widget getDrawer() {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Container(),
              decoration: BoxDecoration(
                color: Colors.blue[100],
              ),
            ),
            ListTile(
              title: Text('Add Owner'),
              onTap: () {
                Navigator.pop(context);
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SearchOwner(this.userId, false);
                  }),
                 );

              },
            ),
            ListTile(
              title: Text('Co-Owner requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return LandlordRequests(this.userId);
                  }),
                 );

              },
            ),
            ListTile(
              title: Text('Create property'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return CreateProperty(this.userId, null, true, false);
                  }),
                 );

              },
            ),
            ListTile(
              title: Text('Tenant requests'),
              onTap: () async {
                Navigator.pop(context);
                setState(() {
                                  this.loadingState = true;
                                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return TenantRequestBuildingList(this.userId);
                  }),
                 );

              },
            ),
            /*ListTile(
              title: Text('Join property'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return FlatList(this.userId, true, null);
                  }),
                 );

              },
            )*/
          ],
        ));
  }

}
  
  