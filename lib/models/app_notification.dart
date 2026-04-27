class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.type = 'general',
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final String type;
  bool read;
}
