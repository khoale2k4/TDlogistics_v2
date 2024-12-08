import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/models/chats_model.dart';

class ChatRepository {
  final String baseUrl = baseUrll;

  Future<Map<String, dynamic>> getMessages(
      String token, String id, int page, int size) async {
    try {
      final url = Uri.parse('$baseUrl/chat/message/get');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(
          {"receiverId": id, "page": page, "size": size},
        ),
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        List<Message> msgs = [];
        for (final msg in responseData["data"]) {
          msgs.add(Message.fromJson(msg));
        }
        msgs = msgs.reversed.toList();

        return {
          "success": true,
          "message": responseData["message"],
          "data": msgs,
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"],
          "data": responseData["data"],
        };
      }
    } catch (error) {
      return {'success': false, 'message': error.toString()};
    }
  }

  Future<Map<String, dynamic>> getReceivers(
      String token, int page, int size) async {
    try {
      final url = Uri.parse('$baseUrl/chat/conversation/get?page=$page&size=$size');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        List<Chat> chats = [];
        for (final chat in responseData["data"]) {
          Chat newChat = Chat.fromJson(chat);
          final lm = (await getMessages(token, newChat.otherUserId!, 1, 1));

          if(lm["success"] && lm["data"].isNotEmpty) {
            print(lm["data"]);
            newChat.lastMessage = lm["data"][0].content;
            newChat.lastMessageTime = lm["data"][0].updatedAt;
          }
          chats.add(newChat);
        }
        chats = chats.reversed.toList();
        return {
          "success": true,
          "message": responseData["message"],
          "data": chats,
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"],
          "data": responseData["data"],
        };
      }
    } catch (error) {
      return {'success': false, 'message': error.toString()};
    }
  }

  Future<Map<String, dynamic>> deteleMessage(String token, String id) async {
    try {
      final url = Uri.parse('$baseUrl/chat/message/revode/$id');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      final response = await http.delete(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode <= 210) {
        return {
          "success": true,
          "message": responseData["message"],
          "data": "",
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"],
          "data": responseData["data"],
        };
      }
    } catch (error) {
      return {'success': false, 'message': error.toString()};
    }
  }
}
