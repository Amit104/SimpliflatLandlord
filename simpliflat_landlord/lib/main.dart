import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/ui/create_or_join/create_or_join_home.dart';
import 'package:simpliflat_landlord/ui/home/home.dart';
import 'package:simpliflat_landlord/ui/signup/signup_phonenumber.dart';
import 'package:simpliflat_landlord/services/startup_service.dart';
import 'package:simpliflat_landlord/ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: StartupService.getUser(),
        builder: (BuildContext context, AsyncSnapshot<User> userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          User user = userSnapshot.data;

          return MultiProvider(
            providers: [
              Provider<User>.value(value: user),
            ],
            child: MaterialApp(
                title: 'SimpliFlat',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  brightness: Brightness.light,
                  primaryColor: Colors.white,
                  accentColor: Colors.indigo[900],
                  fontFamily: 'Montserrat',
                ),
                home: WillPopScope(onWillPop: () {
                  moveToLastScreen();
                  return null;
                }, child: Scaffold(
                    body: Builder(builder: (BuildContext contextScaffold) {
                  return user == null
                      ? SignUpPhone()
                      : user.getPropertyRegistered() == true ? Home() : CreateOrJoinHome();
                })))),
          );
        });
  }

  void moveToLastScreen() {
    debugPrint("EXIT");
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
