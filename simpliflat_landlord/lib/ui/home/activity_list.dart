import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/local_db/activity_db.dart';
import 'package:simpliflat_landlord/model/activity.dart';
import 'package:simpliflat_landlord/model/user.dart';
import 'package:simpliflat_landlord/utility/utility.dart';

class ActivityList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ActivityListState();
  }

}

class ActivityListState extends State<ActivityList> {

  DateFormat date = DateFormat("yyyy-MM-dd");

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            return 0;
          },
          child: FutureBuilder(
          future: _getActivities(user.getUserId()),
          builder: (BuildContext context, AsyncSnapshot<List<Activity>> data) {
      if(!data.hasData) {
        return LoadingContainerVertical(3);
      }

      return GroupedListView<dynamic, String>(
                      groupBy: (dynamic activity) => date
                          .format((activity as Activity).getCreatedAt()
                              .toDate()
                              .toLocal())
                          .toString(),
                      sort: false,
                      elements: data.data,
                      groupSeparatorBuilder: (String value) => Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: EdgeInsets.only(bottom: 20),
                        child: Center(
                          child: Container(
                            child: new Text(getDateValue(value),
                                style: new TextStyle(
                                    color: Colors.indigo[900],
                                    fontSize: 14.0,
                                    fontFamily: 'Robato')),
                            decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(6.0)),
                                color: Colors.indigo[100]),
                            padding:
                                new EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
                          ),
                        ),
                      ),
      
        itemBuilder: (BuildContext context, dynamic activity) {
          return _buildactivityItem(activity);
        },
      );
          },
        ),
    );
  }

  String getDateValue(value) {
    var numToMonth = {
      1: 'JANUARY',
      2: 'FEBRUARY',
      3: 'MARCH',
      4: 'APRIL',
      5: 'MAY',
      6: 'JUNE',
      7: 'JULY',
      8: 'AUGUST',
      9: 'SEPTEMBER',
      10: 'OCTOBER',
      11: 'NOVEMBER',
      12: 'DECEMBER'
    };
    DateTime separatorDate = DateTime.parse(value);
    DateTime currentDate =
        DateTime.parse(date.format(DateTime.now().toLocal()).toString());
    String yesterday = date.format(
        DateTime(currentDate.year, currentDate.month, currentDate.day - 1));
    if (value == date.format(DateTime.now().toLocal()).toString()) {
      return "TODAY";
    } else if (value == yesterday) {
      return "YESTERDAY";
    } else {
      return separatorDate.day.toString() +
          " " +
          numToMonth[separatorDate.month.toInt()] +
          " " +
          separatorDate.year.toString();
    }
  }

  Future<List<Activity>> _getActivities(String userId) async {
    List<Activity> activities = new List();
    List<Map<String, dynamic>> activitiesList = await ActivityDB.instance.queryAllRows();
    if(activitiesList != null && activitiesList.length > 0) {
      debugPrint(activitiesList.length.toString());
      activities = activitiesList.map((Map<String, dynamic> a) => Activity.fromJson(a, a['activityId'])).toList();
    }
    int lastseen = await Utility.getActivityLastSeen();
    Utility.addToSharedPref(activityLastSeen: Timestamp.now().millisecondsSinceEpoch);
    if(lastseen == null) {
      lastseen = Timestamp.now().millisecondsSinceEpoch;
    }
    debugPrint(lastseen.toString());
    QuerySnapshot s = await Firestore.instance.collection('activity').where('timestamp', isGreaterThan: lastseen).where('userList', arrayContains: userId).getDocuments();
    
    if(s.documents != null) {
      debugPrint(s.documents.length.toString());
      List<Activity> temp = s.documents.map((DocumentSnapshot doc) => Activity.fromJson(doc.data, doc.documentID)).toList();
      activities.addAll(temp);
      saveToLocalDB(temp);
    }



    activities.sort((Activity a, Activity b) {
      return b.getTimestamp().compareTo(a.getTimestamp());
    });

    return activities;
  }

  Widget _buildactivityItem(Activity activity) {
  DateTime datetime = activity.getCreatedAt().toDate();
    final f = new DateFormat.jm();
    String datetimeString = f.format(datetime);


    String activityTitle = activity.getMessage();
    if (activityTitle.length > 100) {
      activityTitle = activityTitle.substring(0, 100) + "...";
    }

    return Container(
          margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
          color: Colors.white70,
          child: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
        child: SizedBox(
          child: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  child: Text(activity.getTitle(),
                      style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600
                      )),
                  padding: EdgeInsets.only(bottom: 5.0),
                ),
                Text(activityTitle,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Roboto',
                      color: Colors.black,
                    )),
              ],
            ),
            subtitle: Padding(
              child: Text(datetimeString,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontFamily: 'Roboto',
                    color: Colors.black45,
                  )),
              padding: EdgeInsets.only(top: 6.0),
            ),
          ),
        ),
      ),
    );
  }

  void saveToLocalDB(List<Activity> activities) async {
    for(Activity activity in activities) {
      await ActivityDB.instance.insert(activity.toJson());
    } 
  }


}