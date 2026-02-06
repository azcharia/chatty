// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reminder _$ReminderFromJson(Map<String, dynamic> json) => Reminder(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  dateTime: DateTime.parse(json['dateTime'] as String),
  isCompleted: json['isCompleted'] as bool? ?? false,
  category: json['category'] as String? ?? 'general',
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt:
      json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$ReminderToJson(Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'dateTime': instance.dateTime.toIso8601String(),
  'isCompleted': instance.isCompleted,
  'category': instance.category,
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};
