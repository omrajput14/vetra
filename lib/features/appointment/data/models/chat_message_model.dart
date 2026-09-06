class ChatMessageModel {
  final String id;
  final String appointmentId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String recipientId;
  final String messageType;
  final String content;
  final String? treatmentPayloadJson;
  final bool isRead;
  final String createdAt;

  ChatMessageModel({
    required this.id,
    required this.appointmentId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.recipientId,
    required this.messageType,
    required this.content,
    this.treatmentPayloadJson,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      appointmentId: json['appointmentId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? 'User',
      senderRole: json['senderRole']?.toString() ?? 'FARMER',
      recipientId: json['recipientId']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'TEXT',
      content: json['content']?.toString() ?? '',
      treatmentPayloadJson: json['treatmentPayloadJson']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'recipientId': recipientId,
      'messageType': messageType,
      'content': content,
      'treatmentPayloadJson': treatmentPayloadJson,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
