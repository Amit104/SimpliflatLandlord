import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/screens/createOrJoin/FlatList.dart';
import 'package:simpliflat_landlord/screens/flatSetup/AddTenant.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/home/AllIncomingRequests.dart';
import 'package:simpliflat_landlord/screens/models/Block.dart';
import 'package:simpliflat_landlord/screens/models/Building.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/models/OwnerFlat.dart';
import 'package:simpliflat_landlord/screens/ownerRequests/CoOwnerRequests.dart';
import 'package:simpliflat_landlord/screens/ownerRequests/CoOwnerRequestsBuildingList.dart';
import 'package:simpliflat_landlord/screens/ownerRequests/LandlordRequests.dart';
import 'package:simpliflat_landlord/screens/ownerRequests/SearchOwner.dart';
import 'package:simpliflat_landlord/screens/tenantRequests/SearchTenant.dart';
import 'package:simpliflat_landlord/screens/tenantRequests/TenantRequests.dart';
import 'package:simpliflat_landlord/screens/tenantRequests/TenantRequestsBuildingList.dart';
import 'package:simpliflat_landlord/screens/tenant_portal/tenant_portal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';

class Home extends StatefulWidget {
  final Owner user;

  Home(this.user);

  @override
  State<StatefulWidget> createState() {
    return HomeState(this.user);
  }
}

class HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    checkIfNewRequests();
  }

  final Owner user;

  bool requestsExist = true;

  bool loadingState = false;

  Map<String, bool> buildingExpanded = new Map();

  Map<String, bool> blocksExpanded = new Map();

  HomeState(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(),
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        return this.loadingState
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(child: getBody());
      }),
    );
  }

  Widget getBody() {
    return Column(children: [
      Container(
        margin: EdgeInsets.only(top: 20.0),
        child: Text('Your buildings'),
      ),
      Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: FutureBuilder(
            future: getBuildingList(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Building>> flats) {
              debugPrint('checking');
              if (!flats.hasData) {
                return LoadingContainerVertical(2);
              }
              debugPrint('build started');
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 350.0),
                child: SingleChildScrollView(
                  child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      bool bIdTemp =
                          buildingExpanded[flats.data[index].getBuildingId()];
                      if (bIdTemp == null) {
                        buildingExpanded[flats.data[index].getBuildingId()] =
                            true;
                      } else {
                        buildingExpanded[flats.data[index].getBuildingId()] =
                            !buildingExpanded[
                                flats.data[index].getBuildingId()];
                      }
                      setState(() {
                        buildingExpanded = buildingExpanded;
                      });
                    },
                    children: getBuildingListWidget(flats.data),
                  ),
                ),
              );
            }),
      ),
      getNewRequestsWidget()
    ],
    );
  }

  Widget getNewRequestsWidget() {
    debugPrint(this.requestsExist.toString());
    return this.requestsExist? Container(
      child: ListTile(
        onTap: () {
          Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return AllIncomingRequests(this.user);
        }),
      );
        },
        title:Text('You have new requests'),
      ),
    ):Container();
  }

  List<ExpansionPanel> getBuildingListWidget(List<Building> buildings) {
    List<ExpansionPanel> buildingsWidget = new List();
    for (int i = 0; i < buildings.length; i++) {
      buildingsWidget.add(new ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(buildings[i].getBuildingName()),
            subtitle: Text(buildings[i].getZipcode()),
          );
        },
        body: getBlocksListWidget(buildings[i]),
        isExpanded: buildingExpanded[buildings[i].getBuildingId()] == null
            ? false
            : buildingExpanded[buildings[i].getBuildingId()],
      ));
    }

    return buildingsWidget;
  }

  Widget getBlocksListWidget(Building b) {
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
        isExpanded: blocksExpanded[
                    b.getBuildingId() + '-' + blocks[i].getBlockName()] ==
                null
            ? false
            : blocksExpanded[
                b.getBuildingId() + '-' + blocks[i].getBlockName()],
      ));
    }
    return new ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) async {
        bool bIdTemp = blocksExpanded[
            b.getBuildingId() + '-' + blocks[index].getBlockName()];
        if (bIdTemp == null) {
          blocksExpanded[
              b.getBuildingId() + '-' + blocks[index].getBlockName()] = true;
        } else {
          blocksExpanded[
                  b.getBuildingId() + '-' + blocks[index].getBlockName()] =
              !blocksExpanded[
                  b.getBuildingId() + '-' + blocks[index].getBlockName()];
        }
        setState(() {
          blocksExpanded = blocksExpanded;
        });
      },
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
                navigateToLandlordPortal(flats[index]);
              },
              child: Text(flats[index].getFlatName()),
            ),
          );
        },
      ),
    );
  }

  void navigateToLandlordPortal(OwnerFlat flat) async {
    flat.setZipcode(flat.getBuildingDetails());
    QuerySnapshot q = await Firestore.instance
        .collection(globals.ownerTenantFlat)
        .where('ownerFlatId', isEqualTo: flat.getFlatId())
        .where('status', isEqualTo: 0)
        .getDocuments();
    //TODO: building address and zipcode are set only in case if owner and tenant apartment are linked. Need to set in other case too
    //Instead add building Address in flat
    if (q != null && q.documents.length > 0) {
      flat.setBuildingAddress(q.documents[0].data['buildingAddress']);
      flat.setZipcode(q.documents[0].data['zipcode']);
      flat.setTenantFlatId(q.documents[0].data['tenantFlatId']);
      flat.setTenantFlatName(q.documents[0].data['tenantFlatName']);
      flat.setApartmentTenantId(q.documents[0].documentID);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return LandlordPortal(flat, this.user);
        }),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return AddTenant(this.user, flat);
        }),
      );
    }
  }

  Future<List<Building>> getBuildingList() async {
    QuerySnapshot flats = await Firestore.instance
        .collection(globals.ownerFlat)
        .where('ownerIdList', arrayContains: this.user.getOwnerId())
        .getDocuments();

    List<DocumentSnapshot> allMyFlats = flats.documents;

    Map<String, Building> myBuildings = new Map();

    allMyFlats.forEach((DocumentSnapshot flatDoc) {
      OwnerFlat flat = OwnerFlat.fromJson(flatDoc.data, flatDoc.documentID);
      Building b = myBuildings[flat.getBuildingId()];
      if (b == null) {
        b = new Building();
        myBuildings[flat.getBuildingId()] = b;
        b.setZipcode(flat.getBuildingDetails());
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
                return SearchOwner(this.user, null);
              }),
            );
          },
        ),
        ListTile(
          title: Text('Owner requests'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return LandlordRequests(this.user, false);
              }),
            );
          },
        ),
        ListTile(
          title: Text('Co-Owner requests'),
          onTap: () async {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return CoOwnerRequests(this.user, false);
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
                return FlatList(this.user, false);
              }),
            );
          },
        ),
        ListTile(
          title: Text('Tenant requests'),
          onTap: () async {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return TenantRequests(this.user, false);
              }),
            );
          },
        ),
        ListTile(
          title: Text('Join property'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return FlatList(this.user, true);
              }),
            );
          },
        ),
        ListTile(
          title: Text('Add Tenant'),
          onTap: () async {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return SearchTenant(this.user, null);
              }),
            );
          },
        ),
      ],
    ));
  }

  void checkIfNewRequests() async {
    QuerySnapshot q = await Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('ownerIdList', arrayContains: this.user.getOwnerId())
        .limit(1)
        .getDocuments();
    if (q.documents.length > 0) {
      debugPrint("tenant requests found");
      this.requestsExist = true;
    } else {
      q = await Firestore.instance
          .collection(globals.ownerOwnerJoin)
          .where('status', isEqualTo: globals.RequestStatus.Pending.index)
          .where('ownerIdList', arrayContains: this.user.getOwnerId())
          .limit(1)
          .getDocuments();
      if (q.documents.length > 0) {
        debugPrint("owner requests found");
        this.requestsExist = true;
      }
    }
    if(mounted) {
      setState(() {
              this.requestsExist = this.requestsExist;
            });
    }
  }
}
