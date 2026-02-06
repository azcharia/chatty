import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final int? id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? type; // 'chat', 'reminder', 'note', 'knowledge'

  Message({
    this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = 'chat',
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    int? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? type,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}
