import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simpliflat_landlord/screens/signup/create_or_join.dart';
import 'package:simpliflat_landlord/screens/signup/signupPhoneNumber.dart';
import 'package:simpliflat_landlord/screens/tenant_portal/tenant_portal.dart';
import 'package:simpliflat_landlord/screens/flatSetup/createOrJoinHome.dart';
import 'package:simpliflat_landlord/screens/home/Home.dart';


class StartNavigation extends StatelessWidget {
  final flag;
  final requestDenied;
  final List incomingRequests;
  final flatId;
  final Map<String, Map> flatIdentifierData;
  final String userId;

  StartNavigation(this.flag, this.requestDenied, this.incomingRequests,
      this.flatId, this.flatIdentifierData, this.userId);

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
          : (flag == 2
              ? Home(this.userId)
              : LandlordPortal(flatId)),
    );
  }

  void moveToLastScreen(BuildContext context) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
