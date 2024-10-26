
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
    int? height;
    int? width;
    int? length;
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
    dynamic sendImages;
    dynamic receiveImages;
    dynamic sendSignature;
    dynamic receiveSignature;
    dynamic qrcode;
    dynamic signature;
    bool? paid;
    String? customerId;
    String? createdAt;
    String? updatedAt;
    List<Journies>? journies;
    List<Images>? images;
    List<dynamic>? signatures;

    Order({this.id, this.trackingNumber, this.agencyId, this.serviceType, this.nameSender, this.phoneNumberSender, this.nameReceiver, this.phoneNumberReceiver, this.mass, this.height, this.width, this.length, this.provinceSource, this.districtSource, this.wardSource, this.detailSource, this.longSource, this.latSource, this.provinceDest, this.districtDest, this.wardDest, this.detailDest, this.longDestination, this.latDestination, this.fee, this.parent, this.cod, this.shipper, this.statusCode, this.miss, this.sendImages, this.receiveImages, this.sendSignature, this.receiveSignature, this.qrcode, this.signature, this.paid, this.customerId, this.createdAt, this.updatedAt, this.journies, this.images, this.signatures});

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
        sendImages = json["sendImages"];
        receiveImages = json["receiveImages"];
        sendSignature = json["sendSignature"];
        receiveSignature = json["receiveSignature"];
        qrcode = json["qrcode"];
        signature = json["signature"];
        paid = json["paid"];
        customerId = json["customerId"];
        createdAt = json["createdAt"];
        updatedAt = json["updatedAt"];
        journies = json["journies"] == null ? null : (json["journies"] as List).map((e) => Journies.fromJson(e)).toList();
        images = json["images"] == null ? null : (json["images"] as List).map((e) => Images.fromJson(e)).toList();
        signatures = json["signatures"] ?? [];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["trackingNumber"] = trackingNumber;
        data["agencyId"] = agencyId;
        data["serviceType"] = serviceType;
        data["nameSender"] = nameSender;
        data["phoneNumberSender"] = phoneNumberSender;
        data["nameReceiver"] = nameReceiver;
        data["phoneNumberReceiver"] = phoneNumberReceiver;
        data["mass"] = mass;
        data["height"] = height;
        data["width"] = width;
        data["length"] = length;
        data["provinceSource"] = provinceSource;
        data["districtSource"] = districtSource;
        data["wardSource"] = wardSource;
        data["detailSource"] = detailSource;
        data["longSource"] = longSource;
        data["latSource"] = latSource;
        data["provinceDest"] = provinceDest;
        data["districtDest"] = districtDest;
        data["wardDest"] = wardDest;
        data["detailDest"] = detailDest;
        data["longDestination"] = longDestination;
        data["latDestination"] = latDestination;
        data["fee"] = fee;
        data["parent"] = parent;
        data["cod"] = cod;
        data["shipper"] = shipper;
        data["statusCode"] = statusCode;
        data["miss"] = miss;
        data["sendImages"] = sendImages;
        data["receiveImages"] = receiveImages;
        data["sendSignature"] = sendSignature;
        data["receiveSignature"] = receiveSignature;
        data["qrcode"] = qrcode;
        data["signature"] = signature;
        data["paid"] = paid;
        data["customerId"] = customerId;
        data["createdAt"] = createdAt;
        data["updatedAt"] = updatedAt;
        if(journies != null) {
            data["journies"] = journies?.map((e) => e.toJson()).toList();
        }
        if(images != null) {
            data["images"] = images?.map((e) => e.toJson()).toList();
        }
        if(signatures != null) {
            data["signatures"] = signatures;
        }
        return data;
    }
}

class Images {
    String? id;
    String? name;
    String? type;
    String? createdAt;
    String? updatedAt;

    Images({this.id, this.name, this.type, this.createdAt, this.updatedAt});

    Images.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        name = json["name"];
        type = json["type"];
        createdAt = json["createdAt"];
        updatedAt = json["updatedAt"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["name"] = name;
        data["type"] = type;
        data["createdAt"] = createdAt;
        data["updatedAt"] = updatedAt;
        return data;
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
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["time"] = time;
        data["message"] = message;
        data["orderId"] = orderId;
        data["updatedAt"] = updatedAt;
        return data;
    }
}