class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final String? gender;
  final String? dateOfBirth;
  final String? createdAt;
  final bool isOnline;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.location,
    this.gender,
    this.dateOfBirth,
    this.createdAt,
    this.isOnline = false,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      location: json['location'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      createdAt: json['created_at'],
      isOnline: json['is_online'] == true || json['is_online'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'location': location,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'created_at': createdAt,
      'is_online': isOnline,
    };
  }
}
