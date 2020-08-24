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
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import '../home/Home.dart';
import '../models/OwnershipDetailsDBHandler.dart';


class CreateProperty extends StatefulWidget {
  final String userId;

  Building building;

  final bool isAdd;

  final bool join;

  CreateProperty(this.userId, this.building, this.isAdd, this.join);

  @override
  State<StatefulWidget> createState() {
    return CreatePropertyState(this.userId, this.building, this.isAdd, this.join);
  }
}

class CreatePropertyState extends State<CreateProperty> {
  @override
  void initState() {
    super.initState();
  }

  bool buildingsExpanded = false;
  bool flatExpanded = false;
  final String userId;
  Building building;

  bool loadingState = false;


  final bool isAdd;

  final bool join;

  Map<String, bool> blocksExpanded = new Map();

  CreatePropertyState(this.userId, this.building, this.isAdd, this.join) {
    if(!this.isAdd) {
      for(int i = 0; i < this.building.getBlocks().length; i++) {
        this.blocksExpanded[this.building.getBlocks()[i].getBlockName()] = false;
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
          title: Text(this.join? 'Join property':'Create Property'),
          centerTitle: true,
          actions: <Widget>[
            this.join?Container():Container(
                padding: EdgeInsets.all(10.0),
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    navigateToCreateBuilding();
                  },
                )),
          ],
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          return loadingState
              ? Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator())
              : Container(
                  child: building == null
                      ? Container()
                      : Column(children: [
                            this.join?getMainExpansionPanelListForJoin(scaffoldC):getMainExpansionPanelList(scaffoldC, null),
                            this.join?Container():Expanded(
                                child: Align(
                                    alignment: FractionalOffset.bottomCenter,
                                    child: RaisedButton(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15.0),
                                      child: Text('Save'),
                                      onPressed: () {
                                        saveProperty(scaffoldC);
                                      },
                                    ))),
                          ]),
                );
        }));
  }

  Widget getMainExpansionPanelList(BuildContext scaffoldC, List<DocumentSnapshot> data) {
    return ExpansionPanelList(
                            expansionCallback: (int index, bool isExpanded) {
                              debugPrint(isExpanded.toString());
                              setState(() {
                                buildingsExpanded = !buildingsExpanded;
                              });
                            },
                            children: [
                              ExpansionPanel(
                                headerBuilder:
                                    (BuildContext context, bool isExpanded) {
                                  return ListTile(
                                    onTap: () {
                                      if(isAdd && !this.join)
                                        navigateToCreateBuilding();
                                    },
                                    title: Text(building.getBuildingName()),
                                    trailing: this.join && !ifRequestToBuilding(data)?Container(child:IconButton(icon:Icon(Icons.link), onPressed: (){sendRequestToOwner(scaffoldC);},)):this.join?SizedBox():IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        acceptBlockName(null);
                                      },
                                    ),
                                  );
                                },
                                body: getBlocksListWidget(scaffoldC, data),
                                isExpanded: buildingsExpanded,
                              ),
                            ],
                          );
  }

  bool ifRequestToBuilding(List<DocumentSnapshot> data) {
    if(data == null || data.isEmpty) {
      return false;
    }
    DocumentSnapshot d = data.firstWhere((request){
      return request['flatId'] == null;
    }, orElse: () {return null;});

    return d != null;
  }

  bool ifRequestToFlat(List<DocumentSnapshot> data, String flatId) {
    if(data == null || data.isEmpty || flatId == null) {
      return false;
    }
    
    DocumentSnapshot d = data.firstWhere((request){
      return request['flatId'] == flatId;
    },  orElse: () { return null;});
    return d != null;
  }

  Widget getMainExpansionPanelListForJoin(BuildContext scaffoldC) {
    return FutureBuilder(
      future: Firestore.instance.collection(globals.ownerOwnerJoin).where('requesterId', isEqualTo: this.userId).where('buildingId', isEqualTo: this.building.getBuildingId()).getDocuments(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> documents) {
        if(!documents.hasData) {
          return LoadingContainerVertical(2);
        }
        return getMainExpansionPanelList(scaffoldC, documents.data.documents);
      },
    );
  }

  Widget getBlocksListWidget(BuildContext scaffoldC, List<DocumentSnapshot> documents) {
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
            onTap: () {
              if(isAdd || blocks[i].getBlockName() == null)
                acceptBlockName(blocks[i]);
            },
            title: Text(blocks[i].blockName),
            trailing: this.join?SizedBox():IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                navigateToAddFlats(blocks[i]);
              },
            ),
          );
        },
        body: GestureDetector(onTap: (){if(!this.join) {navigateToAddFlats(blocks[i]);}}, child:getFlatNamesWidget(blocks[i], documents, scaffoldC)),
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

  Widget getFlatNamesWidget(Block block, List<DocumentSnapshot> documents, BuildContext ctx) {
    List<OwnerFlat> flats = block.getOwnerFlats();
    if (flats == null || flats.isEmpty) {
      return Container();
    }


    if(!this.join) {
      List<Widget> flatsWidget = new List();
      for (int i = 0; i < flats.length; i++) {
        flatsWidget.add(new Chip(
          label: Text(flats[i].getFlatName()),
          deleteIcon: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {},
          ),
        ));
      }
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 15.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: 5.0,
            children: flatsWidget,
          ),
        ),
      );
    }
    return 
      ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (BuildContext context, int position) {return Divider(height:1.0);},
        itemCount: flats.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(flats[index].getFlatName()),
            trailing: ifRequestToFlat(documents, flats[index].getFlatId())?SizedBox():IconButton(icon: Icon(Icons.link), onPressed: () {sendRequestToOwner(ctx, forFlat: true, block: block, flat: flats[index]);},),
          );
        },
      );
    
  }

  void navigateToCreateBuilding() async {
    Building b = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateBuilding(this.userId, this.building);
      }),
    );

    setState(() {
      this.building = b;
    });
  }

  void acceptBlockName(Block block) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CreateBlock(setBlockDetails, block, this.building.getBlocks());
        });
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

  void navigateToAddFlats(Block block) async {
    List<OwnerFlat> ownerFlats = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateFlats(this.userId, block.getOwnerFlats(), this.join);
      }),
    );
    ownerFlats.forEach((OwnerFlat flat) {
      flat.setBlockName(block.getBlockName());
    });
    block.setOwnerFlats(ownerFlats);
    setState(() {
      block = block;
    });
  }

  void saveProperty(BuildContext ctx) async {
    setState(() {
      loadingState = true;
    });

    
    List<Map<String, dynamic>> localData = new List();
    var db = Firestore.instance;

    var batch = db.batch();
    DocumentReference dr;
    if(this.building.getBuildingId() != null) {
      dr = Firestore.instance.collection(globals.building).document(this.building.getBuildingId());
    }
    else {
      dr = Firestore.instance.collection(globals.building).document();
      localData.add({'buildingId': dr.documentID, 'buildingName': this.building.getBuildingName(), 'blockName': null, 'flatId': null, 'flatName': null});
    }

    Map<String, dynamic> buildingData = this.building.toJson();
    batch.setData(dr, buildingData);


        

    List<Block> blocks = this.building.getBlocks();
    if(blocks != null) {
    for (int i = 0; i < this.building.getBlocks().length; i++) {
      
      
      List<OwnerFlat> flats = blocks[i].getOwnerFlats();
      CollectionReference flatColRef =
          Firestore.instance.collection(globals.ownerFlat);
      if(flats != null) {
      for (int j = 0; j < flats.length; j++) {
        DocumentReference flatDocRef;
        if(flats[j].getFlatId() != null) {
          flatDocRef = flatColRef.document(flats[j].getFlatId());
        }
        else {
          flatDocRef = flatColRef.document();
          localData.add({'buildingId': dr.documentID, 'buildingName': this.building.getBuildingName(), 'blockName': blocks[i].getBlockName(), 'flatId': flatDocRef.documentID, 'flatName': flats[j].getFlatName()});
        }
        flats[j].setBuildingDetails(this.building.getZipcode());
        flats[j].setBuildingName(this.building.getBuildingName());
        flats[j].setBuildingId(dr.documentID);
        Map<String, dynamic> flatData = flats[j].toJson();
        batch.setData(flatDocRef, flatData, merge: true);
      }
      }
    }
    }

    batch.commit().then((retVal) {
      debugPrint("saved successfully");
      OwnershipDetailsDBHelper.instance.insertAll(localData);
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Home(this.userId);
        }),
      );
    }).catchError((e) {
      debugPrint("error while saving");
      setState(() {
        loadingState = false;
      });
      Utility.createErrorSnackBar(ctx, error: 'Error while saving');
    });
  }

  void sendRequestToOwner(BuildContext ctx, {bool forFlat, Block block, OwnerFlat flat}) async {

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

    if(forFlat) {
      request.setBlockName(block.getBlockName());
      request.setFlatId(flat.getFlatId());
      request.setFlatDisplayId(flat.getFlatDisplayId());
      request.setFlatNumber(flat.getFlatName());
    }


    Map<String, dynamic> data = request.toJson();
    Firestore.instance.collection(globals.ownerOwnerJoin).add(data).then((value) {
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
