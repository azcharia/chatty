import 'package:json_annotation/json_annotation.dart';

part 'reminder.g.dart';

@JsonSerializable()
class Reminder {
  final int? id;
  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;
  final String category;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Reminder({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
    this.category = 'general',
    required this.createdAt,
    this.completedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
  Map<String, dynamic> toJson() => _$ReminderToJson(this);

  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
    String? category,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Helper methods
  bool get isPast => DateTime.now().isAfter(dateTime);
  bool get isToday =>
      DateTime.now().day == dateTime.day &&
      DateTime.now().month == dateTime.month &&
      DateTime.now().year == dateTime.year;
  bool get isTomorrow =>
      DateTime.now().add(const Duration(days: 1)).day == dateTime.day &&
      DateTime.now().add(const Duration(days: 1)).month == dateTime.month &&
      DateTime.now().add(const Duration(days: 1)).year == dateTime.year;

  String get timeUntil {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) return 'Sudah lewat';

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lagi';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lagi';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lagi';
    } else {
      return 'Sebentar lagi';
    }
  }

  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'work':
        return '💼';
      case 'personal':
        return '👤';
      case 'health':
        return '🏥';
      case 'shopping':
        return '🛒';
      case 'call':
        return '📞';
      case 'meeting':
        return '🤝';
      case 'birthday':
        return '🎂';
      case 'anniversary':
        return '💕';
      default:
        return '📝';
    }
  }
}
