class User {
  int? userId; // PRIMARY KEY, nullの可能性あり（新規作成時に自動採番されるため）
  String userName;
  String emailAddress;
  List<int> password; // BYTEAはList<int>で表現
  String iconImageUrl;
  String comment;
  String residence; // CHAR(2)
  DateTime subscription;
  int gender; // 性別を表す整数
  int age;
  bool withdrawalFlag; // デフォルト: false

  User({
    this.userId,
    required this.userName,
    required this.emailAddress,
    required this.password,
    required this.iconImageUrl,
    required this.comment,
    required this.residence,
    required this.subscription,
    required this.gender,
    required this.age,
    this.withdrawalFlag = false,
  });

  // マップからUserインスタンスを作成するファクトリーメソッド
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['USER_ID'],
      userName: map['USER_NAME'],
      emailAddress: map['EMAIL_ADDRESS'],
      password: map['PASSWORD'],
      iconImageUrl: map['ICON_IMAGE_URL'],
      comment: map['COMMENT'],
      residence: map['RESIDENCE'],
      subscription: map['SUBSCRIPTION'],
      gender: map['GENDER'],
      age: map['AGE'],
      withdrawalFlag: map['WITHDRAWAL_FLAG'],
    );
  }

  // Userインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'USER_ID': userId,
      'USER_NAME': userName,
      'EMAIL_ADDRESS': emailAddress,
      'PASSWORD': password,
      'ICON_IMAGE_URL': iconImageUrl,
      'COMMENT': comment,
      'RESIDENCE': residence,
      'SUBSCRIPTION': subscription,
      'GENDER': gender,
      'AGE': age,
      'WITHDRAWAL_FLAG': withdrawalFlag,
    };
  }
}
