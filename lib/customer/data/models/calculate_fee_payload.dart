
class CalculateFeePayLoad {
    String? serviceType;
    int? cod;
    double? latSource;
    double? longSource;
    double? latDestination;
    double? longDestination;
    String? voucherId;

    CalculateFeePayLoad({this.serviceType, this.cod, this.latSource, this.longSource, this.latDestination, this.longDestination, this.voucherId});

    CalculateFeePayLoad.fromJson(Map<String, dynamic> json) {
        serviceType = json["serviceType"];
        cod = json["cod"];
        latSource = json["latSource"];
        longSource = json["longSource"];
        latDestination = json["latDestination"];
        longDestination = json["longDestination"];
        voucherId = json["voucherId"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["serviceType"] = serviceType;
        _data["cod"] = cod;
        _data["latSource"] = latSource;
        _data["longSource"] = longSource;
        _data["latDestination"] = latDestination;
        _data["longDestination"] = longDestination;
        _data["voucherId"] = voucherId;
        return _data;
    }
}