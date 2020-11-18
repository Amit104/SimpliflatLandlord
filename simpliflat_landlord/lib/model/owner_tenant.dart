
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpliflat_landlord/model/base_model.dart';
import 'package:simpliflat_landlord/model/owner_flat.dart';
import 'package:simpliflat_landlord/model/tenant_flat.dart';

class OwnerTenant extends BaseModel {
  int status;
  OwnerFlat ownerFlat;
  TenantFlat tenantFlat;
  String ownerTenantId;
  Map<String, List<OwnerFlat>> ownedFlats;

	OwnerFlat getOwnerFlat() {
		return this.ownerFlat;
	}

	void setOwnerFlat(OwnerFlat ownerFlat) {
		this.ownerFlat = ownerFlat;
	}

	TenantFlat getTenantFlat() {
		return this.tenantFlat;
	}

	void setTenantFlat(TenantFlat tenantFlat) {
		this.tenantFlat = tenantFlat;
	}

  int getStatus() {
    return this.status;
  }

  void setStatus(int status) {
    this.status = status;
  }

  String getOwnerTenantId() {
    return this.ownerTenantId;
  }

  void setOwnerTenantId(String ownerTenantId) {
    this.ownerTenantId = ownerTenantId;
  }

  void setOwnedFlats(Map<String, List<OwnerFlat>> ownedFlats) {
    this.ownedFlats = ownedFlats;
  }

  Map<String, List<OwnerFlat>> getOwnedFlats() {
    return this.ownedFlats;
  }
  
  static OwnerTenant fromJson(Map<String, dynamic> data, String documentId) {
    OwnerTenant ot = new OwnerTenant();
    return ot;
  }

  Map<String, dynamic> toJson() {
    return {};
  }

  static Map<String, dynamic> toUpdateJson({status}) {
    Map<String, dynamic> updateJson = new Map();
    if(status != null) updateJson['status'] = status;
    updateJson['updatedAt'] = Timestamp.now();
    return updateJson;
  }

}