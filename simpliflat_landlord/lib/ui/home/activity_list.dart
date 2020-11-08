import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simpliflat_landlord/common_widgets/loading_container.dart';
import 'package:simpliflat_landlord/model/activity.dart';

class ActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getActivities(),
      builder: (BuildContext context, AsyncSnapshot<List<Activity>> data) {
        if(!data.hasData) {
          return LoadingContainerVertical(3);
        }
        return ListView.separated(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          separatorBuilder: (BuildContext context, int pos) {
            return Divider(height: 1.0,);
          },
          itemCount: data.data.length,
          itemBuilder: (BuildContext context, int pos) {
            return _buildactivityItem(data.data[pos]);
          },
        );
      },
    );
  }

  Future<List<Activity>> _getActivities() async {
    //TODO: add owner id list in activity so that owner ld list condition can be added here
    DateTime now= new DateTime.now();
    Timestamp startDate = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    Timestamp endDate = Timestamp.fromDate(DateTime(now.year, now.month, now.day).add(new Duration(days: 1)));
    int start = startDate.millisecondsSinceEpoch;
    int end = endDate.millisecondsSinceEpoch;
    QuerySnapshot s = await Firestore.instance.collection('activity').where('timestamp', isGreaterThan: start).where('timestamp', isLessThan: end).getDocuments();
    List<Activity> activities = new List();
    if(s.documents != null) {
      activities = s.documents.map((DocumentSnapshot doc) => Activity.fromJson(doc.data, doc.documentID)).toList();
    }

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

    return Padding(
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
                      fontFamily: 'Montserrat',
                    )),
                padding: EdgeInsets.only(bottom: 5.0),
              ),
              Text(activityTitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                  )),
            ],
          ),
          subtitle: Padding(
            child: Text(datetimeString,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12.0,
                  fontFamily: 'Montserrat',
                  color: Colors.black45,
                )),
            padding: EdgeInsets.only(top: 6.0),
          ),
        ),
      ),
    );
  }


}