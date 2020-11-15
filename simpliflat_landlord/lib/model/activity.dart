import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';

class Activity extends BaseModel {
  String senderName;
  String title;
  String message;
  String activityId;
  String buildingName;
  String ownerFlatName;
  String ownerFlatId;
  String tenantFlatId;
  String ownerTenantFlatId;
  String documentId;
  int timestamp;

	String getActivityId() {
		return this.activityId;
	}

	void setActivityId(String activityId) {
		this.activityId = activityId;
	}

	String getBuildingName() {
		return this.buildingName;
	}

	void setBuildingName(String buildingName) {
		this.buildingName = buildingName;
	}

	String getOwnerFlatName() {
		return this.ownerFlatName;
	}

	void setOwnerFlatName(String ownerFlatName) {
		this.ownerFlatName = ownerFlatName;
	}

	String getOwnerFlatId() {
		return this.ownerFlatId;
	}

	void setOwnerFlatId(String ownerFlatId) {
		this.ownerFlatId = ownerFlatId;
	}

	String getTenantFlatId() {
		return this.tenantFlatId;
	}

	void setTenantFlatId(String tenantFlatId) {
		this.tenantFlatId = tenantFlatId;
	}

	String getOwnerTenantFlatId() {
		return this.ownerTenantFlatId;
	}

	void setOwnerTenantFlatId(String ownerTenantFlatId) {
		this.ownerTenantFlatId = ownerTenantFlatId;
	}

	String getDocumentId() {
		return this.documentId;
	}

	void setDocumentId(String documentId) {
		this.documentId = documentId;
	}

	int getTimestamp() {
		return this.timestamp;
	}

	void setTimestamp(int timestamp) {
		this.timestamp = timestamp;
	}


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

  Map<String, dynamic> toJson() {
    return {
      'activityId' : this.activityId,
            'senderName': this.senderName,
            'title': this.title,
            'message': this.message,
            'buildingName': this.buildingName,
            'ownerFlatName': this.ownerFlatName,
            'ownerFlatId': this.ownerFlatId,
            'tenantFlatId': this.tenantFlatId,
            'ownerTenantFlatId': this.ownerTenantFlatId,
            'timestamp': this.timestamp,
            'documentId': this.documentId,
    };
  }

  static Activity fromJson(Map<String, dynamic> data, String documentId) {
    Activity activity = new Activity();
    activity.setMessage(data['message']);
    activity.setTitle(data['title']);
    activity.setSenderName(data['sendername']);
    activity.setCreatedAt(Timestamp.fromDate(new DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int)));
    activity.setActivityId(documentId);
    activity.setTimestamp(data['timestamp']);
    return activity;
  } 
}