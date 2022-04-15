class Parcel {
  int id = 0;
  int status = 0;
  String chargeCode = "";
  String dischargeCode = "";
  int boxId = 0;

  Parcel(this.id, this.status, this.chargeCode, this.dischargeCode, this.boxId);

  Parcel.fromJson(Map<String, dynamic> parcelMap) {
    this.id = parcelMap['id'];
    this.status = parcelMap['status'] ?? 0;
    this.chargeCode = parcelMap['chargeCode'] ?? '';
    this.dischargeCode = parcelMap['dischargeCode'] ?? '';
    this.boxId = parcelMap['boxId'] ?? 0;
  }
}
