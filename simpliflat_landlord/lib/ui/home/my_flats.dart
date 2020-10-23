import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/dao/landlord_requests_dao.dart';
import 'package:simpliflat_landlord/dao/owner_tenant_dao.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/ui/flat_setup/add_tenant.dart';
import 'package:simpliflat_landlord/ui/tenant_portal/tenant_portal.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/services/owner_requests_service.dart';
import 'package:simpliflat_landlord/view_model/join_property_model.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';

class MyFlats extends StatelessWidget {
  
  final Building building;

  MyFlats(this.building);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
                              create: (_) => LoadingModel(),
                              child: ChangeNotifierProvider(
                                create: (_) => JoinPropertyModel(),
     child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('My flats', style: CommonWidgets.getAppBarTitleStyle()),
          centerTitle: true,
          elevation: 0,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          return 
              Container(
                  child: building == null
                      ? Container()
                      : SingleChildScrollView(
                          child: Column(children: [
                             getMainExpansionPanelListForJoin(scaffoldC),
                          ]),
                        ),
                );
        }))));
  }

  Widget getMainExpansionPanelList(
      BuildContext scaffoldC, List<DocumentSnapshot> data, JoinPropertyModel joinPropertyModel) {

    return Column(
                                  children:[ Container(
                                    color: Color(0xff2079FF),
                                                                      child: ListTile(
                                                                        contentPadding: EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15.0),
                                      
                                      title: Text(building.getBuildingName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20.0, color: Colors.white)),
                                    ),
                                  ), getBlocksListWidget(scaffoldC, data, joinPropertyModel)]);
  }


  bool isOwnerOfFlat(OwnerFlat flat, String userId) {

      if (flat.getOwnerIdList().contains(userId)) {
        return true;
      }
    

    return false;
  }


  Widget getMainExpansionPanelListForJoin(BuildContext scaffoldC) {
    User user = Provider.of<User>(scaffoldC, listen: false);
    return FutureBuilder(
      future: LandlordRequestsDao.getRequestsSentByMeToOwnerForBuilding(user.getUserId(), this.building.getBuildingId()),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> documents) {
        if (!documents.hasData) {
          return LoadingContainerVertical(2);
        }
        return Consumer2<JoinPropertyModel, LoadingModel>(
          builder: (BuildContext context, JoinPropertyModel joinPropertyModel, LoadingModel loadingModel,  Widget child) {
            return loadingModel.load? LoadingContainerVertical(5):
            getMainExpansionPanelList(scaffoldC, documents.data.documents, joinPropertyModel);
          },
        ); 
       
      },
    );
  }

  Widget getBlocksListWidget(
      BuildContext scaffoldC, List<DocumentSnapshot> documents, JoinPropertyModel joinPropertyModel) {
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
            title: Text(blocks[i].blockName, style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 18.0)),
          );
        },
        body: getFlatNamesWidget(blocks[i], documents, scaffoldC),
        isExpanded: joinPropertyModel.isBlockExpanded(blocks[i].getBlockName()),
      ));
    }
    return new ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) async {
        debugPrint("blocks expanded");
        Provider.of<JoinPropertyModel>(scaffoldC, listen: false).expandBlock(blocks[index].getBlockName());
      },
      children: blocksWidget,
    );
  }

  
  Widget getFlatNamesWidget(
      Block block, List<DocumentSnapshot> documents, BuildContext ctx) {
    User user = Provider.of<User>(ctx, listen: false);


    List<OwnerFlat> flats = block.getOwnerFlats();
    if (flats == null || flats.isEmpty) {
      return Container();
    }


    
      List<Widget> flatsWidget = new List();
      for (int i = 0; i < flats.length; i++) {
        flatsWidget.add(GestureDetector(
          onTap: () => navigateToLandlordPortal(flats[i], ctx),
                  child: new Chip(
            backgroundColor: Colors.white,
            label: Text(flats[i].getFlatName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 17.0, color: Color(0xff2079FF))),
            deleteIcon: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {},
            ),
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

  void navigateToLandlordPortal(OwnerFlat flat, BuildContext context) async {
    debugPrint("navigate to landlord portal");
    flat.setZipcode(flat.getBuildingDetails());
    QuerySnapshot q = await OwnerTenantDao.getByOwnerFlatId(flat.getFlatId());
    //TODO: building address and zipcode are set only in case if owner and tenant apartment are linked. Need to set in other case too
    //Instead add building Address in flat
    if (q != null && q.documents.length > 0) {
      flat.setBuildingAddress(q.documents[0].data['buildingAddress']);
      flat.setZipcode(q.documents[0].data['zipcode']);
      flat.setTenantFlatId(q.documents[0].data['tenantFlatId']);
      flat.setTenantFlatName(q.documents[0].data['tenantFlatName']);
      flat.setApartmentTenantId(q.documents[0].documentID);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return LandlordPortal(flat);
        }),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return AddTenant(flat);
        }),
      );
    }
  }
}
