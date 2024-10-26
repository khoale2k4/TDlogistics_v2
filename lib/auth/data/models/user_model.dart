
class User {
    String? id;
    String? username;
    dynamic staffId;
    dynamic agencyId;
    dynamic firstName;
    dynamic lastName;
    String? fullname;
    String? phoneNumber;
    String? email;
    dynamic cccd;
    dynamic province;
    dynamic district;
    dynamic town;
    dynamic detailAddress;
    dynamic birthDate;
    dynamic bin;
    dynamic bank;
    dynamic deposit;
    dynamic salary;
    dynamic paidSalary;
    dynamic avatar;
    String? createdAt;
    String? updatedAt;
    List<Roles>? roles;

    User({this.id, this.username, this.staffId, this.agencyId, this.firstName, this.lastName, this.fullname, this.phoneNumber, this.email, this.cccd, this.province, this.district, this.town, this.detailAddress, this.birthDate, this.bin, this.bank, this.deposit, this.salary, this.paidSalary, this.avatar, this.createdAt, this.updatedAt, this.roles});

    User.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        username = json["username"];
        staffId = json["staffId"];
        agencyId = json["agencyId"];
        firstName = json["firstName"];
        lastName = json["lastName"];
        fullname = json["fullname"];
        phoneNumber = json["phoneNumber"];
        email = json["email"];
        cccd = json["cccd"];
        province = json["province"];
        district = json["district"];
        town = json["town"];
        detailAddress = json["detailAddress"];
        birthDate = json["birthDate"];
        bin = json["bin"];
        bank = json["bank"];
        deposit = json["deposit"];
        salary = json["salary"];
        paidSalary = json["paidSalary"];
        avatar = json["avatar"];
        createdAt = json["createdAt"];
        updatedAt = json["updatedAt"];
        roles = json["roles"] == null ? null : (json["roles"] as List).map((e) => Roles.fromJson(e)).toList();
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["username"] = username;
        data["staffId"] = staffId;
        data["agencyId"] = agencyId;
        data["firstName"] = firstName;
        data["lastName"] = lastName;
        data["fullname"] = fullname;
        data["phoneNumber"] = phoneNumber;
        data["email"] = email;
        data["cccd"] = cccd;
        data["province"] = province;
        data["district"] = district;
        data["town"] = town;
        data["detailAddress"] = detailAddress;
        data["birthDate"] = birthDate;
        data["bin"] = bin;
        data["bank"] = bank;
        data["deposit"] = deposit;
        data["salary"] = salary;
        data["paidSalary"] = paidSalary;
        data["avatar"] = avatar;
        data["createdAt"] = createdAt;
        data["updatedAt"] = updatedAt;
        if(roles != null) {
            data["roles"] = roles?.map((e) => e.toJson()).toList();
        }
        return data;
    }
}

class Roles {
    String? id;
    String? value;
    String? createdAt;
    String? updatedAt;

    Roles({this.id, this.value, this.createdAt, this.updatedAt});

    Roles.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        value = json["value"];
        createdAt = json["createdAt"];
        updatedAt = json["updatedAt"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["value"] = value;
        data["createdAt"] = createdAt;
        data["updatedAt"] = updatedAt;
        return data;
    }
}