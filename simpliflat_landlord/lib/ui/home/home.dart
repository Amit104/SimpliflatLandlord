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
    /*return Column(children: [
      Container(
        margin: EdgeInsets.only(top: 20.0),
        child: Text('Your buildings'),
      ),
      ChangeNotifierProvider(
      create: (_) => HomeModelBuildingList(),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: FutureBuilder(
            future: getBuildingList(context),
            builder:
                (BuildContext context, AsyncSnapshot<List<Building>> flats) {
              if (!flats.hasData) {
                return LoadingContainerVertical(2);
              }
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 350.0),
                child: SingleChildScrollView(
                  child: Consumer<HomeModelBuildingList>(
                    builder: (BuildContext context, HomeModelBuildingList homeModelBuildingList, Widget child) {
                      return ExpansionPanelList(
                      expansionCallback: (int index, _) => Provider.of<HomeModelBuildingList>(context, listen: false).expandBuilding(flats.data[index].getBuildingId()),
                      children: getBuildingListWidget(flats.data, homeModelBuildingList, context));
                    },
                  ),
                ),
              );
            }),
      )),
      getNewRequestsWidget(context),
    ],
    );*/
  }

  Widget getNewRequestsWidget(BuildContext context) {
    return FutureBuilder(
      future: checkIfNewRequests(context),
      builder: (BuildContext context, AsyncSnapshot<bool> requestsExistsSnapshot) {
        if(requestsExistsSnapshot.connectionState == ConnectionState.waiting) {
          return LoadingContainerVertical(1);
        }

        return ListTile(
        onTap: () {
          User user = Provider.of<User>(context, listen: false);
          debugPrint('user id on tap - ' + user.getUserId());
          Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return AllIncomingRequests();
        }),
      );
        },
        title:Text('You have new requests'),
      );
      }
    );
  }

  List<ExpansionPanel> getBuildingListWidget(List<Building> buildings, HomeModelBuildingList homeModelBuildingList, BuildContext ctx) {
    List<ExpansionPanel> buildingsWidget = new List();
    for (int i = 0; i < buildings.length; i++) {
      buildingsWidget.add(new ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(buildings[i].getBuildingName()),
            subtitle: Text(buildings[i].getZipcode()),
          );
        },
        body: getBlocksListWidget(buildings[i], homeModelBuildingList, ctx),
        isExpanded: homeModelBuildingList.isBuildingExpanded(buildings[i].getBuildingId()),
      ));
    }

    return buildingsWidget;
  }

  Widget getBlocksListWidget(Building b, HomeModelBuildingList homeModelBuildingList, BuildContext ctx) {
    List<ExpansionPanel> blocksWidget = new List();
    List<Block> blocks = b.getBlocks();

    if (blocks == null || blocks.isEmpty) {
      return Container();
    }
    for (int i = 0; i < blocks.length; i++) {
      blocksWidget.add(new ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(blocks[i].blockName),
          );
        },
        body: getFlatNamesWidget(blocks[i]),
        isExpanded: homeModelBuildingList.isBlockExpanded(b.getBuildingId(), blocks[i].getBlockName()),
      ));
    }
    return new ExpansionPanelList(
      expansionCallback: (int index, _) => Provider.of<HomeModelBuildingList>(ctx, listen: false).expandBlock(b.getBuildingId(), blocks[index].getBlockName()),
      children: blocksWidget,
    );
  }

  Widget getFlatNamesWidget(Block block) {
    List<OwnerFlat> flats = block.getOwnerFlats();
    if (flats == null || flats.isEmpty) {
      return Container();
    }

    return Container(
      height: 50.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: flats.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            margin: EdgeInsets.all(5.0),
            color: Colors.grey[300],
            child: GestureDetector(
              onTap: () {
                navigateToLandlordPortal(flats[index], context);
              },
              child: Text(flats[index].getFlatName()),
            ),
          );
        },
      ),
    );
  }

  void navigateToLandlordPortal(OwnerFlat flat, BuildContext context) async {
    debugPrint("navigate to landlord portal");
    User user = Provider.of<User>(context, listen: false);
    QuerySnapshot q = await OwnerTenantDao.getByOwnerFlatId(flat.getFlatId());
    if (q != null && q.documents.length > 0) {
      flat.setTenantFlatId(q.documents[0].data['tenantFlatId']);
      flat.setTenantFlatName(q.documents[0].data['tenantFlatName']);
      flat.setApartmentTenantId(q.documents[0].documentID);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return LandlordPortal(flat);
        }),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return AddTenant(flat);
        }),
      );
    }
  }

  Future<List<Building>> getBuildingList(BuildContext context) async {
    User user = Provider.of<User>(context, listen: false);
    debugPrint('userid - ' + user.getUserId());
    QuerySnapshot flats = await OwnerFlatDao.getByOwnerId(user.getUserId());

    List<DocumentSnapshot> allMyFlats = flats.documents;

    Map<String, Building> myBuildings = new Map();

    allMyFlats.forEach((DocumentSnapshot flatDoc) {
      OwnerFlat flat = OwnerFlat.fromJson(flatDoc.data, flatDoc.documentID);
      Building b = myBuildings[flat.getBuildingId()];
      if (b == null) {
        b = new Building();
        myBuildings[flat.getBuildingId()] = b;
        b.setZipcode(flat.getZipcode());
        b.setBuildingName(flat.getBuildingName());
        b.setBuildingId(flat.getBuildingId());
      }

      List<Block> blocks = b.getBlocks();

      Block block;
      if (blocks != null) {
        block = blocks.firstWhere((Block b) {
          return b.getBlockName() == flat.getBlockName();
        }, orElse: () {
          return null;
        });
      } else {
        blocks = new List();
        b.setBlock(blocks);
      }

      if (block == null) {
        block = new Block();
        block.setBlockName(flat.getBlockName());
        blocks.add(block);
      }
      if (block != null) {
        if (block.getOwnerFlats() == null) {
          block.setOwnerFlats(new List());
        }
        block.getOwnerFlats().add(flat);
      }
    });

    debugPrint('returning data - ' + myBuildings.values.length.toString());

    List<Building> buildingsList = new List();
    myBuildings.forEach((String key, Building value) {
      buildingsList.add(value);
    });

    return buildingsList;
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

  Future<bool> checkIfNewRequests(BuildContext context) async {
    User user = Provider.of<User>(context, listen: false);
    QuerySnapshot q = await Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('ownerIdList', arrayContains: user.getUserId())
        .limit(1)
        .getDocuments();
    if (q.documents.length > 0) {
      debugPrint("tenant requests found");
      return true;
    } else {
      q = await Firestore.instance
          .collection(globals.ownerOwnerJoin)
          .where('status', isEqualTo: globals.RequestStatus.Pending.index)
          .where('ownerIdList', arrayContains: user.getUserId())
          .limit(1)
          .getDocuments();
      if (q.documents.length > 0) {
        debugPrint("owner requests found");
        return true;
      }
    }
    return false;
  }
}
