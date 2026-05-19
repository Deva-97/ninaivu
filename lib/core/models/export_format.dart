enum ExportFormat {
  csv,
  pdf,
  doc,
  txt,
}

extension ExportFormatX on ExportFormat {
  String get label => switch (this) {
    ExportFormat.csv => 'CSV',
    ExportFormat.pdf => 'PDF',
    ExportFormat.doc => 'DOC',
    ExportFormat.txt => 'TXT',
  };

  String get fileExtension => switch (this) {
    ExportFormat.csv => 'csv',
    ExportFormat.pdf => 'pdf',
    ExportFormat.doc => 'doc',
    ExportFormat.txt => 'txt',
  };

  String get description => switch (this) {
    ExportFormat.csv => 'Best for Excel, Sheets, sorting, and filtering',
    ExportFormat.pdf => 'Best for fixed-layout sharing and printing',
    ExportFormat.doc => 'Best for Word-style document opening and editing',
    ExportFormat.txt => 'Best for lightweight plain-text export',
  };
}
