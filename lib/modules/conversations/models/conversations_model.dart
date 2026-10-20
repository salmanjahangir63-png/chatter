class ConversationModel {
  final String id;
  final String type;
  final ChatParticipant sender;
  final ChatParticipant receiver;
  final List<dynamic> members;
  final String content;
  final List<dynamic> readBy;
  final DateTime timestamp;
  final String timeAgo;
  final Map<String,dynamic> unreadCounts;

  ConversationModel({
    required this.id,
    required this.type,
    required this.sender,
    required this.receiver,
    required this.members,
    required this.content,
    required this.readBy,
    required this.timestamp,
    required this.timeAgo,
    required this.unreadCounts,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json["_id"],
        type: json["type"],
        sender: ChatParticipant.fromJson(json["sender"]),
        receiver: ChatParticipant.fromJson(json["receiver"]),
        members: List<dynamic>.from(json["members"].map((x) => x)),
        content: json["content"],
        readBy: List<dynamic>.from(json["readBy"].map((x) => x)),
        timestamp: DateTime.parse(json["timestamp"]),
        timeAgo: json["timeAgo"] ?? 'Just now',
        unreadCounts: json['unreadCounts'],
      );
}

class ChatParticipant {
  final String id;
  final String name;

  ChatParticipant({required this.id, required this.name});

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      ChatParticipant(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}
