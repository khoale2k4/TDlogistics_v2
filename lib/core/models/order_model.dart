
import 'dart:convert';

class Order {
    String? id;
    String? trackingNumber;
    String? agencyId;
    String? serviceType;
    String? nameSender;
    String? phoneNumberSender;
    String? nameReceiver;
    String? phoneNumberReceiver;
    int? mass;
    dynamic height;
    dynamic width;
    dynamic length;
    String? provinceSource;
    String? districtSource;
    String? wardSource;
    String? detailSource;
    double? longSource;
    double? latSource;
    String? provinceDest;
    String? districtDest;
    String? wardDest;
    String? detailDest;
    double? longDestination;
    double? latDestination;
    dynamic fee;
    dynamic parent;
    int? cod;
    dynamic shipper;
    String? statusCode;
    int? miss;
    dynamic qrcode;
    dynamic signature;
    bool? paid;
    String? customerId;
    dynamic takingDescription;
    int? fromMass;
    int? toMass;
    String? goodType;
    bool? isBulkyGood;
    dynamic note;
    bool? receiverWillPay;
    bool? deliverDoorToDoor;
    String? createdAt;
    String? updatedAt;
    List<Journies>? journies;
    List<dynamic>? images;
    List<dynamic>? signatures;

    Order({this.id, this.trackingNumber, this.agencyId, this.serviceType, this.nameSender, this.phoneNumberSender, this.nameReceiver, this.phoneNumberReceiver, this.mass, this.height, this.width, this.length, this.provinceSource, this.districtSource, this.wardSource, this.detailSource, this.longSource, this.latSource, this.provinceDest, this.districtDest, this.wardDest, this.detailDest, this.longDestination, this.latDestination, this.fee, this.parent, this.cod, this.shipper, this.statusCode, this.miss, this.qrcode, this.signature, this.paid, this.customerId, this.takingDescription, this.fromMass, this.toMass, this.goodType, this.isBulkyGood, this.note, this.receiverWillPay, this.deliverDoorToDoor, this.createdAt, this.updatedAt, this.journies, this.images, this.signatures});

    Order.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        trackingNumber = json["trackingNumber"];
        agencyId = json["agencyId"];
        serviceType = json["serviceType"];
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
        longSource = json["longSource"];
        latSource = json["latSource"];
        provinceDest = json["provinceDest"];
        districtDest = json["districtDest"];
        wardDest = json["wardDest"];
        detailDest = json["detailDest"];
        longDestination = json["longDestination"];
        latDestination = json["latDestination"];
        fee = json["fee"];
        parent = json["parent"];
        cod = json["cod"];
        shipper = json["shipper"];
        statusCode = json["statusCode"];
        miss = json["miss"];
        qrcode = json["qrcode"];
        signature = json["signature"];
        paid = json["paid"];
        customerId = json["customerId"];
        takingDescription = json["takingDescription"];
        fromMass = json["fromMass"];
        toMass = json["toMass"];
        goodType = json["goodType"];
        isBulkyGood = json["isBulkyGood"];
        note = json["note"];
        receiverWillPay = json["receiverWillPay"];
        deliverDoorToDoor = json["deliverDoorToDoor"];
        createdAt = json["createdAt"];
        updatedAt = json["updatedAt"];
        journies = json["journies"] == null ? null : (json["journies"] as List).map((e) => Journies.fromJson(e)).toList();
        images = json["images"] ?? [];
        signatures = json["signatures"] ?? [];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        id = _data["id"];
        trackingNumber = _data["trackingNumber"];
        agencyId = _data["agencyId"];
        serviceType = _data["serviceType"];
        nameSender = _data["nameSender"];
        phoneNumberSender = _data["phoneNumberSender"];
        nameReceiver = _data["nameReceiver"];
        phoneNumberReceiver = _data["phoneNumberReceiver"];
        mass = _data["mass"];
        height = _data["height"];
        width = _data["width"];
        length = _data["length"];
        provinceSource = _data["provinceSource"];
        districtSource = _data["districtSource"];
        wardSource = _data["wardSource"];
        detailSource = _data["detailSource"];
        longSource = _data["longSource"];
        latSource = _data["latSource"];
        provinceDest = _data["provinceDest"];
        districtDest = _data["districtDest"];
        wardDest = _data["wardDest"];
        detailDest = _data["detailDest"];
        longDestination = _data["longDestination"];
        latDestination = _data["latDestination"];
        fee = _data["fee"];
        parent = _data["parent"];
        cod = _data["cod"];
        shipper = _data["shipper"];
        statusCode = _data["statusCode"];
        miss = _data["miss"];
        qrcode = _data["qrcode"];
        signature = _data["signature"];
        paid = _data["paid"];
        customerId = _data["customerId"];
        takingDescription = _data["takingDescription"];
        fromMass = _data["fromMass"];
        toMass = _data["toMass"];
        goodType = _data["goodType"];
        isBulkyGood = _data["isBulkyGood"];
        note = _data["note"];
        receiverWillPay = _data["receiverWillPay"];
        deliverDoorToDoor = _data["deliverDoorToDoor"];
        createdAt = _data["createdAt"];
        updatedAt = _data["updatedAt"];
        journies = _data["journies"] == null ? null : (_data["journies"] as List).map((e) => Journies.fromJson(e)).toList();
        images = _data["images"] ?? [];
        signatures = _data["signatures"] ?? [];
        return _data;
    }
}

class Journies {
    int? id;
    String? time;
    String? message;
    String? orderId;
    String? updatedAt;

    Journies({this.id, this.time, this.message, this.orderId, this.updatedAt});

    Journies.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        time = json["time"];
        message = json["message"];
        orderId = json["orderId"];
        updatedAt = json["updatedAt"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        id = _data["id"];
        time = _data["time"];
        message = _data["message"];
        orderId = _data["orderId"];
        updatedAt = _data["updatedAt"];
        return _data;
    }
}