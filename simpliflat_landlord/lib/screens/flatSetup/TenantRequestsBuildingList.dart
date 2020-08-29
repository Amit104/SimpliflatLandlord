import 'package:flutter/material.dart';
import '../models/Building.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;
import 'package:simpliflat_landlord/screens/utility.dart';
import 'dart:math';
import '../models/OwnerFlat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import './createProperty.dart';
import './PropertyRequests.dart';
import '../models/Block.dart';
import '../models/Owner.dart';
import '../models/OwnershipDetailsDBHandler.dart';
import './TenantRequests.dart';
import './LandlordRequests.dart';



class TenantRequestBuildingList extends StatefulWidget {

  final String userId;


  TenantRequestBuildingList(this.userId);

  @override
  State<StatefulWidget> createState() {
    return TenantRequestBuildingListState(this.userId);
  }

}

class TenantRequestBuildingListState extends State<TenantRequestBuildingList> {

  final String userId;

  bool loadingState = false;


  Map<String, List<OwnerFlat>> ownedFlatIds = new Map();


  TenantRequestBuildingListState(this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your buildings'),
        centerTitle: true,
        backgroundColor: Colors.white,
        
      ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        return loadingState == true?Container(alignment: Alignment.center, child: CircularProgressIndicator()):
        getBody(scaffoldC);
      }),
    );
  }

  Future<List<OwnerFlat>> getBuildingList() async {
    ownedFlatIds = new Map();
    QuerySnapshot allFlats = await Firestore.instance.collection(globals.ownerFlat).where('ownerIdList', arrayContains:  this.userId).getDocuments();
    List<OwnerFlat> buildings = new List();
    debugPrint('full length ' + allFlats.documents.length.toString());
    for(int i = 0; i < allFlats.documents.length; i++) {
      debugPrint(i.toString());
      DocumentSnapshot d1 = allFlats.documents[i];
      
      OwnerFlat flatTemp = OwnerFlat.fromJson(d1.data, d1.documentID);
      if(ownedFlatIds[flatTemp.getBuildingId()] == null) {
        ownedFlatIds[flatTemp.getBuildingId()] = new List();
      }
      debugPrint('loading - ' + flatTemp.getBuildingId() + ' flatTemp - ' + flatTemp.getFlatId());
      ownedFlatIds[flatTemp.getBuildingId()].add(flatTemp);
      OwnerFlat alreadyAdded = buildings.firstWhere((OwnerFlat b) {
        return (b.getBuildingId() == d1.data['buildingId']);
      }, orElse: () {return null;});
      if(alreadyAdded == null) {
        buildings.add(flatTemp);
      }
    }
    return buildings;
  }

  Widget getBody(BuildContext scaffoldC) {
    return FutureBuilder (
      future: getBuildingList(),
      builder: (BuildContext context, AsyncSnapshot<List<OwnerFlat>> buildings) {
        if(!buildings.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos){
            return Divider(height: 1.0);
          },
          itemCount: buildings.data.length,
          itemBuilder: (BuildContext context, int position) {
            return Card(
              child: ListTile(
                onTap: () {navigate(buildings.data[position]);},
                title: Text(buildings.data[position].getBuildingName()),
                subtitle: Text(buildings.data[position].getBuildingDetails()),
              ),
            );
          },
        );
      },
    );
  }

  void navigate(OwnerFlat flat) async {
    
    List<String> flatIds = new List();

    Building b = new Building();
    b.setBuildingName(flat.getBuildingName());
    b.setZipcode(flat.getBuildingDetails());
    b.setBuildingId(flat.getBuildingId());

    List<Block> blocks = new List();

  
    List<OwnerFlat> flats = ownedFlatIds[flat.getBuildingId()];

    ownedFlatIds.forEach((String key, List<OwnerFlat> value) {
      value.forEach((OwnerFlat o) {
        debugPrint(key + ' - ' + o.getFlatId());
      });
    });

    debugPrint(flats.length.toString());
    for(int i = 0; i < flats.length; i++) {

      OwnerFlat flat = flats[i];
      debugPrint('flatid = ' + flat.getFlatId());
      flatIds.add(flat.getFlatId());
      
      Block block = blocks.firstWhere((Block b) { return b.getBlockName() == flat.getBlockName();}, orElse: () {return null;});
      if(block == null) {
        block = new Block();
        block.setBlockName(flats[i].getBlockName());
        blocks.add(block);
      }
      if(block != null) {
        if(block.getOwnerFlats() == null) {
          block.setOwnerFlats(new List());
        }
        block.getOwnerFlats().add(flat);
      }
    }


    b.setBlock(blocks);
      

    
      Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return TenantRequests(this.userId, b, flatIds);
                    }),
                  );
    }



  

}