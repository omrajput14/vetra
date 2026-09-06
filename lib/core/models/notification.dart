class AppNotification {
  final String id;
  final String title;
  final String message;
  final String? payloadJson;
  final String? priority;
  final String? status;
  final DateTime timestamp;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.payloadJson,
    this.priority,
    this.status,
    required this.timestamp,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['body']?.toString() ?? json['message']?.toString() ?? '',
      payloadJson: json['payloadJson']?.toString(),
      priority: json['priority']?.toString() ?? 'NORMAL',
      status: json['status']?.toString() ?? 'SENT',
      timestamp: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}