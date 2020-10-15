import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';

class Message extends BaseModel {
  bool createdByTenant;
  String message;
  String createdByUserId;
  String createdByUserName;
  String messageId;

	bool isCreatedByTenant() {
		return this.createdByTenant;
	}

	void setCreatedByTenant(bool createdByTenant) {
		this.createdByTenant = createdByTenant;
	}

	String getMessage() {
		return this.message;
	}

	void setMessage(String message) {
		this.message = message;
	}

	String getCreatedByUserId() {
		return this.createdByUserId;
	}

	void setCreatedByUserId(String createdByUserId) {
		this.createdByUserId = createdByUserId;
	}

	String getCreatedByUserName() {
		return this.createdByUserName;
	}

	void setCreatedByUserName(String createdByUserName) {
		this.createdByUserName = createdByUserName;
	}

  String getMessageId() {
    return this.messageId;
  }

  void setMessageId(String messageId) {
    this.messageId = messageId;
  }

  static Message fromJson(Map<String, dynamic> data, String documentId) {
    Message msgBoard = new Message();
    msgBoard.setCreatedByTenant(data['is_created_by_tenant']);
    msgBoard.setCreatedByUserId(data['user_id']);
    msgBoard.setCreatedByUserName(data['user_name']);
    msgBoard.setMessage(data['message']);
    msgBoard.setCreatedAt(data['created_at']);
    msgBoard.setUpdatedAt(data['updated_at']);
    msgBoard.setMessageId(documentId);

    return msgBoard;
  }

  Map<String, dynamic> toJson() {
    return {
      'is_created_by_tenant': this.createdByTenant,
      'message': this.message,
      'user_id': this.createdByUserId,
      'user_name': this.createdByUserName,
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now()
    };
  }



}