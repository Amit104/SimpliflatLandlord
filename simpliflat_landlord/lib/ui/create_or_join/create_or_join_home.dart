import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/constants/colors.dart';
import 'package:simpliflat_landlord/constants/strings.dart';
import 'package:simpliflat_landlord/dao/landlord_requests_dao.dart';
import 'package:simpliflat_landlord/main.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/model/landlord_request.dart';
import 'package:simpliflat_landlord/services/authentication_service.dart';
import 'package:simpliflat_landlord/ui/create_or_join/flat_list.dart';
import 'package:simpliflat_landlord/utility/utility.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/services/owner_requests_service.dart';
import 'package:simpliflat_landlord/ui/home/home.dart';
import 'package:simpliflat_landlord/view_model/loading_model.dart';

class CreateOrJoinHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Simpliflat Landlord Portal'),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext scaffoldC) {
        return getBody(scaffoldC, context);
      }),
    );
  }

  Widget getBody(BuildContext scaffoldC, BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              getInfoWidget(context),
              getCreateOrJoinOptionsWidget(context),
              ChangeNotifierProvider(
                create: (_) => LoadingModel(),
                builder: (context, child) =>
                    getIncomingRequestsWidget(context),
              ),
            ],
          ),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              child: getSignOutButton(scaffoldC),
              height: 40.0,
            ),
          ),
        )),
      ],
    );
  }

  Widget getSignOutButton(BuildContext context) {
    return RaisedButton(
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(25.0),
        side: BorderSide(
          width: 0.0,
        ),
      ),
      color: AppColors.PRIMARY_COLOR,
      textColor: Colors.white,
      onPressed: () {
        showDialog<bool>(
          context: context,
          builder: (context) {
            return new AlertDialog(
              title: new Text('Sign out'),
              content: new Text('Are you sure you want to sign out?'),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                new FlatButton(
                    child: new Text('Yes'),
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                      await AuthenticationService.signOut();
                      navigateToSignIn(context);
                    }),
              ],
            );
          },
        );
      },
      child: Text(
        'SIGN OUT',
        style: TextStyle(
            fontFamily: Strings.PRIMARY_FONT_FAMILY,
            fontWeight: Strings.PRIMARY_FONT_WEIGHT,
            color: Colors.white),
      ),
    );
  }

  navigateToSignIn(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return MyApp();
    }));
  }


  Widget getCreateOrJoinOptionsWidget(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(),
            flex: 2,
          ),
          GestureDetector(
            onTap: () {
              navigateToCreateProperty(false, context);
            },
            child: SizedBox(
              height: 225,
              width: deviceSize.width * 0.42,
              child: new Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  color: Colors.black87,
                  elevation: 2.0,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Color(0xff6C67D3)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                left: 28.0,
                                top: 40.0,
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 30.0,
                                color: Colors.white,
                              )),
                          textInCard(
                              "CREATE", FontWeight.w700, 21.0, 28.0, 10.0),
                          textInCard(
                              "A FLAT", FontWeight.normal, 21.0, 28.0, 3.0),
                          textInCard(
                              "Create a new flat", null, 14.0, 28.0, 8.0),
                          textInCard("and invite your", null, 14.0, 28.0, 4.0),
                          textInCard("flatmates", null, 14.0, 28.0, 4.0),
                        ]),
                  )),
            ),
          ),
          Expanded(
            child: Container(),
            flex: 3,
          ),
          GestureDetector(
            onTap: () {
              navigateToCreateProperty(true, context);
            },
            child: SizedBox(
              height: 225,
              width: deviceSize.width * 0.42,
              child: new Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  color: Color(0xff2079FF),
                  elevation: 2.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                left: 28.0,
                                top: 40.0,
                              ),
                              child: Icon(
                                Icons.play_circle_outline,
                                size: 30.0,
                                color: Colors.white,
                              )),
                          textInCard("JOIN", FontWeight.w700, 21.0, 28.0, 10.0),
                          textInCard(
                              "A FLAT", FontWeight.normal, 21.0, 28.0, 3.0),
                          textInCard("Search for your", null, 14.0, 28.0, 8.0),
                          textInCard("flat and send a", null, 14.0, 28.0, 4.0),
                          textInCard("request", null, 14.0, 28.0, 4.0),
                        ]),
                  )),
            ),
          ),
          Expanded(
            child: Container(),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget textInCard(text, weight, size, padLeft, padTop) {
    return Padding(
      padding: EdgeInsets.only(top: padTop, left: padLeft),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: size,
          color: Colors.white,
          fontFamily: Strings.PRIMARY_FONT_FAMILY,
          fontWeight: Strings.PRIMARY_FONT_WEIGHT,
        ),
      ),
    );
  }



  void navigateToCreateProperty(bool join, BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return FlatList(join);
      }),
    );
  }

  Widget getInfoWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Text(
              'Welcome to Simpliflat',
              style: TextStyle(
                fontFamily: Strings.PRIMARY_FONT_FAMILY,
                fontWeight: Strings.PRIMARY_FONT_WEIGHT,
                fontSize: 22.0,
                color: AppColors.PRIMARY_COLOR,
              ),
            ),
          ),
          Container(
            child: Text(
              'Please create a flat or join an existing one.',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: Strings.PRIMARY_FONT_FAMILY,
                fontWeight: Strings.PRIMARY_FONT_WEIGHT,
                color: Colors.black54,
              ),
            ),
          ),
          Container(
            child: Text(
              'We make living simple.',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: Strings.PRIMARY_FONT_FAMILY,
                fontWeight: Strings.PRIMARY_FONT_WEIGHT,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getIncomingRequestsWidget(BuildContext scaffoldC) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30.0),
      child: getIncomingRequestsDataWidget(scaffoldC),
    );
  }

  Widget getIncomingRequestsDataWidget(BuildContext scaffoldC) {
    User user = Provider.of<User>(scaffoldC, listen: false);
    return StreamBuilder(
        stream: LandlordRequestsDao.getRequestsSentToMeByOwner(user.getUserId()),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
          if (!snapshots.hasData) {
            return LoadingContainerVertical(2);
          }
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: snapshots.data.documents.length + 1,
              itemBuilder: (BuildContext context, int position) {
                if(snapshots.data.documents.length == 0) return Container();

                if (position == 0 && snapshots.data.documents.length > 0) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Requests',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: Strings.PRIMARY_FONT_FAMILY,
                        fontWeight: Strings.PRIMARY_FONT_WEIGHT,
                        color: AppColors.PRIMARY_COLOR,
                      ),
                    ),
                  );
                }
                Map<String, dynamic> data =
                    snapshots.data.documents[position].data;
                LandlordRequest req = LandlordRequest.fromJson(
                    data, snapshots.data.documents[position].documentID);

                return Consumer<LoadingModel>(
                  builder: (BuildContext context, LoadingModel loadingModel,
                      Widget child) {
                    return loadingModel.load
                        ? LoadingContainerVertical(5)
                        : Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 3.0, horizontal: 12.0),
                            elevation: 1.0,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Row(
                                children: [
                                  Container(
                                      padding: EdgeInsets.all(10.0),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 25.0,
                                        ),
                                        onPressed: () {
                                          acceptRequest(req, scaffoldC);
                                          Utility.addToSharedPref(
                                              propertyRegistered: true);
                                        },
                                      )),
                                  Expanded(
                                    child: Column(children: [
                                      Text(
                                        getTitleText(req),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontFamily:
                                              Strings.PRIMARY_FONT_FAMILY,
                                          fontWeight:
                                              Strings.PRIMARY_FONT_WEIGHT,
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'Please join as co-owner',
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12.0,
                                          fontFamily:
                                              Strings.PRIMARY_FONT_FAMILY,
                                          fontWeight:
                                              Strings.PRIMARY_FONT_WEIGHT,
                                        ),
                                      )
                                      
                                    ]),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(10.0),
                                      child: IconButton(
                                        icon: Icon(Icons.close,
                                            color: Colors.red, size: 25.0),
                                        onPressed: () {
                                          rejectRequest(req, scaffoldC);
                                        },
                                      )),
                                ],
                              ),
                            ),
                          );
                  },
                );
              });
        });
  }

  String getTitleText(request) {
    if (request.getFlatId() == null) {
      return 'Request for building ' + request.getBuildingName();
    } else {
      return 'Request for flat ' + request.getFlatNumber();
    }
  }

  Future<bool> rejectRequest(
      LandlordRequest request, BuildContext scaffoldC) async {
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();
    Utility.createErrorSnackBar(scaffoldC, error: 'Rejecting request');
    bool ifSuccess = await OwnerRequestsService.rejectRequest(request);
    if(ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Request rejected successfully');
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Error while rejecting request');
    };

    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();
    return ifSuccess;
  }

  void acceptRequest(LandlordRequest request, BuildContext scaffoldC) async {
    Provider.of<LoadingModel>(scaffoldC, listen: false).startLoading();

    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');

    bool ifSuccess = await OwnerRequestsService.acceptRequestFromOwner(request);

    if (ifSuccess) {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Request accepted successfully');
      Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();

      navigateToHome(scaffoldC);
    } else {
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC,
          error: 'Error while accepting request');
    }

    Provider.of<LoadingModel>(scaffoldC, listen: false).stopLoading();
  }

  navigateToHome(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return Home();
    }));
  }
}
