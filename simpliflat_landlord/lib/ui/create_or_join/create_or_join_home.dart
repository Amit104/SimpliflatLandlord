import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/dao/landlord_requests_dao.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/model/landlord_request.dart';
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
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          getCreateOrJoinOptionsWidget(context),
          getInfoWidget(context),
          ChangeNotifierProvider(
            create: (_) => LoadingModel(),
            builder: (BuildContext context1, Widget child) {
              return getIncomingRequestsWidget(context1, scaffoldC);
            }),
        ],
      ),
    );
  }

  Widget getCreateOrJoinOptionsWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              navigateToCreateProperty(false, context);
            },
            child: ClipRRect(
              child: Stack(children: [
                Image.asset(
                  'assets/images/CreateProperty.jpg',
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.width * 0.40,
                  fit: BoxFit.fill,
                ),
                Positioned(
                    bottom: 15.0,
                    left: 15.0,
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: Center(
                        child: Text(
                      'Create a Property',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 226, 184, 1),
                        fontSize: 20.0,
                      ),
                    ))),
              ]),
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          GestureDetector(
            onTap: () {
              navigateToCreateProperty(true, context);
            },
            child: ClipRRect(
              child: Stack(children: [
                Image.asset(
                  'assets/images/JoinProperty.jpg',
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.width * 0.40,
                  fit: BoxFit.fill,
                ),
                Positioned(
                    bottom: 15.0,
                    left: 15.0,
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: Center(
                        child: Text(
                      'Join a Property',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 226, 184, 1),
                          fontSize: 20.0),
                    ))),
              ]),
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Text(
              'Welcome to Simpliflat Landlord',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          Container(
            child: Text(
              'Please create a property or join an existing one.',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            child: Text(
              'We make management of your property easy.',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getIncomingRequestsWidget(BuildContext provCxt, BuildContext scaffoldC) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Incoming Requests',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 10.0),
          getIncomingRequestsDataWidget(provCxt, scaffoldC),
        ],
      ),
    );
  }

  Widget getIncomingRequestsDataWidget(BuildContext provCxt, BuildContext scaffoldC) {
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
              itemCount: snapshots.data.documents.length,
              itemBuilder: (BuildContext context, int position) {
                
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
                            elevation: 5.0,
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
                                          acceptRequest(req, scaffoldC, provCxt);
                                          Utility.addToSharedPref(
                                              propertyRegistered: true);
                                        },
                                      )),
                                  Expanded(
                                    child: Column(children: [
                                      Text(
                                        getTitleText(req),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        'Please join as co-owner',
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12.0),
                                      )
                                    ]),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(10.0),
                                      child: IconButton(
                                        icon: Icon(Icons.close,
                                            color: Colors.red, size: 25.0),
                                        onPressed: () {
                                          rejectRequest(req, scaffoldC, provCxt);
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
      LandlordRequest request, BuildContext scaffoldC, BuildContext provCxt) async {
    Provider.of<LoadingModel>(provCxt, listen: false).startLoading();
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

    Provider.of<LoadingModel>(provCxt, listen: false).stopLoading();
    return ifSuccess;
  }

  void acceptRequest(LandlordRequest request, BuildContext scaffoldC, BuildContext provCxt) async {
    Provider.of<LoadingModel>(provCxt, listen: false).startLoading();

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

    Provider.of<LoadingModel>(provCxt, listen: false).stopLoading();
  }

  navigateToHome(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return Home();
    }));
  }
}
