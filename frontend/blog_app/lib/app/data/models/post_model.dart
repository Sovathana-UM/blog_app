import 'user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String? title;
  final String image;
  final String? createdAt;
  final UserModel? user;
  final int commentsCount;
  final int likesCount;

  PostModel({
    required this.id,
    required this.userId,
    this.title,
    required this.image,
    this.createdAt,
    this.user,
    this.commentsCount = 0,
    this.likesCount = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title'],
      image: json['image'] ?? '',
      createdAt: json['created_at'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      commentsCount: json['comments_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'image': image,
      'created_at': createdAt,
      'comments_count': commentsCount,
      'likes_count': likesCount,
      if (user != null) 'user': user!.toJson(),
    };
  }
}
