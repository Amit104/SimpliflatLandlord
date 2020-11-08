import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';

class Activity extends BaseModel {
  String senderName;
  String title;
  String message;

	String getSenderName() {
		return this.senderName;
	}

	void setSenderName(String senderName) {
		this.senderName = senderName;
	}

	String getTitle() {
		return this.title;
	}

	void setTitle(String title) {
		this.title = title;
	}

  String getMessage() {
    return this.message;
  }

  void setMessage(String message) {
    this.message = message;
  }

  static Activity fromJson(Map<String, dynamic> data, String documentId) {
    Activity activity = new Activity();
    activity.setMessage(data['message']);
    activity.setTitle(data['title']);
    activity.setSenderName(data['sendername']);
    activity.setCreatedAt(Timestamp.fromDate(new DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int)));
    return activity;
  } 
}