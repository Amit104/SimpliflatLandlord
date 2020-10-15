import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      }, child: Scaffold(body: Builder(builder: (BuildContext contextScaffold) {
        return Stack(fit: StackFit.expand, children: <Widget>[
          new DecoratedBox(
            decoration: new BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                            backgroundColor: Colors.indigo[900],
                            radius: 50.0,
                            child: Icon(Icons.home,
                                color: Colors.white, size: 50.0)),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                        ),
                        Text(
                          "SIMPLIFLAT LANDLORD",
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 21.0,
                            fontFamily: 'Montserrat',
                          ),
                        )
                      ],
                    ),
                  )),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.indigo[900]),
                    ),
                  ],
                ),
              )
            ],
          )
        ]);
      }))),
    );
  }

  void moveToLastScreen() {
    debugPrint("EXIT");
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

}