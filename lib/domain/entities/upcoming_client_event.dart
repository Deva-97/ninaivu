class UpcomingClientEvent {
  const UpcomingClientEvent({
    required this.clientId,
    required this.clientName,
    required this.mobile,
    required this.eventType,
    required this.label,
    required this.eventDateMs,
    this.profileImagePath,
  });

  final String clientId;
  final String clientName;
  final String mobile;
  final String eventType;
  final String label;
  final int eventDateMs;
  final String? profileImagePath;
}
