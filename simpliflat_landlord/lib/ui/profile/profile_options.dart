import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/constants/colors.dart';
import 'package:simpliflat_landlord/dao/owner_dao.dart';
import 'package:simpliflat_landlord/dao/owner_flat_dao.dart';
import 'package:simpliflat_landlord/dao/owner_tenant_dao.dart';
import 'package:simpliflat_landlord/dao/tenant_dao.dart';
import 'package:simpliflat_landlord/model/owner_tenant.dart';
import 'package:simpliflat_landlord/model/tenant.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/services/profile_options_service.dart';
import 'package:simpliflat_landlord/ui/flat_setup/add_tenant.dart';
import 'package:simpliflat_landlord/constants/globals.dart' as globals;
import 'package:simpliflat_landlord/ui/home/home.dart';
import 'package:simpliflat_landlord/model/owner.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/models.dart';
import 'package:simpliflat_landlord/ui/owner_requests/search_owner.dart';
import 'package:simpliflat_landlord/ui/signup/signup_otp.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/services/owner_requests_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';


class ProfileOptions extends StatelessWidget {

  Set editedData = Set();
  var _formKey1 = GlobalKey<FormState>();
  var _minimumPadding = 5.0;
  BuildContext _scaffoldContext;
  TextEditingController textField = TextEditingController();
  //String userName;

  final User user;
  final OwnerTenant flat;

  ProfileOptions(this.user, this.flat);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return WillPopScope(
        onWillPop: () {
          _moveToLastScreen(context);
          return null;
        },
        child: ChangeNotifierProvider(
          create: (_) => LoadingModel(),
        child: Scaffold(
        appBar: AppBar(
          title: Text('Profile Options', style: CommonWidgets.getAppBarTitleStyle()),
          centerTitle: true,
          elevation: 0,
        ),
            body: Builder(builder: (BuildContext scaffoldC) {
              _scaffoldContext = scaffoldC;
              return Consumer<LoadingModel>(
                      builder: (BuildContext conCxt, LoadingModel loadingModel, Widget child) {
                      
                        if(loadingModel.load) return LoadingContainerVertical(3);
                              return Center(
                    child: ListView(children: <Widget>[
                      getFlatDetailsWidget(scaffoldC),
                      SizedBox(height: 10),
                      getFlatMembersPanel(),
                      
                      SizedBox(height:10),

                      getOwnersPanel(scaffoldC),
                      
                      SizedBox(height:10),

                      getOwnerButtonsPanel(scaffoldC),
                      
                      SizedBox(height: 30)
                    ]));
                      });
            }))));
  }

  Widget getOwnerButtonsPanel(BuildContext scaffoldC) {
    return Container(
      width: MediaQuery.of(scaffoldC).size.width,
      height: 80,
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [GestureDetector(
              onTap: () {
                                   Navigator.push(
                      scaffoldC,
                      MaterialPageRoute(builder: (context) {
                          return SearchOwner(this.flat.getOwnerFlat());
                      }),
                     );

                  },
                  child: Container(
            width: MediaQuery.of(scaffoldC).size.width * 0.45,
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20)), border: Border.all(color: AppColors.PRIMARY_COLOR)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [Text('Add Owner', style: TextStyle(
                                  fontSize: 17.0,
                                  fontFamily: 'Roboto',
                                  color: Color(0xff2079FF),
                                  fontWeight: FontWeight.w600
                                ),),
                                Icon(Icons.add, color: AppColors.PRIMARY_COLOR,)],
                           
                 
                          ),
                        ),
        ),
                      GestureDetector(
                        onTap: () {
                                   showDialog<bool>(
                            context: scaffoldC,
                            builder: (context) {
                              return new AlertDialog(
                                title: new Text('Evacuate Flat'),
                                content: new Text(
                                    'Are you sure you want to evacuate this flat?'),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: new Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  new FlatButton(
                                      child: new Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                        _evacuateFlat(scaffoldC);
                                      }),
                                ],
                              );
                            },
                          );
                        

                },
                                              child: Container(
                          width: MediaQuery.of(scaffoldC).size.width * 0.45,
          padding: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20)), border: Border.all(color: AppColors.PRIMARY_COLOR)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:[Text('Evacuate Flat', style: TextStyle(
                                  fontSize: 17.0,
                                  fontFamily: 'Roboto',
                                  color: Color(0xff2079FF),
                                  fontWeight: FontWeight.w600
                                ),),
                                Icon(Icons.close, color: AppColors.PRIMARY_COLOR,)],
                           
                
                          ),
                        ),
                      )],
      ),
    );
  }

  Widget getFlatDetailsWidget(BuildContext context) {
    return Stack(
      children: [
          Container(
        height: 150,
        width: MediaQuery.of(context).size.width,
        child: Image.asset('assets/images/CreateProperty.jpg',
                fit: BoxFit.fill)
      ),
      Container(
        margin: EdgeInsets.only(top: 60, left: 20),
        child: Text(this.flat.getOwnerFlat().getBlockName() + ' - ' + this.flat.getOwnerFlat().getFlatName(), style: CommonWidgets.getTextStyleBold(size: 20, color: Colors.white),)),
      Container(
        margin: EdgeInsets.only(top: 90, left: 20),
        child: Text(this.flat.getOwnerFlat().getBuildingName() + ', ' + this.flat.getOwnerFlat().getZipcode(), style: CommonWidgets.getTextStyleBold(size: 17, color: Colors.white),)),
      ],
    );
  }

  Widget getFlatMembersPanel() {
    return Container(
                      color: Colors.white,
                                          child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                        padding: EdgeInsets.only(left: 10.0, top: 10.0),
                        child: Text(
                          "Flat Members",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Roboto',
                            color: Color(0xff2079FF),
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5.0),
                        height: 90.0,
                        child: _getExistingUsers(),
                      )]),
                    );
  }

  Widget getOwnersPanel(BuildContext scaffoldC) {
    return Container(
                      color: Colors.white,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Padding(
                        padding: EdgeInsets.only(left: 10.0, top: 10.0),
                        child: Text(
                          "Owners",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Roboto',
                            color: Color(0xff2079FF),
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5.0),
                        height: 90.0,
                        child: _getOwners(scaffoldC),
                      )]),
                    );
  }

  _moveToLastScreen(BuildContext _navigatorContext) {
    debugPrint("Back");
    Navigator.pop(_navigatorContext, {'editedData': editedData});
  }

  Widget _getOwners(BuildContext scaffoldC) {
    return ListView.builder(
        itemCount: this.flat.getOwnerFlat().getOwners().length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int position) {
          return SizedBox(
            width: 100,
            height: 90,
            child: Card(
              color: Colors.white30,
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onLongPress: () {
                        debugPrint("on long press");
                        if(ifUserIsAdmin() && userAndSelectedDifferent(this.flat.getOwnerFlat().getOwners()[position])) {
                          getOwnerActions(scaffoldC, this.flat.getOwnerFlat().getOwners()[position]);

                        }
                      },
                                          child: CircleAvatar(
                        backgroundColor: Utility.userIdColor(
                            this.flat.getOwnerFlat().getOwners()[position].getOwnerId()),
                        child: Align(
                          child: Text(
                            this.flat.getOwnerFlat().getOwners()[position]
                                .getName() == ""
                                ? "S"
                                : 
                                this.flat.getOwnerFlat().getOwners()[position]
                                .getName()[0]
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Roboto',
                              color: Colors.white,
                            ),
                          ),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7.5),
                      child: Text(
                        this.flat.getOwnerFlat().getOwners()[position]
                              .getName(),
                        style:
                        TextStyle(fontSize: 14.0, fontFamily: 'Roboto', fontWeight: FontWeight.w600),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget getEvacuateFlatPanel(BuildContext scaffoldC) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20)), border: Border.all(color: AppColors.PRIMARY_COLOR)),
                      margin: EdgeInsets.only(left:10, top: 5, bottom: 10, right: 10),
                                          child: ListTile(
title: Text('Evacuate Flat', style: TextStyle(
                              fontSize: 17.0,
                              fontFamily: 'Roboto',
                              color: Color(0xff2079FF),
                              fontWeight: FontWeight.w600
                            ),),
                            trailing: Icon(Icons.home, color: AppColors.PRIMARY_COLOR,),
                        onTap: () {
                          showDialog<bool>(
                            context: scaffoldC,
                            builder: (context) {
                              return new AlertDialog(
                                title: new Text('Evacuate Flat'),
                                content: new Text(
                                    'Are you sure you want to evacuate this flat?'),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: new Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  new FlatButton(
                                      child: new Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                        _evacuateFlat(scaffoldC);
                                      }),
                                ],
                              );
                            },
                          );
                        },
                       
                      ),
                    );
  }

  void getOwnerActions(BuildContext scaffoldC, Owner ownerTemp) async {
 final action = CupertinoActionSheet(
      title: Text(
        "Actions",
        style: TextStyle(fontSize: 25),
      ),
      actions: <Widget>[
        ifUserIsAdmin() && userAndSelectedDifferent(ownerTemp)? CupertinoActionSheetAction(
          child: Text("Remove"),
          onPressed: () {
            Navigator.of(scaffoldC, rootNavigator: true).pop();
            _removeOwnerForFlat(scaffoldC, ownerTemp);
          },
        ):Container(),
        ifUserIsAdmin() && userAndSelectedDifferent(ownerTemp)? CupertinoActionSheetAction(
          child: Text("Make Admin"),
          onPressed: () {
            Navigator.of(scaffoldC, rootNavigator: true).pop();
            _makeOwnerAdminForFlat(scaffoldC, ownerTemp);
          },
        ):Container(),
        
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(scaffoldC, rootNavigator: true).pop();
        },
      ),
    );
    showCupertinoModalPopup(context: scaffoldC, builder: (context) => action);
                
  }

  bool userAndSelectedDifferent(Owner owner) {
    return owner.getOwnerId() != this.user.getUserId();
  }

  void _makeOwnerAdminForFlat(BuildContext scaffoldC, Owner ownerTemp) async {
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();
    Utility.createErrorSnackBar(scaffoldC, error: 'Changing Admin');
    bool ifSucess = await ProfileOptionsService.makeOwnerAdminForFlat(ownerTemp, this.flat);
    Scaffold.of(scaffoldC).hideCurrentSnackBar();
    if(ifSucess) {
      Owner newAdmin = this.flat.getOwnerFlat().getOwners().firstWhere((Owner ownerTemp1) {
        return ownerTemp1.getOwnerId() == ownerTemp.getOwnerId();
      }, orElse: () {return null;});
      newAdmin.setRole(globals.OwnerRoles.Admin.index.toString());
      Owner oldAdmin = this.flat.getOwnerFlat().getOwners().firstWhere((Owner ownerTemp1) {
        return ownerTemp1.getOwnerId() == this.user.getUserId();
      }, orElse: () {return null;});
      oldAdmin.setRole(globals.OwnerRoles.Manager.index.toString());
      Utility.createErrorSnackBar(scaffoldC, error: 'Admin changed successfully');
    }
    else {
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while changing admin');
    }
    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();
  }

  bool ifUserIsAdmin() {
    if(this.flat.getOwnerFlat().getOwners() != null) {
      Owner allowed = this.flat.getOwnerFlat().getOwners().firstWhere((Owner ownerTemp1) {
        return ownerTemp1.getOwnerId() == this.user.getUserId() && ownerTemp1.getRole() == globals.OwnerRoles.Admin.index.toString();
      }, orElse: () {return null;});

      return (allowed != null);
    }
    return false;
  }

  void _removeOwnerForFlat(BuildContext scaffoldC, Owner ownerTemp) async {
    /** check if user is allowed to remove owner */
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();
    Utility.createErrorSnackBar(scaffoldC, error: 'Removing owner...');
    if(this.flat.getOwnerFlat().getOwners() != null) {
      Owner allowed = this.flat.getOwnerFlat().getOwners().firstWhere((Owner ownerTemp1) {
        return ownerTemp1.getOwnerId() == this.user.getUserId() && ownerTemp1.getRole() == globals.OwnerRoles.Admin.index.toString();
      }, orElse: () {return null;});
      if(allowed == null) {
        //not allowed to remove as this user is not admin
        return;
      }
    }
    
    bool ifSuccess = await OwnerRequestsService.removeOwnerFromFlat(ownerTemp, flat.getOwnerFlat());
    Scaffold.of(scaffoldC).hideCurrentSnackBar();
    if(ifSuccess) {
      this.flat.getOwnerFlat().getOwners().removeWhere((Owner owner) {
        return owner.getOwnerId() == ownerTemp.getOwnerId();
      });
      Utility.createErrorSnackBar(scaffoldC, error: 'Owner removed successfully');
    }
    else {
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while removoing owner');
    }

    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();

  }

  void _evacuateFlat(BuildContext scaffoldC) async {
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();
    Utility.createErrorSnackBar(scaffoldC, error: 'Evacuating flat...');
    bool ifSuccess = await ProfileOptionsService.evacuateFlat(this.flat.getOwnerTenantId());
    Scaffold.of(scaffoldC).hideCurrentSnackBar();
    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();

    if(ifSuccess) {
      this.flat.setTenantFlat(null);
      Navigator.of(scaffoldC).pop();
      Navigator.of(scaffoldC).push(
        new MaterialPageRoute(
          builder: (BuildContext ctx) {
            return AddTenant(this.flat.getOwnerFlat(), this.flat.getOwnedFlats());
          }
        )
      );
    } else {
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while evacuating flat');
    }
    
  }

  ListView _getExistingUsers() {
    List<Tenant> tenants = this.flat.getTenantFlat().getTenants();
    return ListView.builder(
        itemCount: tenants.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int position) {
          return SizedBox(
            width: 100,
            height: 90,
            child: Card(
              color: Colors.white30,
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Utility.userIdColor(
                          tenants[position].getTenantId()),
                      child: Align(
                        child: Text(
                          tenants[position].getName() == ""
                              ? "S"
                              : tenants[position].getName()[0]
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Roboto',
                            color: Colors.white,
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 7.5),
                      child: Text(
                        tenants[position].getName(),
                        style:
                        TextStyle(fontSize: 14.0, fontFamily: 'Roboto', fontWeight: FontWeight.w600),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
