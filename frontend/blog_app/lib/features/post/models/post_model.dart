import '../../auth/models/user_model.dart';
import 'category_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String? title;
  final String? content;
  final String image;
  final String? createdAt;
  final UserModel? user;
  final CategoryModel? category;
  final int commentsCount;
  final int likesCount;
  final bool isLiked;
  final bool isSaved;

  PostModel({
    required this.id,
    required this.userId,
    this.title,
    this.content,
    required this.image,
    this.createdAt,
    this.user,
    this.category,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.isLiked = false,
    this.isSaved = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title'],
      content: json['content'],
      image: json['image'] ?? '',
      createdAt: json['created_at'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      commentsCount: json['comments_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] == 1 || json['is_liked'] == true,
      isSaved: json['is_saved'] == 1 || json['is_saved'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'image': image,
      'created_at': createdAt,
      'comments_count': commentsCount,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'is_saved': isSaved,
      if (user != null) 'user': user!.toJson(),
      if (category != null) 'category': category!.toJson(),
    };
  }
}
