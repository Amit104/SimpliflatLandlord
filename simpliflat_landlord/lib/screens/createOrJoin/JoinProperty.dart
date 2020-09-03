import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/models/Block.dart';
import 'package:simpliflat_landlord/screens/models/Building.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/models/OwnerFlat.dart';
import 'package:simpliflat_landlord/screens/utility.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import 'package:simpliflat_landlord/service/OwnerRequestsService.dart';

/// page for owner to join an existing property
class JoinProperty extends StatefulWidget {
  final Owner user;

  /// the building in which the flat is to be created
  Building building;

  JoinProperty(this.user, this.building);

  @override
  State<StatefulWidget> createState() {
    return JoinPropertyState(
        this.user, this.building);
  }
}

class JoinPropertyState extends State<JoinProperty> {
  @override
  void initState() {
    super.initState();
  }

  bool buildingsExpanded = false;
  bool flatExpanded = false;
  final Owner user;
  Building building;

  bool loadingState = false;

  Map<String, bool> blocksExpanded = new Map();

  JoinPropertyState(this.user, this.building) {
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
    
      if (flat.getOwnerIdList().contains(this.user.getOwnerId())) {
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
        .where('requesterId', isEqualTo: this.user.getOwnerId())
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
                        block: block, flat: flats[index]);
                  },
                ),
        );
      },
    );
  }

  void sendRequestToOwner(BuildContext ctx,
      {Block block, OwnerFlat flat}) async {
 
    setState(() {
        this.loadingState = true;
    });

    bool ifSuccess = await OwnerRequestsService.sendRequestToOwner(this.building, block, flat, this.user);

    if(ifSuccess) {
      setState(() {
        this.loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Request created successfully');
    } else {
      setState(() {
        this.loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Error while creating request');
    }
  }
}
