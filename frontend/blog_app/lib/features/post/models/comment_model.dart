import '../../auth/models/user_model.dart';

class CommentModel {
  final int id;
  final String postId;
  final String userId;
  final String content;
  final String createdAt;
  final UserModel? user;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      postId: json['post_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      user: json['author'] != null ? UserModel.fromJson(json['author']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt,
      if (user != null) 'user': user!.toJson(),
    };
  }
}
