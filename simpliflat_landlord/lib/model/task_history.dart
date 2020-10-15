import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';

class TaskHistory extends BaseModel {
  String completedByUserId;
  String  completedByUserName;

  TaskHistory(this.completedByUserId, this.completedByUserName);

	String getCompletedByUserId() {
		return this.completedByUserId;
	}

	void setCompletedByUserId(String completedByUserId) {
		this.completedByUserId = completedByUserId;
	}

	getCompletedByUserName() {
		return this.completedByUserName;
	}

	void setCompletedByUserName( completedByUserName) {
		this.completedByUserName = completedByUserName;
	}

  Map<String, dynamic> toJson() {
    return {
      'completed_by': this.completedByUserId,
      'user_name': this.completedByUserName,
      'created_at': Timestamp.now()
    };
  }

}