import 'package:flutter/material.dart';
import './CreateBuilding.dart';
import '../models/Building.dart';
import './CreateBlock.dart';
import '../models/Block.dart';
import '../models/OwnerFlat.dart';
import './CreateFlats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'dart:convert';
import 'package:simpliflat_landlord/screens/utility.dart';
import '../models/LandlordRequest.dart';
import '../models/Owner.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import '../home/Home.dart';
import '../models/TenantFlat.dart';

class CreateTenantRequest extends StatefulWidget {
  final String userId;



  final TenantFlat tenantFlat;

  final Building building;

  CreateTenantRequest(this.userId, this.building, this.tenantFlat);

  @override
  State<StatefulWidget> createState() {
    return CreateTenantRequestState(
        this.userId, this.building, this.tenantFlat);
  }
}

class CreateTenantRequestState extends State<CreateTenantRequest> {
  @override
  void initState() {
    super.initState();
  }

  bool buildingsExpanded = false;
  bool flatExpanded = false;
  final String userId;

  bool loadingState = false;


  Building building;


  Map<String, bool> blocksExpanded = new Map();

  TenantFlat tenantFlat;

  CreateTenantRequestState(this.userId, this.building, this.tenantFlat) {
    if(this.building != null) {
      for (int i = 0; i < this.building.getBlocks().length; i++) {
        this.blocksExpanded[this.building.getBlocks()[i].getBlockName()] =
            false;
      }
      this.buildingsExpanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Add Tenant'),
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          return loadingState
              ? Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator())
              : Container(
                  child: SingleChildScrollView(
                          child: Column(children: [
                            getBody(scaffoldC),
                          ]),
                        ),
                );
        }));
  }

  Widget getBody(BuildContext scaffoldContext) {
    
        return getMainExpansionPanelList(scaffoldContext);

  }


  Widget getMainExpansionPanelList(
      BuildContext scaffoldC) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        debugPrint(isExpanded.toString());
        setState(() {
          buildingsExpanded = !buildingsExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(this.building.getBuildingName()),
            );
          },
          body: getBlocksListWidget(scaffoldC),
          isExpanded: buildingsExpanded,
        ),
      ],
    );
  }



  Future<QuerySnapshot> getExistingRequestsData() {
    Query q = Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .where('buildingId', isEqualTo: this.building.getBuildingId());

    return q.getDocuments();
  }

  Widget getBlocksListWidget(
      BuildContext scaffoldC) {
    List<ExpansionPanel> blocksWidget = new List();
    List<Block> blocks = this.building.getBlocks();
    debugPrint('blocks is empty');

    if (blocks == null || blocks.isEmpty) {
      return Container();
    }
    debugPrint('blocks is not empty');
    for (int i = 0; i < blocks.length; i++) {
      blocksWidget.add(new ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(blocks[i].blockName),
          );
        },
        body: getFlatNamesWidget(blocks[i], scaffoldC),
        isExpanded: blocksExpanded[blocks[i].getBlockName()],
      ));
    }
    return new ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) async {
        debugPrint("blocks expanded");
        setState(() {
          blocksExpanded[blocks[index].getBlockName()] =
              !blocksExpanded[blocks[index].getBlockName()];
        });
      },
      children: blocksWidget,
    );
  }

  Widget getFlatNamesWidget(
      Block block, BuildContext ctx) {
    List<OwnerFlat> flats = block.getOwnerFlats();
    if (flats == null || flats.isEmpty) {
      return Container();
    }

    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int position) {
        return Divider(height: 1.0);
      },
      itemCount: flats.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(flats[index].getFlatName()),
          trailing: IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    sendRequestToTenant(ctx,
                        forFlat: true, block: block, flat: flats[index]);
                  },
                ),
        );
      },
    );
  }

  void sendRequestToTenant(BuildContext ctx,
      {bool forFlat, Block block, OwnerFlat flat}) async {
    setState(() {
      this.loadingState = false;
    });

    QuerySnapshot s =await Firestore.instance.collection(globals.ownerTenantFlat).where('owner_flat_id', isEqualTo: flat.getFlatId()).where('status', isEqualTo: 0).getDocuments();

    if(s.documents.length > 0) {
      showDialog(
        context: context,
        barrierDismissible: true,
        child: AlertDialog(
          title: Text('Warning'),
          content: Text('The flat is already assigned to someone. Continue?'),
          actions: <Widget>[
            RaisedButton(child: Text('Confirm'), onPressed: () {
              createTenantRequest(ctx, block, flat);
              Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
            },),
            RaisedButton(child: Text('Cancel'), onPressed: () {
              Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
            },)
          ],
        ),
      );
    }


  }

  void createTenantRequest(BuildContext ctx, Block block, OwnerFlat ownerFlat) async {

    String phoneNumber = await Utility.getUserPhone();
    String userName = await Utility.getUserName();

    Map<String, dynamic> newReq = {
          'building_id' : this.building.getBuildingId(),
          'block_id' : block.getBlockName(),
          'owner_flat_id' : ownerFlat.getFlatId(),
          'tenant_flat_id': this.tenantFlat.getFlatId(),
          'request_from_tenant': 1,
          'status': 0,
          'created_at': Timestamp.now(),
          'updated_at': Timestamp.now(),
          'created_by' : { "user_id" : this.userId, 'name' : userName, 'phone' : phoneNumber },
          'tenant_flat_name' : this.tenantFlat.getFlatName(),
          'building_details' : {'building_name' : this.building.getBuildingName(),'building_zipcode' : this.building.getZipcode(),'building_address' : ''} ,
        };


    Firestore.instance
        .collection(globals.joinFlatLandlordTenant)
        .add(newReq)
        .then((value) {
      setState(() {
        this.loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Request created successfully');
        Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Home(this.userId);
        }),
      );
      
    }).catchError((e) {
      setState(() {
        this.loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Error while creating request');
    });
  }
}
