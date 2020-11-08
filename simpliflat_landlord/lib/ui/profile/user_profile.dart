import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/common.dart';
import 'package:simpliflat_landlord/model/user.dart';

class UserProfile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
     appBar: AppBar(
          title: Text('Profile', style: CommonWidgets.getAppBarTitleStyle(),),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
      backgroundColor: Colors.white,
      body: Builder(builder: (BuildContext scaffoldC) {
        return getBody(scaffoldC);
      },

      ));
  }

  Widget getBody(BuildContext scaffoldC) {
    User user = Provider.of<User>(scaffoldC, listen: false);
    return ListView(
      children: [
        SizedBox(height:30),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
            children: [
            CircleAvatar(
            radius:50.0,
            backgroundImage: AssetImage('assets/images/avatar.png'),
            backgroundColor: Colors.transparent,
          ),
          Container(
            padding: EdgeInsets.only(left: 30),
            child: Text(user.getName(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 20.0),)),
          ]),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: ListTile(
            leading: Icon(Icons.phone),
            title: Text(user.getPhone(), style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 15.0, color: Colors.grey))
          ),
        )
      ],
    );
  }

}