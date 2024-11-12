
class ShippingBill {
    String? companyName;
    String? companyAddress;
    String? taxCode;
    String? email;

    ShippingBill({this.companyName, this.companyAddress, this.taxCode, this.email});

    ShippingBill.fromJson(Map<String, dynamic> json) {
        companyName = json["companyName"];
        companyAddress = json["companyAddress"];
        taxCode = json["taxCode"];
        email = json["email"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["companyName"] = companyName;
        _data["companyAddress"] = companyAddress;
        _data["taxCode"] = taxCode;
        _data["email"] = email;
        return _data;
    }
}