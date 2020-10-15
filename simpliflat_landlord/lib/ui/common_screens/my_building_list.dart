import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/dao/building_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/tenant_flat.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/ui/owner_requests/property_requests.dart';
import 'package:simpliflat_landlord/ui/tenant_requests.dart/create_tenant_request.dart';
import 'package:simpliflat_landlord/view_model/my_building_list_model.dart';

/// list to show the owners buildings
class MyBuildingList extends StatefulWidget {
  final TenantFlat tenantFlat;

  final Owner owner;

  /// tenantFlat and owner are just to determine which page should be the next page
  MyBuildingList(this.tenantFlat, this.owner);

  @override
  State<StatefulWidget> createState() {
    return MyBuildingListState(this.tenantFlat, this.owner);
  }
}

class MyBuildingListState extends State<MyBuildingList> {
  //TODO: add loading state
  final TenantFlat tenantFlat;

  final Owner owner;

  MyBuildingListState(this.tenantFlat, this.owner);

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
        return Provider(
            create: (_) => MyBuildingListModel(), child: getBody(scaffoldC));
      }),
    );
  }

  Widget getBody(BuildContext scaffoldC) {
    User user = Provider.of<User>(context, listen: false);
    Map<String, List<OwnerFlat>> ownedFlats = Provider.of<MyBuildingListModel>(context, listen: false).getOwnedFlatIds();
    return FutureBuilder(
      future: getBuildingList(
          user.getUserId(), ownedFlats),
      builder:
          (BuildContext context, AsyncSnapshot<List<OwnerFlat>> buildings) {
        if (!buildings.hasData) {
          return LoadingContainerVertical(2);
        }
        return ListView.separated(
          separatorBuilder: (BuildContext ctx, int pos) {
            return Divider(height: 1.0);
          },
          itemCount: buildings.data.length,
          itemBuilder: (BuildContext context, int position) {
            return Card(
              child: ListTile(
                onTap: () {
                  navigate(buildings.data[position]);
                },
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
    Map<String, List<OwnerFlat>> ownedFlats =
        Provider.of<MyBuildingListModel>(context, listen: false)
            .getOwnedFlatIds();

    Building b =
        await createBuildingObject(flat, ownedFlats);

    if (this.tenantFlat != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return CreateTenantRequest(b, this.tenantFlat);
        }),
      );
    } else if (this.owner != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return PropertyRequests(b, this.owner);
        }),
      );
    }
  }


  Future<List<OwnerFlat>> getBuildingList(String userId, Map<String, List<OwnerFlat>> ownedFlats) async {
    ownedFlats = new Map();
    QuerySnapshot allFlats = await OwnerFlatDao.getByOwnerId(userId);
    List<OwnerFlat> buildings = new List();
    for(int i = 0; i < allFlats.documents.length; i++) {
      DocumentSnapshot d1 = allFlats.documents[i];
      OwnerFlat flatTemp = OwnerFlat.fromJson(d1.data, d1.documentID);
      if(ownedFlats[flatTemp.getBuildingId()] == null) {
        ownedFlats[flatTemp.getBuildingId()] = new List();
      }
      ownedFlats[flatTemp.getBuildingId()].add(flatTemp);
      OwnerFlat alreadyAdded = buildings.firstWhere((OwnerFlat b) {
        return (b.getBuildingId() == d1.data['buildingId']);
      }, orElse: () {return null;});
      if(alreadyAdded == null) {
        buildings.add(flatTemp);
      }
    }
    return buildings;
  }

  Future<Building> createBuildingObject(OwnerFlat flat, Map<String, List<OwnerFlat>> ownedFlats) async {
    Building b = await BuildingDao.getById(flat.getBuildingId());

    List<Block> blocks = new List();

  
    List<OwnerFlat> flats = ownedFlats[flat.getBuildingId()];

    for(int i = 0; i < flats.length; i++) {

      OwnerFlat flat = flats[i];
      
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

    return b;

  }

}
