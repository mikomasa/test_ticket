// 同行者募集bean

class Companion {
  int? companionId;
  int userId;
  int eventId;
  String recruitmentTitle;
  int recruitmentMember;
  DateTime recruitmentLimit;
  int recruitmentGender;
  int recruitmentAge;
  String recruitmentText;

  Companion({
    this.companionId,
    required this.userId,
    required this.eventId,
    required this.recruitmentTitle,
    required this.recruitmentMember,
    required this.recruitmentLimit,
    required this.recruitmentGender,
    required this.recruitmentAge,
    required this.recruitmentText,
  });

  // CompanionオブジェクトをMapに変換する
  Map<String, dynamic> toMap() {
    return {
      'USER_ID': userId,
      'EVENT_ID': eventId,
      'RECRUITMENT_TITLE': recruitmentTitle,
      'RECRUITMENT_MEMBER': recruitmentMember,
      'RECRUITMENT_LIMIT': recruitmentLimit.toIso8601String(),
      'RECRUITMENT_GENDER': recruitmentGender,
      'RECRUITMENT_AGE': recruitmentAge,
      'RECRUITMENT_TEXT': recruitmentText,
    };
  }

  // MapをCompanionオブジェクトに変換する
  factory Companion.fromMap(Map<String, dynamic> map) {
    return Companion(
      companionId: map['COMPANION_ID'],
      userId: map['USER_ID'],
      eventId: map['EVENT_ID'],
      recruitmentTitle: map['RECRUITMENT_TITLE'],
      recruitmentMember: map['RECRUITMENT_MEMBER'],
      recruitmentLimit: DateTime.parse(map['RECRUITMENT_LIMIT']),
      recruitmentGender: map['RECRUITMENT_GENDER'],
      recruitmentAge: map['RECRUITMENT_AGE'],
      recruitmentText: map['RECRUITMENT_TEXT'],
    );
  }
}
