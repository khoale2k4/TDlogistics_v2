
class CreateOrderObject {
    String? nameSender;
    String? phoneNumberSender;
    String? nameReceiver;
    String? phoneNumberReceiver;
    int? fromMass;
    int? toMass;
    int? mass;
    String? provinceSource;
    String? districtSource;
    String? wardSource;
    String? detailSource;
    String? provinceDest;
    String? districtDest;
    String? wardDest;
    String? detailDest;
    double? longSource;
    double? latSource;
    double? longDestination;
    double? latDestination;
    int? cod;
    String? serviceType;
    String? goodType;
    bool? receiverWillPay;
    bool? deliverDoorToDoor;
    GiftOrder? giftOrder;
    String? takingDescription;
    String? note;
    String? voucherId;

    CreateOrderObject({this.nameSender, this.phoneNumberSender, this.nameReceiver, this.phoneNumberReceiver, this.fromMass, this.toMass, this.mass, this.provinceSource, this.districtSource, this.wardSource, this.detailSource, this.provinceDest, this.districtDest, this.wardDest, this.detailDest, this.longSource, this.latSource, this.longDestination, this.latDestination, this.cod, this.serviceType, this.goodType, this.receiverWillPay, this.deliverDoorToDoor, this.giftOrder, this.takingDescription, this.note, this.voucherId});

    CreateOrderObject.fromJson(Map<String, dynamic> json) {
        nameSender = json["nameSender"];
        phoneNumberSender = json["phoneNumberSender"];
        nameReceiver = json["nameReceiver"];
        phoneNumberReceiver = json["phoneNumberReceiver"];
        fromMass = json["fromMass"];
        toMass = json["toMass"];
        mass = json["mass"];
        provinceSource = json["provinceSource"];
        districtSource = json["districtSource"];
        wardSource = json["wardSource"];
        detailSource = json["detailSource"];
        provinceDest = json["provinceDest"];
        districtDest = json["districtDest"];
        wardDest = json["wardDest"];
        detailDest = json["detailDest"];
        longSource = json["longSource"];
        latSource = json["latSource"];
        longDestination = json["longDestination"];
        latDestination = json["latDestination"];
        cod = json["cod"];
        serviceType = json["serviceType"];
        goodType = json["goodType"];
        receiverWillPay = json["receiverWillPay"];
        deliverDoorToDoor = json["deliverDoorToDoor"];
        giftOrder = json["giftOrder"] == null ? null : GiftOrder.fromJson(json["giftOrder"]);
        takingDescription = json["takingDescription"];
        note = json["note"];
        voucherId = json["voucherId"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["nameSender"] = nameSender;
        _data["phoneNumberSender"] = phoneNumberSender;
        _data["nameReceiver"] = nameReceiver;
        _data["phoneNumberReceiver"] = phoneNumberReceiver;
        _data["fromMass"] = fromMass;
        _data["toMass"] = toMass;
        _data["mass"] = mass;
        _data["provinceSource"] = provinceSource;
        _data["districtSource"] = districtSource;
        _data["wardSource"] = wardSource;
        _data["detailSource"] = detailSource;
        _data["provinceDest"] = provinceDest;
        _data["districtDest"] = districtDest;
        _data["wardDest"] = wardDest;
        _data["detailDest"] = detailDest;
        _data["longSource"] = longSource;
        _data["latSource"] = latSource;
        _data["longDestination"] = longDestination;
        _data["latDestination"] = latDestination;
        _data["cod"] = cod;
        _data["serviceType"] = serviceType;
        _data["goodType"] = goodType;
        _data["receiverWillPay"] = receiverWillPay;
        _data["deliverDoorToDoor"] = deliverDoorToDoor;
        _data["takingDescription"] = takingDescription;
        _data["note"] = note;
        _data["voucherId"] = voucherId;
        if(giftOrder != null) {
            _data["giftOrder"] = giftOrder?.toJson();
        }
        return _data;
    }
}

class GiftOrder {
    String? message;
    String? topicId;

    GiftOrder({this.message, this.topicId});

    GiftOrder.fromJson(Map<String, dynamic> json) {
        message = json["message"];
        topicId = json["topicId"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["message"] = message;
        _data["topicId"] = topicId;
        return _data;
    }
}