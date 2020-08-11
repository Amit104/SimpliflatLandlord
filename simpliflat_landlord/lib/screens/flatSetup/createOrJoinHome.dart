import 'package:flutter/material.dart';

class CreateOrJoinHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new CreateOrJoinHomeState();
  }
}

class CreateOrJoinHomeState extends State<CreateOrJoinHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Simpliflat Landlord Portal'),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext scaffoldC) {
        return getBody();
      }),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          getCreateOrJoinOptionsWidget(),
          getInfoWidget(),
          getIncomingRequestsWidget(),
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
          Container(
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
          Container(
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

  Widget getIncomingRequestsWidget() {
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
          getIncomingRequestsDataWidget(),
        ],
      ),
    );
  }

  Widget getIncomingRequestsDataWidget() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: 5,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
          elevation: 5.0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 25.0,
                    )),
                Expanded(
                  child: Column(children: [
                    Text(
                      'Apartment MyHome has sent you a request.',
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
                    child: Icon(Icons.close, color: Colors.red, size: 25.0)),
              ],
            ),
          ),
        );
      },
    );
  }
}
