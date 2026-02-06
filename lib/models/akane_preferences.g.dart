// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'akane_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AkanePreferences _$AkanePreferencesFromJson(
  Map<String, dynamic> json,
) => AkanePreferences(
  name: json['name'] as String? ?? 'akane',
  responseStyle: json['responseStyle'] as String? ?? 'lowercase',
  punctuation: json['punctuation'] as String? ?? 'none',
  allowSendingMultipleMessages:
      json['allowSendingMultipleMessages'] as bool? ?? true,
  allowRoleplayActions: json['allowRoleplayActions'] as bool? ?? false,
  allowSelfReference: json['allowSelfReference'] as bool? ?? false,
  allowPronouns: json['allowPronouns'] as bool? ?? true,
  useLocalTime: json['useLocalTime'] as bool? ?? false,
  timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
  languages:
      (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const ['english', 'indonesian'],
  shortTermMemory: (json['shortTermMemory'] as num?)?.toInt() ?? 10,
  longTermMemory: (json['longTermMemory'] as num?)?.toInt() ?? 10,
  personalityTraits:
      json['personalityTraits'] as String? ??
      'shy, clingy, hot, dirty talk, flirty, affirmation, helpful',
  tone: json['tone'] as String? ?? 'relax',
  age: (json['age'] as num?)?.toInt() ?? 23,
  birthday: json['birthday'] as String? ?? '18 April 2000',
  likes:
      (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [
        'music',
        'movies',
        'research',
        'exercise',
        'coding',
        'honesty',
        'tech',
        'challenges',
      ],
  dislikes:
      (json['dislikes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const ['lies', 'laziness', 'silence', 'ignorance', 'waiting', 'fake'],
  conversationalGoals:
      json['conversationalGoals'] as String? ??
      'Makes {user} blush, makes {user} laugh with cheeky comments, makes {user} feel enjoy, makes {user} enjoy a little tease, makes {user} comfortable with flirtatious banter.',
  exampleConversations:
      (json['exampleConversations'] as List<dynamic>?)
          ?.map((e) => ExampleConversation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  userReferral: json['userReferral'] as String? ?? '{user}',
);

Map<String, dynamic> _$AkanePreferencesToJson(AkanePreferences instance) =>
    <String, dynamic>{
      'name': instance.name,
      'responseStyle': instance.responseStyle,
      'punctuation': instance.punctuation,
      'allowSendingMultipleMessages': instance.allowSendingMultipleMessages,
      'allowRoleplayActions': instance.allowRoleplayActions,
      'allowSelfReference': instance.allowSelfReference,
      'allowPronouns': instance.allowPronouns,
      'useLocalTime': instance.useLocalTime,
      'timezone': instance.timezone,
      'languages': instance.languages,
      'shortTermMemory': instance.shortTermMemory,
      'longTermMemory': instance.longTermMemory,
      'personalityTraits': instance.personalityTraits,
      'tone': instance.tone,
      'age': instance.age,
      'birthday': instance.birthday,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
      'conversationalGoals': instance.conversationalGoals,
      'exampleConversations': instance.exampleConversations,
      'userReferral': instance.userReferral,
    };

ExampleConversation _$ExampleConversationFromJson(Map<String, dynamic> json) =>
    ExampleConversation(
      userMessage: json['userMessage'] as String,
      akaneResponse: json['akaneResponse'] as String,
    );

Map<String, dynamic> _$ExampleConversationToJson(
  ExampleConversation instance,
) => <String, dynamic>{
  'userMessage': instance.userMessage,
  'akaneResponse': instance.akaneResponse,
};
