class DateFormatter {
  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Unknown date';
    try {
      final DateTime date = DateTime.parse(dateStr).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[date.month - 1];
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      
      return '${date.day} $month ${date.year} at $hour:$minute';
    } catch (_) {
      return 'Recent';
    }
  }

  static String timeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Unknown date';
    try {
      final DateTime date = DateTime.parse(dateStr).toLocal();
      final Duration diff = DateTime.now().difference(date);
      
      if (diff.inDays > 365) {
        return '${(diff.inDays / 365).floor()}y ago';
      } else if (diff.inDays > 30) {
        return '${(diff.inDays / 30).floor()}mo ago';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return 'Recent';
    }
  }
}
