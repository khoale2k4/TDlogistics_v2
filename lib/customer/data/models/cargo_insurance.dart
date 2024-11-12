
class CargoInsurance {
    String? note;
    bool? hasDeliveryCare;
    String? shippingBillId;

    CargoInsurance({this.note, this.hasDeliveryCare, this.shippingBillId});

    CargoInsurance.fromJson(Map<String, dynamic> json) {
        note = json["note"];
        hasDeliveryCare = json["hasDeliveryCare"];
        shippingBillId = json["shippingBillId"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["note"] = note;
        _data["hasDeliveryCare"] = hasDeliveryCare;
        _data["shippingBillId"] = shippingBillId;
        return _data;
    }
}