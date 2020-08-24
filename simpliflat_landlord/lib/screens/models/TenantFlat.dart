class TenantFlat {
  String buildingAddress;
  String buildingName;
  String zipcode;
  String flatName;
  String flatDisplayId;

	String getBuildingAddress() {
		return this.buildingAddress;
	}

	void setBuildingAddress(String buildingAddress) {
		this.buildingAddress = buildingAddress;
	}

	String getBuildingName() {
		return this.buildingName;
	}

	void setBuildingName(String buildingName) {
		this.buildingName = buildingName;
	}

	String getZipcode() {
		return this.zipcode;
	}

	void setZipcode(String zipcode) {
		this.zipcode = zipcode;
	}

	String getFlatName() {
		return this.flatName;
	}

	void setFlatName(String flatName) {
		this.flatName = flatName;
	}

	String getFlatDisplayId() {
		return this.flatDisplayId;
	}

	void setFlatDisplayId(String flatDisplayId) {
		this.flatDisplayId = flatDisplayId;
	}

  static TenantFlat fromJson(Map<String, dynamic> data, String documentId) {
    TenantFlat flat = new TenantFlat();
    flat.setFlatDisplayId(data['display_id']);
    flat.setFlatName(data['name']);

    return flat;
  }


}