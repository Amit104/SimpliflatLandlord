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

class RequestForCoOwner extends StatefulWidget {
  final String userId;

  Building building;

  RequestForCoOwner(this.userId, this.building);

  @override
  State<StatefulWidget> createState() {
    return RequestForCoOwnerState(
        this.userId, this.building);
  }
}

class RequestForCoOwnerState extends State<RequestForCoOwner> {
  @override
  void initState() {
    super.initState();
  }

  bool buildingsExpanded = false;
  bool flatExpanded = false;
  final String userId;
  Building building;

  bool loadingState = false;

  Map<String, bool> blocksExpanded = new Map();

  RequestForCoOwnerState(this.userId, this.building) {
    if(this.building != null) {
      for (int i = 0; i < this.building.getBlocks().length; i++) {
        this.blocksExpanded[this.building.getBlocks()[i].getBlockName()] =
            false;
      }
      this.buildingsExpanded = true;
    }
    debugPrint("in constructor");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Add Owner'),
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          return loadingState
              ? Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator())
              : Container(
                  child: building == null
                      ? Container()
                      : SingleChildScrollView(
                          child: Column(children: [
                            getMainExpansionPanelListForJoin(scaffoldC),
                          ]),
                        ),
                );
        }));
  }

  Widget getMainExpansionPanelList(
      BuildContext scaffoldC, List<DocumentSnapshot> data) {
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
              title: Text(building.getBuildingName()),
            );
          },
          body: getBlocksListWidget(scaffoldC, data),
          isExpanded: buildingsExpanded,
        ),
      ],
    );
  }


  bool isOwnerOfFlat(OwnerFlat flat) {
    
      if (flat.getOwnerIdList().contains(this.userId)) {
        return true;
      }
    

    return false;
  }

  bool ifRequestToFlatAlreadySent(List<DocumentSnapshot> data, String flatId) {
    if (data == null || data.isEmpty || flatId == null) {
      return false;
    }

    DocumentSnapshot d = data.firstWhere((request) {
     
        return request['flatId'] == flatId;
      
    }, orElse: () {
      return null;
    });
    return d != null;
  }

  Future<QuerySnapshot> getExistingRequestsData() {
    Query q = Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .where('requesterId', isEqualTo: this.userId)
        .where('status', isEqualTo: globals.RequestStatus.Pending.index)
        .where('requestToOwner', isEqualTo: true);

    return q.getDocuments();
  }

  Widget getMainExpansionPanelListForJoin(BuildContext scaffoldC) {
    return FutureBuilder(
      future: getExistingRequestsData(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> documents) {
        if (!documents.hasData) {
          return LoadingContainerVertical(2);
        }
        return getMainExpansionPanelList(scaffoldC, documents.data.documents);
      },
    );
  }

  Widget getBlocksListWidget(
      BuildContext scaffoldC, List<DocumentSnapshot> documents) {
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
        body: getFlatNamesWidget(blocks[i], documents, scaffoldC),
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
      Block block, List<DocumentSnapshot> documents, BuildContext ctx) {
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
          trailing: isOwnerOfFlat(flats[index]) ||
                  ifRequestToFlatAlreadySent(documents, flats[index].getFlatId())
              ? SizedBox()
              : IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    sendRequestToOwner(ctx,
                        forFlat: true, block: block, flat: flats[index]);
                  },
                ),
        );
      },
    );
  }

  void sendRequestToOwner(BuildContext ctx,
      {bool forFlat, Block block, OwnerFlat flat}) async {
    setState(() {
      this.loadingState = false;
    });
    String phoneNumber = await Utility.getUserPhone();
    String userName = await Utility.getUserName();

    LandlordRequest request = new LandlordRequest();
    request.setBuildingAddress(this.building.getBuildingAddress());
    request.setBuildingDisplayId(this.building.getBuildingDisplayId());
    request.setBuildingId(this.building.getBuildingId());
    request.setBuildingName(this.building.getBuildingName());
    request.setZipcode(this.building.getZipcode());
    request.setStatus(globals.RequestStatus.Pending.index);
    request.setRequesterPhone(phoneNumber);
    request.setRequesterId(this.userId);
    request.setRequestToOwner(true);
    request.setRequesterUserName(userName);
    request.setCreatedAt(Timestamp.now());

    
    request.setBlockName(block.getBlockName());
    request.setFlatId(flat.getFlatId());
    request.setFlatDisplayId(flat.getFlatDisplayId());
    request.setFlatNumber(flat.getFlatName());
    

    Map<String, dynamic> data = request.toJson();
    Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .add(data)
        .then((value) {
      setState(() {
        this.loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Request created successfully');
    }).catchError((e) {
      setState(() {
        this.loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Error while creating request');
    });
  }
}
