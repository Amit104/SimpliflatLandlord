import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/dao/landlord_requests_dao.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/services/property_service.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/ui/create_or_join/create_block.dart';
import 'package:simpliflat_landlord/ui/create_or_join/create_building.dart';
import 'package:simpliflat_landlord/ui/create_or_join/create_flats.dart';
import 'package:simpliflat_landlord/ui/home/home.dart';


///create property
class CreateProperty extends StatefulWidget {

  ///building is needed when owner wants to create flat or block in existing building
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
                              getMainExpansionPanelList(scaffoldC),
                              SizedBox(height: 100.0),
                            ]),
                      ),
                );
        }));
  }

  Widget getMainExpansionPanelList(BuildContext scaffoldC) {
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
                                  ), getBlocksListWidget(scaffoldC)]);
  }

  Widget getBlocksListWidget(BuildContext scaffoldC) {
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
        body: GestureDetector(onTap: (){navigateToAddFlats(blocks[i]);}, child:getFlatNamesWidget(blocks[i], scaffoldC)),
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

  Widget getFlatNamesWidget(Block block, BuildContext ctx) {
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

  void setBlockDetails(Block block, bool isEdit) {
    block.setModified(true);
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

    bool ifSuccess = await PropertyService.saveProperty(this.building);

    if(ifSuccess) { 
      debugPrint("saved successfully");
      Utility.addToSharedPref(propertyRegistered: true);
      setState(() {
        loadingState = false;
      });
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Home();
        }),
      );
    } else {
      debugPrint("error while saving");
      setState(() {
        loadingState = false;
      });
      Utility.createErrorSnackBar(this.scaffoldContext, error: 'Error while saving');
    }
  }

  
}
