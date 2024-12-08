
class Voucher {
    String? id;
    int? discount;
    String? expiration;

    Voucher({this.id, this.discount, this.expiration});

    Voucher.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        discount = json["discount"];
        expiration = json["expiration"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["id"] = id;
        _data["discount"] = discount;
        _data["expiration"] = expiration;
        return _data;
    }
}