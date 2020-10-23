import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/dao/landlord_requests_dao.dart';
import 'package:simpliflat_landlord/local_db/ownership_details_dbhandler.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/ui/create_or_join/create_block.dart';
import 'package:simpliflat_landlord/ui/create_or_join/create_building.dart';
import 'package:simpliflat_landlord/ui/create_or_join/create_flats.dart';
import 'package:simpliflat_landlord/ui/home/home.dart';


///create property
class CreateProperty extends StatefulWidget {

  ///building is needed when owner wants to create flat in existing building
  Building building;

  final bool isAdd;

  CreateProperty(this.building, this.isAdd);

  @override
  State<StatefulWidget> createState() {
    return CreatePropertyState(this.building, this.isAdd);
  }
}

class CreatePropertyState extends State<CreateProperty> {
  @override
  void initState() {
    super.initState();
  }

  bool buildingsExpanded = false;
  bool flatExpanded = false;
  Building building;

  bool loadingState = false;


  final bool isAdd;

  BuildContext scaffoldContext;


  Map<String, bool> blocksExpanded = new Map();

  CreatePropertyState(this.building, this.isAdd) {
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
        floatingActionButton: this.building != null? FloatingActionButton.extended(
          backgroundColor: Color(0xff2079FF),
          onPressed: () {
            saveProperty();
          },
          isExtended: true,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          icon: Icon(Icons.save),
          label: Text('Save'),
        ):null,
        appBar: AppBar(
          title: Text('Create Property', style: CommonWidgets.getAppBarTitleStyle()),
          centerTitle: true,
          elevation: 0,
          actions: <Widget>[
            this.building != null && this.building.getBuildingId()!=null?SizedBox(): Container(
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
          this.scaffoldContext = scaffoldC;
          return loadingState
              ? Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator())
              : Container(
                  child: building == null
                      ? Container()
                      : SingleChildScrollView(
                                              child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                              getMainExpansionPanelList(scaffoldC, null),
                              SizedBox(height: 100.0),
                            ]),
                      ),
                );
        }));
  }

  Widget getMainExpansionPanelList(BuildContext scaffoldC, List<DocumentSnapshot> data) {
   return Column(
                                  children:[ Container(
                                    color: Color(0xff2079FF),
                                                                      child: ListTile(
                                                                        contentPadding: EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15.0),
                                      onTap: () {
                                        if(isAdd)
                                          navigateToCreateBuilding();
                                      },
                                      title: Text(building.getBuildingName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20.0, color: Colors.white)),
                                      trailing: IconButton(
                                        icon: Icon(Icons.add, color: Colors.white,),
                                        onPressed: () {
                                          acceptBlockName(null);
                                        },
                                      ),
                                    ),
                                  ), getBlocksListWidget(scaffoldC, data)]);
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
    User user = Provider.of<User>(scaffoldC, listen: false);

    return FutureBuilder(
      future: LandlordRequestsDao.getRequestsSentByMe(user.getUserId(), this.building.getBuildingId()),
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
            title: Text(blocks[i].blockName, style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 18.0)),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                navigateToAddFlats(blocks[i]);
              },
            ),
          );
        },
        body: GestureDetector(onTap: (){navigateToAddFlats(blocks[i]);}, child:getFlatNamesWidget(blocks[i], documents, scaffoldC)),
        isExpanded: blocksExpanded[blocks[i].getBlockName()],
      ));
    }
    return new ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) async {
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


    
      List<Widget> flatsWidget = new List();
      for (int i = 0; i < flats.length; i++) {
        flatsWidget.add(new Chip(
          backgroundColor: Colors.white,
          label: Text(flats[i].getFlatName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 17.0, color: Color(0xff2079FF))),
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

  void navigateToCreateBuilding() async {
    Building b = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateBuilding(this.building);
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
    if(block == null){
      return;
    }
    List<Block> blocks = this.building.getBlocks();
    if (blocks == null) {
      blocks = new List();
    }
    blocksExpanded.forEach((String key, bool value) {
      blocksExpanded[key] = false;
    });
    blocksExpanded[block.getBlockName()] = false;
    if (!isEdit) {
      blocks.add(block);
    }
    setState(() {
      this.building.setBlock(blocks);
      blocksExpanded = blocksExpanded;
    });
    debugPrint(blocks.length.toString());
  }

  void navigateToAddFlats(Block block) async {
    List<OwnerFlat> ownerFlats = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return CreateFlats(block.getOwnerFlats(), false);
      }),
    );
    ownerFlats.forEach((OwnerFlat flat) {
      flat.setBlockName(block.getBlockName());
    });
    blocksExpanded.forEach((String key, bool value) {
      blocksExpanded[key] = false;
    });
    block.setOwnerFlats(ownerFlats);
    setState(() {
      block = block;
    });
  }

  void saveProperty() async {

    setState(() {
      loadingState = true;
    });

    
    List<Map<String, dynamic>> localData = new List();
    var db = Firestore.instance;

    var batch = db.batch();
    DocumentReference dr;
    if(this.building.getBuildingId() != null) {
      //dr = Firestore.instance.collection(globals.building).document(this.building.getBuildingId());
    }
    else {
      dr = Firestore.instance.collection(globals.building).document();
      Map<String, dynamic> buildingData = this.building.toJson();
      batch.setData(dr, buildingData);
      localData.add({'buildingId': dr.documentID, 'buildingName': this.building.getBuildingName(), 'blockName': null, 'flatId': null, 'flatName': null});
    }

    


        

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
          //flatDocRef = flatColRef.document(flats[j].getFlatId());
        }
        else {
          flatDocRef = flatColRef.document();
          localData.add({'buildingId': dr.documentID, 'buildingName': this.building.getBuildingName(), 'blockName': blocks[i].getBlockName(), 'flatId': flatDocRef.documentID, 'flatName': flats[j].getFlatName()});
        
        flats[j].setBuildingDetails(this.building.getZipcode());
        flats[j].setBuildingName(this.building.getBuildingName());
        flats[j].setBuildingId(dr.documentID);
        Map<String, dynamic> flatData = flats[j].toJson();
        batch.setData(flatDocRef, flatData, merge: true);
        }
      }
      }
    }
    }

    batch.commit().then((retVal) {
      debugPrint("saved successfully");
      Utility.addToSharedPref(propertyRegistered: true);
      OwnershipDetailsDBHelper.instance.insertAll(localData);
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Home();
        }),
      );
    }).catchError((e) {
      debugPrint("error while saving");
      setState(() {
        loadingState = false;
      });
      Utility.createErrorSnackBar(this.scaffoldContext, error: 'Error while saving');
    });
  }

  
}
