
class Location {
    String? id;
    String? name;
    double? lat;
    double? lng;
    String? customerId;

    Location({this.id, this.name, this.lat, this.lng, this.customerId});

    Location.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        name = json["name"];
        lat = json["lat"];
        lng = json["lng"];
        customerId = json["customerId"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["id"] = id;
        _data["name"] = name;
        _data["lat"] = lat;
        _data["lng"] = lng;
        _data["customerId"] = customerId;
        return _data;
    }
}

class FavoriteLocation {
    String? id;
    String? description;
    String? name;
    String? phoneNumber;
    double? lat;
    double? lng;

    FavoriteLocation({this.id, this.description, this.name, this.phoneNumber, this.lat, this.lng});

    FavoriteLocation.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        description = json["description"];
        name = json["name"];
        phoneNumber = json["phoneNumber"];
        lat = json["lat"];
        lng = json["lng"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["id"] = id;
        _data["description"] = description;
        _data["name"] = name;
        _data["phoneNumber"] = phoneNumber;
        _data["lat"] = lat;
        _data["lng"] = lng;
        return _data;
    }
}