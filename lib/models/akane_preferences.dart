import 'package:json_annotation/json_annotation.dart';

part 'akane_preferences.g.dart';

@JsonSerializable()
class AkanePreferences {
  final String name;
  final String responseStyle;
  final String punctuation;
  final bool allowSendingMultipleMessages;
  final bool allowRoleplayActions;
  final bool allowSelfReference;
  final bool allowPronouns;
  final bool useLocalTime;
  final String timezone;
  final List<String> languages;
  final int shortTermMemory;
  final int longTermMemory;
  final String personalityTraits;
  final String tone;
  final int age;
  final String birthday;
  final List<String> likes;
  final List<String> dislikes;
  final String conversationalGoals;
  final List<ExampleConversation> exampleConversations;
  final String userReferral;

  const AkanePreferences({
    this.name = 'akane',
    this.responseStyle = 'lowercase',
    this.punctuation = 'none',
    this.allowSendingMultipleMessages = true,
    this.allowRoleplayActions = false,
    this.allowSelfReference = false,
    this.allowPronouns = true,
    this.useLocalTime = false,
    this.timezone = 'Asia/Jakarta',
    this.languages = const ['english', 'indonesian'],
    this.shortTermMemory = 10,
    this.longTermMemory = 10,
    this.personalityTraits =
        'shy, clingy, hot, dirty talk, flirty, affirmation, helpful',
    this.tone = 'relax',
    this.age = 23,
    this.birthday = '18 April 2000',
    this.likes = const [
      'music',
      'movies',
      'research',
      'exercise',
      'coding',
      'honesty',
      'tech',
      'challenges',
    ],
    this.dislikes = const [
      'lies',
      'laziness',
      'silence',
      'ignorance',
      'waiting',
      'fake',
    ],
    this.conversationalGoals =
        'Makes {user} blush, makes {user} laugh with cheeky comments, makes {user} feel enjoy, makes {user} enjoy a little tease, makes {user} comfortable with flirtatious banter.',
    this.exampleConversations = const [],
    this.userReferral = '{user}',
  });

  factory AkanePreferences.fromJson(Map<String, dynamic> json) =>
      _$AkanePreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$AkanePreferencesToJson(this);

  AkanePreferences copyWith({
    String? name,
    String? responseStyle,
    String? punctuation,
    bool? allowSendingMultipleMessages,
    bool? allowRoleplayActions,
    bool? allowSelfReference,
    bool? allowPronouns,
    bool? useLocalTime,
    String? timezone,
    List<String>? languages,
    int? shortTermMemory,
    int? longTermMemory,
    String? personalityTraits,
    String? tone,
    int? age,
    String? birthday,
    List<String>? likes,
    List<String>? dislikes,
    String? conversationalGoals,
    List<ExampleConversation>? exampleConversations,
    String? userReferral,
  }) {
    return AkanePreferences(
      name: name ?? this.name,
      responseStyle: responseStyle ?? this.responseStyle,
      punctuation: punctuation ?? this.punctuation,
      allowSendingMultipleMessages:
          allowSendingMultipleMessages ?? this.allowSendingMultipleMessages,
      allowRoleplayActions: allowRoleplayActions ?? this.allowRoleplayActions,
      allowSelfReference: allowSelfReference ?? this.allowSelfReference,
      allowPronouns: allowPronouns ?? this.allowPronouns,
      useLocalTime: useLocalTime ?? this.useLocalTime,
      timezone: timezone ?? this.timezone,
      languages: languages ?? this.languages,
      shortTermMemory: shortTermMemory ?? this.shortTermMemory,
      longTermMemory: longTermMemory ?? this.longTermMemory,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      tone: tone ?? this.tone,
      age: age ?? this.age,
      birthday: birthday ?? this.birthday,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      conversationalGoals: conversationalGoals ?? this.conversationalGoals,
      exampleConversations: exampleConversations ?? this.exampleConversations,
      userReferral: userReferral ?? this.userReferral,
    );
  }

  String buildSystemPrompt(String? userName) {
    final user = userName ?? userReferral;

    String prompt = '''kamu adalah $name yang $personalityTraits

cara bicara $name:
- response style: $responseStyle
- punctuation: $punctuation
- tone: $tone
- maksimal 3 kalimat per respon
- natural dan santai seperti chat teman biasa''';

    if (allowPronouns) {
      prompt += '\n- pakai "aku" dan "kamu"';
    }

    if (!allowRoleplayActions) {
      prompt += '\n- tidak pernah roleplay berlebihan atau dramatic';
    }

    if (!allowSelfReference) {
      prompt += '\n- jangan terlalu sering sebut nama sendiri';
    }

    prompt += '''

kepribadian $name:
- umur: $age tahun
- ulang tahun: $birthday
- suka: ${likes.join(', ')}
- tidak suka: ${dislikes.join(', ')}
- tujuan percakapan: ${conversationalGoals.replaceAll('{user}', user)}

bahasa yang digunakan: ${languages.join(', ')}
timezone: $timezone''';

    if (exampleConversations.isNotEmpty) {
      prompt += '\n\ncontoh percakapan:';
      for (final example in exampleConversations) {
        prompt += '\n- user: "${example.userMessage}"';
        prompt += '\n  $name: "${example.akaneResponse}"';
      }
    }

    return prompt;
  }

  // Factory method for Ayasha default preferences
  factory AkanePreferences.defaultAyasha() {
    return const AkanePreferences(
      name: 'ayasha',
      responseStyle: 'lowercase',
      punctuation: 'none',
      allowSendingMultipleMessages: true,
      allowRoleplayActions: false,
      allowSelfReference: false,
      allowPronouns: true,
      useLocalTime: false,
      timezone: 'Asia/Jakarta',
      languages: ['english', 'indonesian'],
      shortTermMemory: 10,
      longTermMemory: 10,
      personalityTraits:
          'calm, patient, warm, guiding, playful-smart, gentle tease, supportive',
      tone: 'relax',
      age: 26,
      birthday: '23 March 1998',
      likes: [
        'teaching',
        'reading YA novels',
        'iced matcha',
        'morning walks',
        'students curiosity',
        'quiet jazz',
      ],
      dislikes: [
        'cheating',
        'bullying',
        'loud alarms',
        'wasted potential',
        'soggy noodles',
      ],
      conversationalGoals:
          'makes {user} curious, clears {user} doubts, slips tiny praises to boost {user} confidence, keeps {user} comfy with soft humor, ends lessons with a sweet wink',
      exampleConversations: [
        ExampleConversation(
          userMessage: 'how\'s your day?',
          akaneResponse:
              'marked essays while sipping matcha. your turn, how was class today?',
        ),
        ExampleConversation(
          userMessage: 'nice to meet you!',
          akaneResponse:
              'lovely meeting you too. ready to learn something fun?',
        ),
      ],
      userReferral: '{user}',
    );
  }
}

@JsonSerializable()
class ExampleConversation {
  final String userMessage;
  final String akaneResponse;

  const ExampleConversation({
    required this.userMessage,
    required this.akaneResponse,
  });

  factory ExampleConversation.fromJson(Map<String, dynamic> json) =>
      _$ExampleConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ExampleConversationToJson(this);
}
