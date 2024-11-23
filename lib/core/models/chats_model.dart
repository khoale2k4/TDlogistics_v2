class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final String type;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.type,
  });
}

class Conversation {
  final String id;
  final List<String> participantIds;
  final Message lastMessage;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.updatedAt,
  });
}