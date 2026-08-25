class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String? type;
  final String? data;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'],
      data: json['data'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'],
    );
  }
}
