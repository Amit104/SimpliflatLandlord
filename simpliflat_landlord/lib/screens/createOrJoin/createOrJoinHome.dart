import 'package:flutter/material.dart';
import 'package:simpliflat_landlord/screens/createOrJoin/FlatList.dart';
import 'package:simpliflat_landlord/screens/models/LandlordRequest.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';
import 'package:simpliflat_landlord/screens/utility.dart';
import 'package:simpliflat_landlord/screens/widgets/loading_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/screens/globals.dart' as globals;



class CreateOrJoinHome extends StatefulWidget {

  final Owner user;

  CreateOrJoinHome(this.user);
  
  @override
  State<StatefulWidget> createState() {
    return new CreateOrJoinHomeState(this.user);
  }
}

class CreateOrJoinHomeState extends State<CreateOrJoinHome> {

  @override
  void initState() {
    super.initState();
  }

  final Owner user;

  CreateOrJoinHomeState(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Simpliflat Landlord Portal'),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext scaffoldC) {
        return getBody(scaffoldC);
      }),
    );
  }

  Widget getBody(BuildContext scaffoldC) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          getCreateOrJoinOptionsWidget(),
          getInfoWidget(),
          getIncomingRequestsWidget(scaffoldC),
        ],
      ),
    );
  }

  Widget getCreateOrJoinOptionsWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap: () {navigateToCreateProperty(false);},
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
            onTap: () {navigateToCreateProperty(true);},
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

  void navigateToCreateProperty(bool join) async {
    
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return FlatList(this.user, join);
      }),
    );
    
   

    // if(ifSuccess) {
    //   Utility.createErrorSnackBar(scaffoldC, error: 'Saved Successfully!');
    // }
  }

  Widget getInfoWidget() {
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

  Widget getIncomingRequestsWidget(BuildContext scaffoldC) {
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
          //getIncomingRequestsDataWidget(scaffoldC),
        ],
      ),
    );
  }

  Widget getIncomingRequestsDataWidget(BuildContext scaffoldC) {
    return StreamBuilder(
        stream: Firestore.instance.collection(globals.ownerOwnerJoin).where('toUserId', isEqualTo: this.user.getOwnerId()).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshots) {
          if(!snapshots.hasData) {
            return LoadingContainerVertical(2);
          }
          return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: snapshots.data.documents.length,
        itemBuilder: (BuildContext context, int position) {
          Map<String, dynamic> data = snapshots.data.documents[position].data;
          LandlordRequest req = LandlordRequest.fromJson(data, snapshots.data.documents[position].documentID);
          return Card(
            margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
            elevation: 5.0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(10.0),
                      child: IconButton(
                        icon: Icon(Icons.check, color: Colors.green,
                        size: 25.0,),
                        onPressed: () {},
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
                        style: TextStyle(color: Colors.grey, fontSize: 12.0),
                      )
                    ]),
                  ),
                  Container(
                      padding: EdgeInsets.all(10.0),
                      child: IconButton(icon:Icon(Icons.close, color: Colors.red, size: 25.0), onPressed: () {rejectRequest(req, scaffoldC);},)),
                ],
              ),
            ),
          );
        },
      );
        });
  }


  String getTitleText( request) {
    if(request.getFlatId() == null) {
      return 'Request for building ' + request.getBuildingName();
    }
    else {
      return 'Request for flat ' + request.getFlatNumber();
    }
  }


  Future<bool> rejectRequest(LandlordRequest request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Rejecting request');
    Map updateData = {'status': globals.RequestStatus.Rejected.index};
    bool ret = await Firestore.instance.collection(globals.ownerOwnerJoin).document(request.getRequestId()).updateData(updateData).then((ret){
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request rejected successfully');
      return true;
    }).catchError((){
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while rejecting request');
      return false;
    });

    return ret;
    
  }

  /*void acceptRequest(LandlordRequest request, BuildContext scaffoldC) async {
    Utility.createErrorSnackBar(scaffoldC, error: 'Accepting request');
    Map reqUpdateData = {'status': globals.RequestStatus.Accepted.index};

    WriteBatch batch = Firestore.instance.batch();

    DocumentReference reqDoc = Firestore.instance.collection(globals.ownerOwnerJoin).document(request.getRequestId());
    batch.updateData(reqDoc, reqUpdateData);

    DocumentReference propDoc = Firestore.instance.collection(globals.building).document(request.getBuildingId());
    if(request.getFlatId() != null) {
      propDoc = propDoc.collection(globals.block).document(request.getBlockId()).collection(globals.ownerFlat).document(request.getFlatId());
    }
    
    Map propUpdateData = {'ownerIdList': FieldValue.arrayUnion([request.getRequesterId()]), 'ownerRoleList': FieldValue.arrayUnion([request.getRequesterId() + ':' + globals.OwnerRoles.Manager.index.toString()])};
    batch.updateData(propDoc, propUpdateData);
    await batch.commit().then((ret){
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Request accepted successfully');

      Map<String, dynamic> data = {'buildingId': request.getBuildingId(), 'buildingName': request.getBuildingName(), 'blockId': request.getBlockId(), 'blockName': request.getBlockName(), 'flatId': request.getFlatId(), 'flatName': request.getFlatNumber()};
      OwnershipDetailsDBHelper.instance.insert(data);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Home(this.userId);
        }),
      );
    }).catchError((){
      Scaffold.of(scaffoldC).hideCurrentSnackBar();
      Utility.createErrorSnackBar(scaffoldC, error: 'Error while accepting request');
    });

    

    
  }*/
}
