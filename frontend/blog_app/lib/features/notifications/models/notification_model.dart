import '../../auth/models/user_model.dart';

class NotificationModel {
  final String id;
  final String type;
  final String message;
  final UserModel? sender;
  final String? postId;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    this.sender,
    this.postId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      type: json['type'] ?? 'info',
      message: json['message'] ?? '',
      sender: json['sender'] != null
          ? UserModel.fromJson(json['sender'])
          : null,
      postId: json['post_id']?.toString(),
      isRead: json['read_at'] != null,
      createdAt: json['created_at'] ?? '',
    );
  }
}
