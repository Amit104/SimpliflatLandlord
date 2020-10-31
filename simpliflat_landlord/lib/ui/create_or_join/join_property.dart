import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/dao/landlord_requests_dao.dart';
import 'package:simpliflat_landlord/model/landlord_request.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/services/owner_requests_service.dart';
import 'package:simpliflat_landlord/view_model/join_property_model.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';

/// page for owner to join an existing property
class JoinProperty extends StatelessWidget {
  
  final Building building;

  JoinProperty(this.building);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
                              create: (_) => LoadingModel(),
                              child: ChangeNotifierProvider(
                                create: (_) => JoinPropertyModel(),
     child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Join Property', style: CommonWidgets.getAppBarTitleStyle()),
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
      BuildContext scaffoldC, List<LandlordRequest> data, JoinPropertyModel joinPropertyModel) {

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

  bool ifRequestToFlatAlreadySent(List<LandlordRequest> data, String flatId) {
    if (data == null || data.isEmpty || flatId == null) {
      return false;
    }

    LandlordRequest d = data.firstWhere((LandlordRequest request) {
     
        return request.getFlatId() == flatId;
      
    }, orElse: () {
      return null;
    });
    return d != null;
  }

  Future<List<LandlordRequest>> getExistingRequests(String userId, String buildingId) async {
    List<LandlordRequest> list = new List();

    QuerySnapshot qs =
        await LandlordRequestsDao.getRequestsSentByMeToOwnerForBuilding(userId, buildingId);
    qs.documents.forEach((DocumentSnapshot ds) {
      LandlordRequest req = LandlordRequest.fromJson(ds.data, ds.documentID);
      list.add(req);
    });

    debugPrint("fetched data again");

    return list;
  }

  Widget getMainExpansionPanelListForJoin(BuildContext scaffoldC) {
    User user = Provider.of<User>(scaffoldC, listen: false);
    return FutureBuilder(
      future: getExistingRequests(user.getUserId(), this.building.getBuildingId()),
      builder: (BuildContext context, AsyncSnapshot<List<LandlordRequest>> documents) {
        if (!documents.hasData) {
          return LoadingContainerVertical(2);
        }
        return Consumer2<JoinPropertyModel, LoadingModel>(
          builder: (BuildContext context, JoinPropertyModel joinPropertyModel, LoadingModel loadingModel,  Widget child) {
            return loadingModel.load? LoadingContainerVertical(5):
            getMainExpansionPanelList(scaffoldC, documents.data, joinPropertyModel);
          },
        ); 
       
      },
    );
  }

  Widget getBlocksListWidget(
      BuildContext scaffoldC, List<LandlordRequest> documents, JoinPropertyModel joinPropertyModel) {
    List<ExpansionPanel> blocksWidget = new List();
    List<Block> blocks = this.building.getBlocks();

    if (blocks == null || blocks.isEmpty) {
      return Container();
    }
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
      Block block, List<LandlordRequest> documents, BuildContext ctx) {
    User user = Provider.of<User>(ctx, listen: false);

    List<OwnerFlat> flats = block.getOwnerFlats();
    if (flats == null || flats.isEmpty) {
      return Container();
    }

    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int position) {
        return Divider(height: 1.0);
      },
      itemCount: flats.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(flats[index].getFlatName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 17.0, color: Color(0xff2079FF))),
          trailing: isOwnerOfFlat(flats[index], user.getUserId()) ||
                  ifRequestToFlatAlreadySent(documents, flats[index].getFlatId())
              ? SizedBox()
              : IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    sendRequestToOwner(ctx, documents,
                        block: block, flat: flats[index]);
                  },
                ),
        );
      },
    );
  }

  void sendRequestToOwner(BuildContext ctx, List<LandlordRequest> existingRequests,
      {Block block, OwnerFlat flat}) async {
 
    User user = Provider.of<User>(ctx, listen: false);

    Provider.of<LoadingModel>(ctx, listen: false).startLoading();


    bool ifSuccess = await OwnerRequestsService.sendRequestToOwner(this.building, block, flat, user);

    if(ifSuccess) {
      
      Utility.createErrorSnackBar(ctx, error: 'Request created successfully');
      LandlordRequest req = new LandlordRequest();
      req.setFlatId(flat.getFlatId());
      existingRequests.add(req);
    } else {
      
      Utility.createErrorSnackBar(ctx, error: 'Error while creating request');
    }
    Provider.of<LoadingModel>(ctx, listen: false).stopLoading();

  }
}
