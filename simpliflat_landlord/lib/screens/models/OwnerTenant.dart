import './BaseModel.dart';

class OwnerTenant extends BaseModel {
  String ownerFlatId;
  String tenantFlatId;

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



}