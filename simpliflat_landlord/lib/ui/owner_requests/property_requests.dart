import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/dao/landlord_requests_dao.dart';
import 'package:simpliflat_landlord/model/landlord_request.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/services/owner_requests_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/view_model/join_property_model.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';


/// page to send a request to a user requesting that user to be co-owner
class PropertyRequests extends StatelessWidget {

  final Building building;

  final Owner toOwner;

  PropertyRequests(this.building, this.toOwner);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
                              create: (_) => LoadingModel(),
                              child: ChangeNotifierProvider(
                                create: (_) => JoinPropertyModel(),
                                child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Add Owner'),
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          return Container(
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
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        debugPrint(isExpanded.toString());
        Provider.of<JoinPropertyModel>(scaffoldC, listen: false).expandBuilding();
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(building.getBuildingName()),
            );
          },
          body: getBlocksListWidget(scaffoldC, data, joinPropertyModel),
          isExpanded: joinPropertyModel.isBuildingExpanded(),
        ),
      ],
    );
  }


  bool isOwnerOfFlat(OwnerFlat flat) {
    
      if (flat.getOwnerIdList().contains(this.toOwner.getOwnerId())) {
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

  Future<List<LandlordRequest>> getExistingRequestsData() async {
    List<LandlordRequest> list = new List();
    
    QuerySnapshot qs = await LandlordRequestsDao.getCoownerRequestsSentByMeForBuildingD(this.building.getBuildingId(), this.toOwner.getOwnerId());
    qs.documents.forEach((DocumentSnapshot ds) {
      LandlordRequest req = LandlordRequest.fromJson(ds.data, ds.documentID);
      list.add(req);
    });

    return list;
  }

  Widget getMainExpansionPanelListForJoin(BuildContext scaffoldC) {
    return FutureBuilder(
      future: getExistingRequestsData(),
      builder: (BuildContext context, AsyncSnapshot<List<LandlordRequest>> documents) {
        if (!documents.hasData) {
          return LoadingContainerVertical(2);
        }
        return Consumer2<JoinPropertyModel, LoadingModel>(
          builder: (BuildContext context, JoinPropertyModel joinPropertyModel, LoadingModel loadingModel,  Widget child) {
            return loadingModel.load? LoadingContainerVertical(5):
         getMainExpansionPanelList(scaffoldC, documents.data, joinPropertyModel);
          });
      },
    );
  }

  Widget getBlocksListWidget(
      BuildContext scaffoldC, List<LandlordRequest> documents, JoinPropertyModel joinPropertyModel) {
    List<ExpansionPanel> blocksWidget = new List();
    List<Block> blocks = this.building == null? List(): this.building.getBlocks();

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
    List<OwnerFlat> flats = block.getOwnerFlats();
    if (flats == null || flats.isEmpty) {
      return Container();
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
                  ifRequestToFlatAlreadySent(documents, flats[index].getFlatId())
              ? SizedBox()
              : IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () async {
                    sendRequestToCoOwner(ctx,
                        forFlat: true, block: block, flat: flats[index], existingRequests: documents);
                  },
                ),
        );
      },
    );
  }

  Future<bool> sendRequestToCoOwner(BuildContext ctx,
      {bool forFlat, Block block, OwnerFlat flat, List<LandlordRequest> existingRequests}) async {
    
    User user = Provider.of<User>(ctx, listen: false);
    Provider.of<LoadingModel>(ctx, listen: false).startLoading();

    bool ifSuccess = await OwnerRequestsService.sendRequestToCoOwner(flat, user, this.toOwner);

    if(ifSuccess) {
       
      Utility.createErrorSnackBar(ctx, error: 'Request created successfully');
      LandlordRequest req = new LandlordRequest();
      req.setFlatId(flat.getFlatId());
      existingRequests.add(req);
    } else {
      
      Utility.createErrorSnackBar(ctx, error: 'Error while creating request');
    }

    Provider.of<LoadingModel>(ctx, listen: false).stopLoading();

    return ifSuccess;
  }
}
