class ChatMessage {
  final String id;
  final String text;
  final bool isFromUser;
  final bool isFromAdmin;
  final DateTime timestamp;
  final bool isRead;
  final String? senderName;
  final bool isOptimistic;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.isFromAdmin,
    required this.timestamp,
    this.isRead = false,
    this.senderName,
    this.isOptimistic = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Both HTTP and WebSocket now return is_admin_reply and sender_name
    final isAdmin = json['is_admin_reply'] == true;
    final isUser = !isAdmin;

    return ChatMessage(
      id: json['id'].toString(),
      text: json['message'] ?? '',
      isFromUser: isUser,
      isFromAdmin: isAdmin,
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      senderName: isAdmin ? 'Support Agent' : (json['sender_name'] ?? 'You'),
      isOptimistic: json['isOptimistic'] ?? false,
    );
  }
}
