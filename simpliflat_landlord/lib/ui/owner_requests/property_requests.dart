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
                              getBody(scaffoldC),
                            ]),
                          ),
                  );
                }))));
  }

  Widget getBody(BuildContext scaffoldC) {
    return FutureBuilder(
      future: getExistingRequestsData(),
      builder: (BuildContext context,
          AsyncSnapshot<List<LandlordRequest>> documents) {
        if (!documents.hasData) {
          return LoadingContainerVertical(2);
        }
        return Consumer2<JoinPropertyModel, LoadingModel>(builder:
            (BuildContext context, JoinPropertyModel joinPropertyModel,
                LoadingModel loadingModel, Widget child) {
          return loadingModel.load
              ? LoadingContainerVertical(5)
              : getMainExpansionPanelList(
                  scaffoldC, documents.data, joinPropertyModel);
        });
      },
    );
  }

  Future<List<LandlordRequest>> getExistingRequestsData() async {
    List<LandlordRequest> list = new List();

    QuerySnapshot qs =
        await LandlordRequestsDao.getCoownerRequestsSentByMeForBuildingD(
            this.building.getBuildingId(), this.toOwner.getOwnerId());
    qs.documents.forEach((DocumentSnapshot ds) {
      LandlordRequest req = LandlordRequest.fromJson(ds.data, ds.documentID);
      list.add(req);
    });

    return list;
  }

  Widget getMainExpansionPanelList(
      BuildContext scaffoldC,
      List<LandlordRequest> landlordRequests,
      JoinPropertyModel joinPropertyModel) {
    return Column(
      children: [
        Container(
                                    color: Color(0xff2079FF),
                                                                      child: ListTile(
                                                                        contentPadding: EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15.0),
                                      
                                      title: Text(building.getBuildingName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20.0, color: Colors.white)),
                                    ),
                                  ),
        getBlocksListWidget(scaffoldC, landlordRequests, joinPropertyModel),
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

  Widget getBlocksListWidget(
      BuildContext scaffoldC,
      List<LandlordRequest> existingLandlordRequests,
      JoinPropertyModel joinPropertyModel) {
    List<Block> blocks = this.building.getBlocks();

    if (blocks == null || blocks.isEmpty) {
      return Container();
    }
    return ListView.separated(
      separatorBuilder: (BuildContext context, int pos) {
        return Divider(height: 1.0);
      },
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: blocks.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int pos) {
        return getFlatNamesWidget(
            blocks[pos], context, existingLandlordRequests, joinPropertyModel);
      },
    );
  }

  Widget getFlatNamesWidget(
      Block block,
      BuildContext ctx,
      List<LandlordRequest> existingLandlordRequests,
      JoinPropertyModel joinPropertyModel) {
    List<OwnerFlat> flats = block.getOwnerFlats();
    if (flats == null || flats.isEmpty) {
      return Container();
    }

    return Container(
      child: Column(children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20.0, top: 15.0, bottom: 10.0),
          child: Text(
            block.getBlockName(),
            style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 17.0),
          ),
        ),
        Container(
          height: 50.0,
          margin: EdgeInsets.only(bottom: 10.0, left: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: flats.length,
            itemBuilder: (BuildContext context, int index) {
              return isOwnerOfFlat(flats[index]) ||
                      ifRequestToFlatAlreadySent(
                          existingLandlordRequests, flats[index].getFlatId())
                  ? SizedBox()
                  : Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 10.0),
                      margin: EdgeInsets.all(5.0),
                      child: GestureDetector(
                          onTap: () {
                            sendRequestToCoOwner(ctx,
                                forFlat: true,
                                block: block,
                                flat: flats[index],
                                existingRequests: existingLandlordRequests);
                          },
                          child: Text(flats[index].getFlatName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 17.0, color: Color(0xff2079FF)))),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          border: Border.all(
                            color: Color(0xff2079FF),
                          )),
                    );
            },
          ),
        ),
      ]),
    );
  }

  Future<bool> sendRequestToCoOwner(BuildContext ctx,
      {bool forFlat,
      Block block,
      OwnerFlat flat,
      List<LandlordRequest> existingRequests}) async {
    User user = Provider.of<User>(ctx, listen: false);
    Provider.of<LoadingModel>(ctx, listen: false).startLoading();

    bool ifSuccess = await OwnerRequestsService.sendRequestToCoOwner(
        flat, user, this.toOwner);

    if (ifSuccess) {
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
