class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? timezone;
  final String? locale;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.timezone,
    this.locale,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? timezone,
    String? locale,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
    );
  }
}
