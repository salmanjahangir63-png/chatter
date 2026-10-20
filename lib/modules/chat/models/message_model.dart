class MessageModel {
  final String sender;
  final String receiver;
  final String content;
  final String id;
  final DateTime timestamp;

  MessageModel({
    required this.sender,
    required this.receiver,
    required this.content,
    required this.id,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    sender: json["sender"],
    receiver: json["receiver"],
    content: json["content"],
    id: json["_id"],
    timestamp: DateTime.parse(json["timestamp"]),
  );

  Map<String, dynamic> toJson() => {
    "sender": sender,
    "receiver": receiver,
    "content": content,
    "_id": id,
    "timestamp": timestamp.toIso8601String(),
  };
}
