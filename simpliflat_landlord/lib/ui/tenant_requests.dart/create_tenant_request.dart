import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/dao/owner_tenant_dao.dart';
import 'package:simpliflat_landlord/dao/tenant_requests_dao.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/model/block.dart';
import 'package:simpliflat_landlord/model/building.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/tenant_flat.dart';
import 'package:simpliflat_landlord/model/tenant_request.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/services/tenant_requests_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/ui/home/home.dart';
import 'package:simpliflat_landlord/view_model/join_property_model.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';

/// page to create tenant request
class CreateTenantRequest extends StatelessWidget {

  final TenantFlat tenantFlat;

  final Building building;

  CreateTenantRequest(this.building, this.tenantFlat);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
                              create: (_) => LoadingModel(),
                              child: ChangeNotifierProvider(
                                create: (_) => JoinPropertyModel(),
                            child:  Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Select Flat', style: CommonWidgets.getAppBarTitleStyle()),
          elevation: 0,
          centerTitle: true,
        ),
        body: Builder(builder: (BuildContext scaffoldC) {
          return Container(
                  child: SingleChildScrollView(
                          child: Column(children: [
                            getBody(scaffoldC),
                              
                          ]),
                        ),
                );
        }))));
  }

  Widget getBody(BuildContext scaffoldContext) {
    return StreamBuilder(
      stream: TenantRequestsDao.getReceivedRequestsForBuilding(this.building.getBuildingId()),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> documents) {
        if (!documents.hasData) {
          return LoadingContainerVertical(2);
        }
        List<TenantRequest> tenantRequests = new List();
        documents.data.documents.forEach((DocumentSnapshot ds) {
          tenantRequests.add(TenantRequest.fromJson(ds.data, ds.documentID));
        });
        return Consumer2<JoinPropertyModel, LoadingModel>(
          builder: (BuildContext context, JoinPropertyModel joinPropertyModel, LoadingModel loadingModel,  Widget child) {
            return loadingModel.load? LoadingContainerVertical(5):
         getMainExpansionPanelList(scaffoldContext, tenantRequests, joinPropertyModel);
          });
      },
    );
  }



  Widget getMainExpansionPanelList(
      BuildContext scaffoldC, List<TenantRequest> tenantRequests, JoinPropertyModel joinPropertyModel) {
    return Column(
        
        children: [
    Container(
        color: Color(0xff2079FF),
          child: ListTile(
        title: Text(this.building.getBuildingName(), style: TextStyle(color: Colors.white),),
      ),
    ),
    getBlocksListWidget(scaffoldC, tenantRequests, joinPropertyModel),
        ],
      );
  }


  Widget getBlocksListWidget(
      BuildContext scaffoldC, List<TenantRequest> tenantRequests, JoinPropertyModel joinPropertyModel) {
    List<Block> blocks = this.building.getBlocks();
    debugPrint('blocks is empty');

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
    return getFlatNamesWidget(blocks[pos], context, tenantRequests, joinPropertyModel);
        },
      );
  }

  bool ifRequestToFlatAlreadySent(List<TenantRequest> data, String flatId) {
    if (data == null || data.isEmpty || flatId == null) {
      return false;
    }

    TenantRequest d = data.firstWhere((request) {
     
        return request.getOwnerFlatId() == flatId;
      
    }, orElse: () {
      return null;
    });

    return d != null;
  }

  Widget getFlatNamesWidget(
      Block block, BuildContext ctx, List<TenantRequest> tenantRequests, JoinPropertyModel joinPropertyModel) {
    List<OwnerFlat> flats = block.getOwnerFlats();
    if (flats == null || flats.isEmpty) {
      return Container();
    }

    return Container(
        color: Colors.blue[100],
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left:20.0, top: 15.0, bottom: 10.0),
              child: Text(block.getBlockName(), style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
          fontSize: 17.0),),
            ),
            Container(
              height:50.0,
              margin: EdgeInsets.only(bottom: 10.0),
                              child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: flats.length,
      itemBuilder: (BuildContext context, int index) {
        return ifRequestToFlatAlreadySent(tenantRequests, flats[index].getFlatId())? SizedBox(): Container(
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          margin: EdgeInsets.all(5.0),
          child: GestureDetector(
              onTap: () {
                sendRequestToTenant(ctx,
                        forFlat: true, block: block, flat: flats[index]);
              },
              child: Text(flats[index].getFlatName(), style: TextStyle(color: Color(0xff2079FF),))
          ),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20.0)), border: Border.all(color: Color(0xff2079FF),)),
        );
      },
          ),
            ),
          ]),
      );
  }

  void sendRequestToTenant(BuildContext ctx,
      {bool forFlat, Block block, OwnerFlat flat}) async {
    Utility.createErrorSnackBar(ctx, error: 'Creating request...');
    Provider.of<LoadingModel>(ctx, listen: false).startLoading();

    QuerySnapshot s = await OwnerTenantDao.getByOwnerFlatId(flat.getFlatId());

    if(s.documents.length > 0) {
      showDialog(
        context: ctx,
        barrierDismissible: true,
        child: AlertDialog(
          title: Text('Warning'),
          content: Text('The flat is already assigned to someone. Vacate the flat to add new tenants'),
          actions: <Widget>[
            
            RaisedButton(child: Text('OK'), onPressed: () {
              Navigator.of(ctx,
                                                    rootNavigator: true)
                                                .pop();
            })
          ],
        ),
      );
    }
    else {
      createTenantRequest(ctx, block, flat);
    }

    Provider.of<LoadingModel>(ctx, listen: false).stopLoading();

  }

  void createTenantRequest(BuildContext ctx, Block block, OwnerFlat ownerFlat) async {
      User user = Provider.of<User>(ctx, listen: false);
      ownerFlat.setBuildingAddress(this.building.getBuildingAddress());
      ownerFlat.setZipcode(this.building.getZipcode());
      bool ifSuccess = await TenantRequestsService.createTenantRequest(ownerFlat, user, this.tenantFlat);
       
      if(ifSuccess) {
      
      Utility.createErrorSnackBar(ctx, error: 'Request created successfully');
        Navigator.of(ctx).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
        ctx,
        MaterialPageRoute(builder: (context) {
          return Home();
        }),
      );
      
    } else {
      
      Utility.createErrorSnackBar(ctx, error: 'Error while creating request');
    }
  }
}
