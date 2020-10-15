import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          title: Text('Add Tenant'),
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
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        Provider.of<JoinPropertyModel>(scaffoldC, listen: false).expandBuilding();
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(this.building.getBuildingName()),
            );
          },
          body: getBlocksListWidget(scaffoldC, tenantRequests, joinPropertyModel),
          isExpanded: joinPropertyModel.isBuildingExpanded(),
        ),
      ],
    );
  }


  Widget getBlocksListWidget(
      BuildContext scaffoldC, List<TenantRequest> tenantRequests, JoinPropertyModel joinPropertyModel) {
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
            title: Text(blocks[i].blockName),
          );
        },
        body: getFlatNamesWidget(blocks[i], scaffoldC, tenantRequests, joinPropertyModel),
        isExpanded: joinPropertyModel.isBlockExpanded(blocks[i].getBlockName()),
      ));
    }
    return new ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) async {
        Provider.of<JoinPropertyModel>(scaffoldC, listen: false).expandBlock(blocks[index].getBlockName());
      },
      children: blocksWidget,
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

    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int position) {
        return Divider(height: 1.0);
      },
      itemCount: flats.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(flats[index].getFlatName()),
          trailing: ifRequestToFlatAlreadySent(tenantRequests, flats[index].getFlatId())
              ? SizedBox(): IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    sendRequestToTenant(ctx,
                        forFlat: true, block: block, flat: flats[index]);
                  },
                ),
        );
      },
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
