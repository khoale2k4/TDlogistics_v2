class Message {
    int? id;
    String? senderId;
    String? receiverId;
    String? content;
    String? createdAt;
    String? updatedAt;

    Message({this.id, this.senderId, this.receiverId, this.content, this.createdAt, this.updatedAt});

    Message.fromJson(Map<String, dynamic> json) {
        id = json["id"];
        senderId = json["senderId"];
        receiverId = json["receiverId"];
        content = json["content"];
        createdAt = json["createdAt"];
        updatedAt = json["updatedAt"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["id"] = id;
        _data["senderId"] = senderId;
        _data["receiverId"] = receiverId;
        _data["content"] = content;
        _data["createdAt"] = createdAt;
        _data["updatedAt"] = updatedAt;
        return _data;
    }
}

class Chat {
    String? otherUserId;
    String? fullname;
    String? lastMessageTime;
    String? lastMessage;
    
    Chat({this.otherUserId, this.fullname, this.lastMessageTime, this.lastMessage});

    Chat.fromJson(Map<String, dynamic> json) {
        otherUserId = json["id"];
        fullname = json["fullname"];
        lastMessageTime = json["lastMessageTime"];
        lastMessage = json["lastMessage"];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> _data = <String, dynamic>{};
        _data["id"] = otherUserId;
        _data["fullname"] = fullname;
        _data["lastMessageTime"] = lastMessageTime;
        _data["lastMessage"] = lastMessage;
        return _data;
    }
}