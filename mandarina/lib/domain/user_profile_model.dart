class UserProfileModel {
  final String coverImageUrl;
  final String profileImageUrl;
  final String name;
  final String profession;
  final List<String> socialLinks;
  final String biography;
  final String gender;
  final int completedTasks;
  final int focusMinutes;
  final int affinityLevel;

  const UserProfileModel({
    required this.coverImageUrl,
    required this.profileImageUrl,
    required this.name,
    required this.profession,
    required this.socialLinks,
    required this.biography,
    required this.gender,
    required this.completedTasks,
    required this.focusMinutes,
    required this.affinityLevel,
  });

  UserProfileModel copyWith({
    String? coverImageUrl,
    String? profileImageUrl,
    String? name,
    String? profession,
    List<String>? socialLinks,
    String? biography,
    String? gender,
    int? completedTasks,
    int? focusMinutes,
    int? affinityLevel,
  }) {
    return UserProfileModel(
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      socialLinks: socialLinks ?? this.socialLinks,
      biography: biography ?? this.biography,
      gender: gender ?? this.gender,
      completedTasks: completedTasks ?? this.completedTasks,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      affinityLevel: affinityLevel ?? this.affinityLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coverImageUrl': coverImageUrl,
      'profileImageUrl': profileImageUrl,
      'name': name,
      'profession': profession,
      'socialLinks': socialLinks,
      'biography': biography,
      'gender': gender,
      'completedTasks': completedTasks,
      'focusMinutes': focusMinutes,
      'affinityLevel': affinityLevel,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      coverImageUrl: map['coverImageUrl'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String? ?? '',
      name: map['name'] as String? ?? '',
      profession: map['profession'] as String? ?? '',
      socialLinks: List<String>.from(map['socialLinks'] as List? ?? const []),
      biography: map['biography'] as String? ?? '',
      gender: map['gender'] as String? ?? 'Prefiero no especificar',
      completedTasks: map['completedTasks'] as int? ?? 0,
      focusMinutes: map['focusMinutes'] as int? ?? 0,
      affinityLevel: map['affinityLevel'] as int? ?? 0,
    );
  }
}
