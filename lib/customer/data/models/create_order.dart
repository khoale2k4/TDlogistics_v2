
class CreateOrderObject {
    String? nameSender;
    String? phoneNumberSender;
    String? nameReceiver;
    String? phoneNumberReceiver;
    int? mass;
    int? height;
    int? width;
    int? length;
    String? provinceSource;
    String? districtSource;
    String? wardSource;
    String? detailSource;
    String? provinceDest;
    String? districtDest;
    String? wardDest;
    String? detailDest;
    int? cod;
    String? serviceType;

    CreateOrderObject({this.nameSender, this.phoneNumberSender, this.nameReceiver, this.phoneNumberReceiver, this.mass, this.height, this.width, this.length, this.provinceSource, this.districtSource, this.wardSource, this.detailSource, this.provinceDest, this.districtDest, this.wardDest, this.detailDest, this.cod, this.serviceType});

    CreateOrderObject.fromJson(Map<String, dynamic> json) {
        nameSender = json["nameSender"];
        phoneNumberSender = json["phoneNumberSender"];
        nameReceiver = json["nameReceiver"];
        phoneNumberReceiver = json["phoneNumberReceiver"];
        mass = json["mass"];
        height = json["height"];
        width = json["width"];
        length = json["length"];
        provinceSource = json["provinceSource"];
        districtSource = json["districtSource"];
        wardSource = json["wardSource"];
        detailSource = json["detailSource"];
        provinceDest = json["provinceDest"];
        districtDest = json["districtDest"];
        wardDest = json["wardDest"];
        detailDest = json["detailDest"];
        cod = json["cod"];
        serviceType = json["serviceType"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["nameSender"] = nameSender;
        _data["phoneNumberSender"] = phoneNumberSender;
        _data["nameReceiver"] = nameReceiver;
        _data["phoneNumberReceiver"] = phoneNumberReceiver;
        _data["mass"] = mass;
        _data["height"] = height;
        _data["width"] = width;
        _data["length"] = length;
        _data["provinceSource"] = provinceSource;
        _data["districtSource"] = districtSource;
        _data["wardSource"] = wardSource;
        _data["detailSource"] = detailSource;
        _data["provinceDest"] = provinceDest;
        _data["districtDest"] = districtDest;
        _data["wardDest"] = wardDest;
        _data["detailDest"] = detailDest;
        _data["cod"] = cod;
        _data["serviceType"] = serviceType;
        return _data;
    }
}