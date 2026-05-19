import 'dart:convert';
import 'dart:io';

import 'package:ninaivu/core/models/export_format.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<void> exportAndShare({
    required String baseFileName,
    required ExportFormat format,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '$baseFileName.${format.fileExtension}';
    final file = File('${tempDir.path}/$fileName');
    final bytes = _buildFileBytes(format: format, headers: headers, rows: rows);

    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: fileName),
    );
  }

  List<int> _buildFileBytes({
    required ExportFormat format,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return switch (format) {
      ExportFormat.csv => utf8.encode(_buildCsv(headers: headers, rows: rows)),
      ExportFormat.pdf => _buildPdf(headers: headers, rows: rows),
      ExportFormat.doc => utf8.encode(_buildDoc(headers: headers, rows: rows)),
      ExportFormat.txt => utf8.encode(_buildText(headers: headers, rows: rows)),
    };
  }

  String _buildCsv({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final buffer = StringBuffer('\uFEFF')
      ..writeln(headers.map(_escapeCsv).join(','));
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }
    return buffer.toString();
  }

  String _buildDoc({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final tableHead = headers
        .map((header) => '<th>${_escapeHtml(header)}</th>')
        .join();
    final tableRows = rows
        .map(
          (row) =>
              '<tr>${row.map((cell) => '<td>${_escapeHtml(cell)}</td>').join()}</tr>',
        )
        .join('\n');

    return '''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ninaivu Export</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 24px;
        color: #1f2933;
      }
      h1 {
        margin-bottom: 16px;
      }
      table {
        width: 100%;
        border-collapse: collapse;
      }
      th, td {
        border: 1px solid #d2d6dc;
        padding: 10px;
        text-align: left;
        vertical-align: top;
      }
      th {
        background: #f3f4f6;
      }
      tr:nth-child(even) {
        background: #fafafa;
      }
    </style>
  </head>
  <body>
    <h1>Ninaivu Export</h1>
    <table>
      <thead>
        <tr>$tableHead</tr>
      </thead>
      <tbody>
        $tableRows
      </tbody>
    </table>
  </body>
</html>
''';
  }

  String _buildText({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final buffer = StringBuffer('Ninaivu Export\n\n');
    for (var index = 0; index < rows.length; index++) {
      buffer.writeln('Record ${index + 1}');
      final row = rows[index];
      for (var cellIndex = 0; cellIndex < headers.length; cellIndex++) {
        final value = cellIndex < row.length ? row[cellIndex] : '';
        buffer.writeln('${headers[cellIndex]}: $value');
      }
      if (index < rows.length - 1) {
        buffer.writeln('\n----------------------------------------\n');
      }
    }
    return buffer.toString();
  }

  List<int> _buildPdf({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final lines = <String>[
      'Ninaivu Export',
      '',
      _buildPdfLine(headers),
      '-' * 100,
      ...rows.map(_buildPdfLine),
    ];
    final pages = _paginatePdfLines(lines);
    final objects = <String>[];
    final pageObjectNumbers = <int>[];
    const fontObjectNumber = 3;
    var nextObjectNumber = 4;

    for (final pageLines in pages) {
      final pageObjectNumber = nextObjectNumber++;
      final contentObjectNumber = nextObjectNumber++;
      pageObjectNumbers.add(pageObjectNumber);
      objects.add(
        _buildPdfPageObject(
          pageObjectNumber,
          contentObjectNumber,
          fontObjectNumber,
        ),
      );
      objects.add(_buildPdfContentObject(contentObjectNumber, pageLines));
    }

    final pageReferences = pageObjectNumbers
        .map((number) => '$number 0 R')
        .join(' ');
    final allObjects = <String>[
      '1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n',
      '2 0 obj\n<< /Type /Pages /Kids [$pageReferences] /Count ${pageObjectNumbers.length} >>\nendobj\n',
      '3 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n',
      ...objects,
    ];

    final buffer = StringBuffer('%PDF-1.4\n');
    final offsets = <int>[0];
    for (final object in allObjects) {
      offsets.add(buffer.toString().length);
      buffer.write(object);
    }

    final xrefOffset = buffer.toString().length;
    buffer.writeln('xref');
    buffer.writeln('0 ${allObjects.length + 1}');
    buffer.writeln('0000000000 65535 f ');
    for (var index = 1; index < offsets.length; index++) {
      buffer.writeln('${offsets[index].toString().padLeft(10, '0')} 00000 n ');
    }
    buffer.writeln('trailer');
    buffer.writeln('<< /Size ${allObjects.length + 1} /Root 1 0 R >>');
    buffer.writeln('startxref');
    buffer.writeln(xrefOffset);
    buffer.write('%%EOF');
    return ascii.encode(buffer.toString());
  }

  List<List<String>> _paginatePdfLines(List<String> lines) {
    const maxCharsPerLine = 95;
    const maxLinesPerPage = 42;
    final wrappedLines = <String>[];

    for (final line in lines) {
      if (line.isEmpty) {
        wrappedLines.add('');
        continue;
      }

      var remaining = line;
      while (remaining.length > maxCharsPerLine) {
        final breakIndex = remaining.lastIndexOf(' ', maxCharsPerLine);
        final splitIndex = breakIndex > 0 ? breakIndex : maxCharsPerLine;
        wrappedLines.add(remaining.substring(0, splitIndex).trimRight());
        remaining = remaining.substring(splitIndex).trimLeft();
      }
      wrappedLines.add(remaining);
    }

    final pages = <List<String>>[];
    for (var i = 0; i < wrappedLines.length; i += maxLinesPerPage) {
      final end = (i + maxLinesPerPage < wrappedLines.length)
          ? i + maxLinesPerPage
          : wrappedLines.length;
      pages.add(wrappedLines.sublist(i, end));
    }
    return pages.isEmpty
        ? <List<String>>[
            <String>['Ninaivu Export'],
          ]
        : pages;
  }

  String _buildPdfPageObject(
    int pageObjectNumber,
    int contentObjectNumber,
    int fontObjectNumber,
  ) {
    return '$pageObjectNumber 0 obj\n'
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
        '/Resources << /Font << /F1 $fontObjectNumber 0 R >> >> '
        '/Contents $contentObjectNumber 0 R >>\n'
        'endobj\n';
  }

  String _buildPdfContentObject(int objectNumber, List<String> lines) {
    final content = StringBuffer()
      ..writeln('BT')
      ..writeln('/F1 10 Tf')
      ..writeln('40 800 Td')
      ..writeln('14 TL');

    for (final line in lines) {
      content.writeln('(${_escapePdfText(_asciiSafe(line))}) Tj');
      content.writeln('T*');
    }

    content.writeln('ET');
    final stream = content.toString();
    return '$objectNumber 0 obj\n'
        '<< /Length ${stream.length} >>\n'
        'stream\n'
        '$stream'
        'endstream\n'
        'endobj\n';
  }

  String _buildPdfLine(List<String> columns) {
    return columns
        .map((value) => value.replaceAll('\n', ' ').trim())
        .join(' | ');
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _escapeHtml(String value) {
    return const HtmlEscape(HtmlEscapeMode.element).convert(value);
  }

  String _escapePdfText(String value) {
    return value
        .replaceAll('\\', r'\\')
        .replaceAll('(', r'\(')
        .replaceAll(')', r'\)');
  }

  String _asciiSafe(String value) {
    return value.replaceAll(RegExp(r'[^\x20-\x7E]'), '?');
  }
}
