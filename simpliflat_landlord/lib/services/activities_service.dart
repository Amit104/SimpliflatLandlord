import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/local_db/activity_db.dart';
import 'package:simpliflat_landlord/model/activity.dart';
import 'package:simpliflat_landlord/utility/utility.dart';

class ActivitiesService {
  static Future<List<Activity>> getActivities(
      String userId, Timestamp date) async {
    List<Activity> activities = new List();

    Utility.addToSharedPref(
        activityLastSeen: Timestamp.now().millisecondsSinceEpoch);

    QuerySnapshot s = await Firestore.instance
        .collection('activity')
        .where('timestamp', isGreaterThan: date)
        .where('userList.' + userId, isEqualTo: true)
        .getDocuments();

    if (s.documents != null) {
      print(s.documents.length.toString());
      List<Activity> temp = s.documents
          .map((DocumentSnapshot doc) =>
              Activity.fromJson(doc.data, doc.documentID))
          .toList();
      activities.addAll(temp);
      saveToLocalDB(temp);
    }

    activities.sort((Activity a, Activity b) {
      return b.getTimestamp().compareTo(a.getTimestamp());
    });

    return activities;
  }

  static void saveToLocalDB(List<Activity> activities) async {
    for (Activity activity in activities) {
      await ActivityDB.instance.insert(activity.toJson());
    }
  }

  static Future<Timestamp> getActivityLastSeen() async {
    int lastseen = await Utility.getActivityLastSeen();
    if (lastseen == null) return null;
    return Timestamp.fromMillisecondsSinceEpoch(lastseen);
  }

  static Future<List<Activity>> getFromLocalDB() async {
    List<Activity> activities = new List();
    List<Map<String, dynamic>> activitiesList =
        await ActivityDB.instance.queryAllRows();
    if (activitiesList != null && activitiesList.length > 0) {
      print(activitiesList.length.toString());
      activities = activitiesList
          .map(
              (Map<String, dynamic> a) => Activity.fromJson(a, a['activityId']))
          .toList();
    }

    return activities;
  }
}
