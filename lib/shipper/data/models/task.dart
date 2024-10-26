
import 'package:tdlogistic_v2/core/models/order_model.dart';

class Task {
    String? id;
    String? orderId;
    String? staffId;
    dynamic completedAt;
    bool? completed;
    String? createdAt;
    String? updatedAt;
    Order? order;
    Staff? staff;

    Task({this.id, this.orderId, this.staffId, this.completedAt, this.completed, this.createdAt, this.updatedAt, this.order, this.staff});

    Task.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        orderId = json["orderId"];
        staffId = json["staffId"];
        completedAt = json["completedAt"];
        completed = json["completed"];
        createdAt = json["createdAt"];
        updatedAt = json["updatedAt"];
        order = json["order"] == null ? null : Order.fromJson(json["order"]);
        staff = json["staff"] == null ? null : Staff.fromJson(json["staff"]);
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["orderId"] = orderId;
        data["staffId"] = staffId;
        data["completedAt"] = completedAt;
        data["completed"] = completed;
        data["createdAt"] = createdAt;
        data["updatedAt"] = updatedAt;
        if(order != null) {
            data["order"] = order?.toJson();
        }
        if(staff != null) {
            data["staff"] = staff?.toJson();
        }
        return data;
    }
}

class Staff {
    String? id;
    dynamic staffId;
    String? username;
    dynamic agencyId;
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

    Staff({this.id, this.staffId, this.username, this.agencyId, this.fullname, this.phoneNumber, this.email, this.cccd, this.province, this.district, this.town, this.detailAddress, this.birthDate, this.bin, this.bank, this.deposit, this.salary, this.paidSalary, this.avatar});

    Staff.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        staffId = json["staffId"];
        username = json["username"];
        agencyId = json["agencyId"];
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
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["staffId"] = staffId;
        data["username"] = username;
        data["agencyId"] = agencyId;
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
        return data;
    }
}

class Customer {
    String? id;
    String? phoneNumber;
    String? email;
    dynamic firstName;
    dynamic lastName;
    dynamic avatar;
    String? createdAt;
    String? updatedAt;

    Customer({this.id, this.phoneNumber, this.email, this.firstName, this.lastName, this.avatar, this.createdAt, this.updatedAt});

    Customer.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        phoneNumber = json["phoneNumber"];
        email = json["email"];
        firstName = json["firstName"];
        lastName = json["lastName"];
        avatar = json["avatar"];
        createdAt = json["createdAt"];
        updatedAt = json["updatedAt"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data["id"] = id;
        data["phoneNumber"] = phoneNumber;
        data["email"] = email;
        data["firstName"] = firstName;
        data["lastName"] = lastName;
        data["avatar"] = avatar;
        data["createdAt"] = createdAt;
        data["updatedAt"] = updatedAt;
        return data;
    }
}