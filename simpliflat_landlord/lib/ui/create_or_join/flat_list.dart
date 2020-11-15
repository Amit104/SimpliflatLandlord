import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/dao/building_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/ui/create_or_join/create_property.dart';
import 'package:simpliflat_landlord/ui/create_or_join/join_property.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';


/// list of all buildings
class FlatList extends StatelessWidget {
  
  final bool join;

  FlatList(this.join);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
          create: (_) => LoadingModel(),
          child: Scaffold(
      appBar: AppBar(
          title: Text('Select Buildings', style: CommonWidgets.getAppBarTitleStyle()),
          elevation: 0,
          centerTitle: true,
          actions: <Widget>[Builder(builder: (BuildContext abContext){
                  return this.join?SizedBox():Container(padding: EdgeInsets.all(10.0),child:IconButton(icon:Icon(Icons.add), onPressed: () {navigateToCreateProperty(abContext, null);},));
          })],
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        
        return getBody(scaffoldC);
      }),
    ));
  }

  Widget getBody(BuildContext scaffoldC) {
    return StreamBuilder(
      stream: BuildingDao.getAll(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snaphot) {
        if(!snaphot.hasData) {
          return LoadingContainerVertical(2);
        }

        List<Building> buildings = snaphot.data.documents.map((DocumentSnapshot doc) => Building.fromJson(doc.data, doc.documentID)).toList();
        return Consumer<LoadingModel>(
            builder: (BuildContext context, LoadingModel loadingModel, Widget child) {
              return loadingModel.load? LoadingContainerVertical(3):
              ListView.separated(
            separatorBuilder: (BuildContext ctx, int pos){
              return Divider(height: 1.0);
            },
            itemCount: buildings.length,
            itemBuilder: (BuildContext context, int position) {
              return ListTile(
                onTap: () {createDataObjectAndNavigate(buildings[position], snaphot.data.documents[position].documentID, scaffoldC);},
                title: Text(buildings[position].getBuildingName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 17.0),),
                subtitle: Text(buildings[position].getBuildingAddress() + ' ' + buildings[position].getZipcode(),  style: TextStyle(fontFamily: 'Roboto'),),
                trailing: Icon(Icons.keyboard_arrow_right, color: Color(0xff2079FF),),
              );
            },
          );
            },
        );
      },
    );
  }

  void navigateToCreateProperty(BuildContext abContext, Building building) async {
    bool isAdd = building == null;
    if(this.join) {
      

      Navigator.push(
      abContext,
      MaterialPageRoute(builder: (context) {
        return JoinProperty(building);
      }),
    );

    }
    else {
      Navigator.push(
        abContext,
        MaterialPageRoute(builder: (context) {
          return CreateProperty(building, isAdd);
        }),
      );
    }
  }

  void createDataObjectAndNavigate(Building b, documentId, BuildContext ctx) async {
    debugPrint("navigating");
    Provider.of<LoadingModel>(ctx, listen: false).startLoading();

    List<Block> blocks = b.getBlocks();

    QuerySnapshot snapshot = await OwnerFlatDao.getAllVerifiedFlatsOfBuilding(documentId);

    
    for(int i = 0; i < snapshot.documents.length; i++) {
      OwnerFlat flat = OwnerFlat.fromJson(snapshot.documents[i].data, snapshot.documents[i].documentID);
      Block block = blocks.firstWhere((Block b) { return b.getBlockName() == flat.getBlockName();}, orElse: () {return null;});
      if(block != null) {
        if(block.getOwnerFlats() == null) {
          block.setOwnerFlats(new List());
        }
        block.getOwnerFlats().add(flat);
      }
    }

    Provider.of<LoadingModel>(ctx, listen: false).stopLoading();

    navigateToCreateProperty(ctx, b);
  }

}