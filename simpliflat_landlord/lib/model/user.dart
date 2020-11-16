
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';

class User extends BaseModel {
  String role;
  String name;
  String phone;
  String userId;
  String notificationToken;
  bool propertyRegistered;

	String getRole() {
		return this.role;
	}

	void setRole(String role) {
		this.role = role;
	}

	String getName() {
		return this.name;
	}

	void setName(String name) {
		this.name = name;
	}

	String getPhone() {
		return this.phone;
	}

	void setPhone(String phone) {
		this.phone = phone;
	}

  String getUserId() {
    return this.userId;
  }

  void setUserId(String userId) {
    this.userId = userId;
  }

  String getNotificationToken() {
    return this.notificationToken;
  }

  void setNotificationToken(String notificationToken) {
    this.notificationToken = notificationToken;
  }

  bool getPropertyRegistered() {
    return this.propertyRegistered;
  }

  void setPropertyRegistered(bool propertyRegistered) {
    this.propertyRegistered = propertyRegistered;
  }

  static User fromJson(Map<String, dynamic> data, String documentId) {
    User user = new User();
    user.setName(data['name']);
    user.setPhone(data['phone']);
    user.setUserId(documentId);
    user.setNotificationToken(data['notificationToken']);
    user.setCreatedAt(data['createdAt']);
    user.setUpdatedAt(data['updatedAt']);

    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'phone': this.phone,
      'notificationToken': this.notificationToken,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now()
    };
  }
}