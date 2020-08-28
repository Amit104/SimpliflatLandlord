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

class PropertyRequests extends StatefulWidget {
  final String userId;

  Building building;

  final bool join;

  final Owner toOwner;

  PropertyRequests(this.userId, this.building, this.join, this.toOwner);

  @override
  State<StatefulWidget> createState() {
    return PropertyRequestsState(
        this.userId, this.building, this.join, this.toOwner);
  }
}

class PropertyRequestsState extends State<PropertyRequests> {
  @override
  void initState() {
    super.initState();
  }

  bool buildingsExpanded = false;
  bool flatExpanded = false;
  final String userId;
  Building building;

  bool loadingState = false;

  final bool join;

  Map<String, bool> blocksExpanded = new Map();

  Owner toOwner;

  PropertyRequestsState(this.userId, this.building, this.join, this.toOwner) {
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
          title: Text(this.join ? 'Join property' : 'Add Owner'),
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
              trailing: !ifRequestToBuildingAlreadySent(data) && !ifRequestToBuildingAlreadyReceived(data) && 
                      !isOwnerOfBuilding()
                  ? Container(
                      child: IconButton(
                        icon: Icon(Icons.link),
                        onPressed: () {
                          sendRequestToOwner(scaffoldC);
                        },
                      ),
                    )
                  : SizedBox(),
            );
          },
          body: getBlocksListWidget(scaffoldC, data),
          isExpanded: buildingsExpanded,
        ),
      ],
    );
  }

  bool isOwnerOfBuilding() {
    if (join) {
      if (this.building.getOwnerIdList().contains(this.userId)) {
        return true;
      }
    } else {
      if (this.building.getOwnerIdList().contains(this.toOwner.getOwnerId())) {
        return true;
      }
    }

    return false;
  }

  bool isOwnerOfFlat(OwnerFlat flat) {
    if (join) {
      if (flat.getOwnerIdList().contains(this.userId)) {
        return true;
      }
    } else {
      if (flat.getOwnerIdList().contains(this.toOwner.getOwnerId())) {
        return true;
      }
    }

    return false;
  }

  bool ifRequestToAnyFlat(List<DocumentSnapshot> data) {
    if (data == null || data.isEmpty) {
      return false;
    }

    DocumentSnapshot d = data.firstWhere((request) {
      return request['flatId'] != null;
    }, orElse: () {
      return null;
    });

    return d != null;
  }


  bool ifRequestToFlatAlreadySent(List<DocumentSnapshot> data, String flatId) {
    if (data == null || data.isEmpty || flatId == null) {
      return false;
    }

    DocumentSnapshot d = data.firstWhere((request) {
      if (join) {
        return request['flatId'] == flatId &&
            request['requesterId'] == this.userId;
      } else {
        return request['flatId'] == flatId &&
            request['toUserId'] == this.toOwner.getOwnerId();
      }
    }, orElse: () {
      return null;
    });
    return d != null;
  }

  bool ifRequestToFlatAlreadyReceived(
      List<DocumentSnapshot> data, String flatId) {
    if (data == null || data.isEmpty || flatId == null) {
      return false;
    }

    DocumentSnapshot d = data.firstWhere((request) {
      if (join) {
        return request['flatId'] == flatId &&
            request['toUserId'] == this.userId;
      } else {
        return request['flatId'] == flatId &&
            request['requesterId'] == this.toOwner.getOwnerId();
      }
    }, orElse: () {
      return null;
    });
    return d != null;
  }

  bool ifRequestToBuildingAlreadySent(List<DocumentSnapshot> data) {
    if (data == null || data.isEmpty) {
      return false;
    }

    DocumentSnapshot d = data.firstWhere((request) {
      if (join) {
        return request['flatId'] == null &&
            request['requesterId'] == this.userId;
      } else {
        return request['flatId'] == null &&
            request['toUserId'] == this.toOwner.getOwnerId();
      }
    }, orElse: () {
      return null;
    });
    return d != null;
  }

  bool ifRequestToBuildingAlreadyReceived(
      List<DocumentSnapshot> data) {
    if (data == null || data.isEmpty) {
      return false;
    }

    DocumentSnapshot d = data.firstWhere((request) {
      if (join) {
        return request['flatId'] == null &&
            request['toUserId'] == this.userId;
      } else {
        return request['flatId'] == null &&
            request['requesterId'] == this.toOwner.getOwnerId();
      }
    }, orElse: () {
      return null;
    });
    return d != null;
  }

  Future<QuerySnapshot> getExistingRequestsData() {
    Query q = Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .where('buildingId', isEqualTo: this.building.getBuildingId())
        .where('status', isEqualTo: globals.RequestStatus.Pending.index);

    /*if(!this.join) {
      debugPrint("not join");
      q = q.where('toUserId', isEqualTo: this.toOwner.getOwnerId());
    }
    else {
      q = q.where('requesterId', isEqualTo: this.userId);
    }*/

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
    if (!this.join) {
      /** reason for below? */
      documents.removeWhere((DocumentSnapshot document) {
        if (document.data['ownerIdList'] == null) {
          return false;
        }
        return !(document.data['ownerIdList'] as List).contains(this.userId);
      });
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
                  ifRequestToFlatAlreadySent(documents, flats[index].getFlatId()) ||
                  ifRequestToFlatAlreadyReceived(documents, flats[index].getFlatId()) ||
                  ifRequestToBuildingAlreadySent(documents) || isOwnerOfBuilding()
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

  //TODO: check if block is updated and populate isUpdated field correspondingly. If not updated then no need to set in batch
  void setBlockDetails(Block block, bool isEdit) {
    debugPrint("in set block details");
    List<Block> blocks = this.building.getBlocks();
    if (blocks == null) {
      blocks = new List();
    }
    blocksExpanded[block.getBlockName()] = false;
    if (!isEdit) {
      blocks.add(block);
    }
    setState(() {
      this.building.setBlock(blocks);
      blocksExpanded[block.getBlockName()] = false;
    });
    debugPrint(blocks.length.toString());
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

    if (forFlat != null && forFlat) {
      request.setBlockName(block.getBlockName());
      request.setFlatId(flat.getFlatId());
      request.setFlatDisplayId(flat.getFlatDisplayId());
      request.setFlatNumber(flat.getFlatName());
    }

    if (!join) {
      request.setToUserId(this.toOwner.getOwnerId());
      request.setToPhoneNumber(this.toOwner.getPhone());
      request.setToUsername(this.toOwner.getName());
    }

    Map<String, dynamic> data = request.toJson();
    Firestore.instance
        .collection(globals.ownerOwnerJoin)
        .add(data)
        .then((value) {
      setState(() {
        this.loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Request created successfully');
      if(this.toOwner == null) {
        Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Home(this.userId);
        }),
      );
      }
    }).catchError((e) {
      setState(() {
        this.loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Error while creating request');
    });
  }
}
