import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/dao/building_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/tenant_flat.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/ui/home/my_flats.dart';
import 'package:simpliflat_landlord/ui/owner_requests/property_requests.dart';
import 'package:simpliflat_landlord/ui/tenant_requests.dart/create_tenant_request.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';
import 'package:simpliflat_landlord/view_model/my_building_list_model.dart';

/// list to show the owners buildings
class MyBuildingList extends StatefulWidget {
  final TenantFlat tenantFlat;

  final Owner owner;

  final bool toTenantPortal;

  /// tenantFlat and owner are just to determine which page should be the next page
  MyBuildingList(this.tenantFlat, this.owner, this.toTenantPortal);

  @override
  State<StatefulWidget> createState() {
    return MyBuildingListState(this.tenantFlat, this.owner, this.toTenantPortal);
  }
}

class MyBuildingListState extends State<MyBuildingList> {
  final TenantFlat tenantFlat;

  final Owner owner;

  final bool toTenantPortal;

  MyBuildingListState(this.tenantFlat, this.owner, this.toTenantPortal);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
            create: (_) => MyBuildingListModel(),
    child: ChangeNotifierProvider(
          create: (_) => LoadingModel(),
          child: Scaffold(
        appBar: AppBar(
          title: Text('Your buildings', style: CommonWidgets.getAppBarTitleStyle(),),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Builder(builder: (BuildContext scaffoldC) {
           return getBody(scaffoldC);
        })),
    ),
    );
  }

  Widget getBody(BuildContext scaffoldC) {
    User user = Provider.of<User>(context, listen: false);
    return FutureBuilder(
      future: getBuildingList(
          user.getUserId(), scaffoldC),
      builder:
          (BuildContext context, AsyncSnapshot<List<OwnerFlat>> buildings) {
        if (!buildings.hasData) {
          return LoadingContainerVertical(2);
        }
        
        return Consumer<LoadingModel>(
            builder: (BuildContext context, LoadingModel loadingModel, Widget child) {
                if(loadingModel.load) return LoadingContainerVertical(3);
              //TODO: test this
              if(buildings.data != null && buildings.data.length == 1) {
                navigate(buildings.data[0], scaffoldC);
              }

                  return ListView.separated(
            separatorBuilder: (BuildContext ctx, int pos) {
              return Divider(height: 1.0);
            },
            itemCount: buildings.data.length,
            itemBuilder: (BuildContext context, int position) {
              return ListTile(
                onTap: () {
                  navigate(buildings.data[position], scaffoldC);
                },
                title: Text(buildings.data[position].getBuildingName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 17.0),),
                subtitle: Text(buildings.data[position].getZipcode(), style: TextStyle(fontFamily: 'Roboto'),),
                trailing: Icon(Icons.keyboard_arrow_right, color: Color(0xff2079FF),),
              );
            },
          );
            });
      },
    );
  }

  void navigate(OwnerFlat flat, BuildContext scaffoldC) async {

    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();
    Map<String, List<OwnerFlat>> ownedFlats =
        Provider.of<MyBuildingListModel>(scaffoldC, listen: false)
            .getOwnedFlatIds();
    
    debugPrint(ownedFlats.keys.toList().toString());

    Building b =
        await createBuildingObject(flat, ownedFlats);

    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();
    if(toTenantPortal) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return MyFlats(b);
        }),
      );
    } else if (this.tenantFlat != null) {
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


  Future<List<OwnerFlat>> getBuildingList(String userId, BuildContext scaffoldC) async {
    Map<String, List<OwnerFlat>> ownedFlats = new Map();
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
    Provider.of<MyBuildingListModel>(scaffoldC, listen: false).setOwnedFlatIds(ownedFlats);
    return buildings;
  }

  Future<Building> createBuildingObject(OwnerFlat flat, Map<String, List<OwnerFlat>> ownedFlats) async {
    Building b = await BuildingDao.getById(flat.getBuildingId());

    List<Block> blocks = new List();

  
    List<OwnerFlat> flats = ownedFlats[flat.getBuildingId()];

    if(flats == null) {
      return null;
    }

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
