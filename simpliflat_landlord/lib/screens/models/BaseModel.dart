import 'package:cloud_firestore/cloud_firestore.dart';

class BaseModel {
  Timestamp createdAt;
  Timestamp updatedAt;

	Timestamp getCreatedAt() {
		return this.createdAt;
	}

	void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	Timestamp getUpdatedAt() {
		return this.updatedAt;
	}

	void setUpdatedAt(Timestamp updatedAt) {
		this.updatedAt = updatedAt;
	}



}