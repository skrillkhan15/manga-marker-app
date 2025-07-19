class Profile {
  final String id;
  final String name;
  final String avatarPath;

  Profile({required this.id, required this.name, required this.avatarPath});

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      name: map['name'] as String,
      avatarPath: map['avatarPath'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'avatarPath': avatarPath};
  }
}
