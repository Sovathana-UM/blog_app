class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;
  final String? bio;
  final String? location;
  final String? gender;
  final String? dateOfBirth;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicture,
    this.bio,
    this.location,
    this.gender,
    this.dateOfBirth,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      location: json['location'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'profile_picture': profilePicture,
      'bio': bio,
      'location': location,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'created_at': createdAt,
    };
  }
}
