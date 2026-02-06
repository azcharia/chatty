import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String name;
  final String? nickname;
  final List<String> interests;
  final List<String> dailyRoutine;
  final Map<String, String> personalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.name,
    this.nickname,
    this.interests = const [],
    this.dailyRoutine = const [],
    this.personalInfo = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? name,
    String? nickname,
    List<String>? interests,
    List<String>? dailyRoutine,
    Map<String, String>? personalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      interests: interests ?? this.interests,
      dailyRoutine: dailyRoutine ?? this.dailyRoutine,
      personalInfo: personalInfo ?? this.personalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
