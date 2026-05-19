class ClientTimelineItem {
  const ClientTimelineItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.dateTimeMillis,
    required this.routeName,
    required this.routeArgument,
  });

  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String status;
  final int dateTimeMillis;
  final String routeName;
  final String routeArgument;
}
