import '../../auth/models/user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String? title;
  final String? content;
  final List<String> imageUrls;
  final String? createdAt;
  final UserModel? author;
  final int commentsCount;
  final int likesCount;
  final int sharesCount;
  final String? shareUrl;
  final bool isLiked;
  final bool isSaved;
  final String? sharedPostId;
  final PostModel? sharedPost;

  PostModel({
    required this.id,
    required this.userId,
    this.title,
    this.content,
    required this.imageUrls,
    this.createdAt,
    this.author,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.sharesCount = 0,
    this.shareUrl,
    this.isLiked = false,
    this.isSaved = false,
    this.sharedPostId,
    this.sharedPost,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title'],
      content: json['content'],
      imageUrls: json['image_urls'] != null ? List<String>.from(json['image_urls']) : [],
      createdAt: json['created_at'],
      author: json['author'] != null ? UserModel.fromJson(json['author']) : null,
      commentsCount: json['comments_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      shareUrl: json['share_url'],
      isLiked: json['is_liked'] == 1 || json['is_liked'] == true,
      isSaved: json['is_saved'] == 1 || json['is_saved'] == true,
      sharedPostId: json['shared_post_id']?.toString(),
      sharedPost: json['shared_post'] != null ? PostModel.fromJson(json['shared_post']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'image_urls': imageUrls,
      'created_at': createdAt,
      'comments_count': commentsCount,
      'likes_count': likesCount,
      'shares_count': sharesCount,
      'share_url': shareUrl,
      'is_liked': isLiked,
      'is_saved': isSaved,
      if (author != null) 'author': author!.toJson(),
      if (sharedPostId != null) 'shared_post_id': sharedPostId,
      if (sharedPost != null) 'shared_post': sharedPost!.toJson(),
    };
  }
}
