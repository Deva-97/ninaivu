class PolicyDocumentExtractionException implements Exception {
  const PolicyDocumentExtractionException({
    required this.messageKey,
    this.detailKey,
  });

  final String messageKey;
  final String? detailKey;

  @override
  String toString() {
    return detailKey == null ? messageKey : '$messageKey|$detailKey';
  }
}
