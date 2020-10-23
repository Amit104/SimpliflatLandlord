import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';

class UploadDocument extends BaseModel {
  String fileName;
  int fileSize;
  String fileUrl;
  int createdByTenant;
  String createdByUserId;
  String createdByUserName;
  String documentId;

	String getFileName() {
		return this.fileName;
	}

	void setFileName(String fileName) {
		this.fileName = fileName;
	}

	int getFileSize() {
		return this.fileSize;
	}

	void setFileSize(int fileSize) {
		this.fileSize = fileSize;
	}

	String getFileUrl() {
		return this.fileUrl;
	}

	void setFileUrl(String fileUrl) {
		this.fileUrl = fileUrl;
	}

	int isCreatedByTenant() {
		return this.createdByTenant;
	}

	void setCreatedByTenant(int createdByTenant) {
		this.createdByTenant = createdByTenant;
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

  String getDocumentId() {
		return this.documentId;
	}

	void setDocumentId(String documentId) {
		this.documentId = documentId;
	}

  static UploadDocument fromJson(Map<String, dynamic> data, String documentId) {
    UploadDocument document = new UploadDocument();
    document.setCreatedByTenant(data['is_created_by_tenant']);
    document.setCreatedByUserId(data['user_id']);
    document.setCreatedByUserName(data['user_name']);
    document.setFileName(data['file_name']);
    document.setFileSize(data['file_size']);
    document.setFileUrl(data['file_url']);
    document.setCreatedAt(data['created_at']);
    document.setUpdatedAt(data['updated_at']);
    document.setDocumentId(documentId);

    return document;
  }

  Map<String, dynamic> toJson() {
    return {
      'is_created_by_tenant': this.createdByTenant,
      'user_id': this.createdByUserId,
      'user_name': this.createdByUserName,
      'file_name': this.fileName,
      'file_size': this.fileSize,
      'file_url': this.fileUrl,
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now()
    };
  }



}