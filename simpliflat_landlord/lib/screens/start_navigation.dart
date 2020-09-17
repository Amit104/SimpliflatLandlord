import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simpliflat_landlord/screens/createOrJoin/createOrJoinHome.dart';
import 'package:simpliflat_landlord/screens/signup/signupPhoneNumber.dart';
import 'package:simpliflat_landlord/screens/home/Home.dart';
import 'package:simpliflat_landlord/screens/models/Owner.dart';

class StartNavigation extends StatelessWidget {
  final flag;
  final requestDenied;
  final List incomingRequests;
  final flatId;
  final Map<String, Map> flatIdentifierData;
  final Owner user;

  StartNavigation(this.flag, this.requestDenied, this.incomingRequests,
      this.flatId, this.flatIdentifierData, this.user);

  @override
  Widget build(BuildContext context) {
    debugPrint("Flag in navigation screen is " + flag.toString());
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen(context);
        return null;
      },
      child: flag == 1
          ? SignUpPhone()
          : flag == 2? Home(this.user) : CreateOrJoinHome(this.user)
    );
  }

  void moveToLastScreen(BuildContext context) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
