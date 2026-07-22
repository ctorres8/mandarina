class UserProfileModel {
  final String id;
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
  final bool hasCompletedTutorial;
  final String timerSound;
  final double timerVolume;

  const UserProfileModel({
    required this.id,
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
    this.hasCompletedTutorial = false,
    this.timerSound = 'bell_sound',
    this.timerVolume = 0.8,
  });

  UserProfileModel copyWith({
    String? id,
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
    bool? hasCompletedTutorial,
    String? timerSound,
    double? timerVolume,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
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
      hasCompletedTutorial: hasCompletedTutorial ?? this.hasCompletedTutorial,
      timerSound: timerSound ?? this.timerSound,
      timerVolume: timerVolume ?? this.timerVolume,
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
      'hasCompletedTutorial': hasCompletedTutorial,
      'timer_sound': timerSound,
      'timer_volume': timerVolume,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return UserProfileModel(
      id: id,
      coverImageUrl: map['coverImageUrl'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String? ?? '',
      name: map['name'] as String? ?? '',
      profession: map['profession'] as String? ?? '',
      socialLinks: List<String>.from(map['socialLinks'] as List? ?? const []),
      biography: map['biography'] as String? ?? '',
      gender: map['gender'] as String? ?? 'No especificado',
      completedTasks: map['completedTasks'] as int? ?? 0,
      focusMinutes: map['focusMinutes'] as int? ?? 0,
      affinityLevel: map['affinityLevel'] as int? ?? 0,
      hasCompletedTutorial: map['hasCompletedTutorial'] as bool? ?? false,
      timerSound: map['timer_sound'] as String? ?? 'bell_sound',
      timerVolume: (map['timer_volume'] as num?)?.toDouble() ?? 0.8,
    );
  }
}


