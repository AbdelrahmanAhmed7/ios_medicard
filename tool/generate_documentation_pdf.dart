import 'dart:convert';
import 'dart:io';

const _defaultOutput = 'docs/MediCard_Project_Documentation.pdf';

void main(List<String> arguments) async {
  final root = Directory.current.absolute;
  if (!File('pubspec.yaml').existsSync() || !Directory('docs').existsSync()) {
    stderr.writeln('Run this command from the repository root.');
    exitCode = 64;
    return;
  }

  final outputPath = arguments.isEmpty ? _defaultOutput : arguments.first;
  final documents = <_SourceDocument>[
    const _SourceDocument('README.md', 'نظرة عامة'),
    const _SourceDocument('docs/ARCHITECTURE.md', 'المعمارية'),
    const _SourceDocument('docs/FEATURES.md', 'الميزات'),
    const _SourceDocument('docs/API_AND_ROUTES.md', 'واجهات API والتنقل'),
    const _SourceDocument('docs/DEVELOPMENT.md', 'التطوير والصيانة'),
    const _SourceDocument('docs/CODE_REFERENCE.md', 'مرجع الكود الكامل'),
  ];

  for (final document in documents) {
    if (!File(document.path).existsSync()) {
      stderr.writeln('Missing documentation source: ${document.path}');
      exitCode = 66;
      return;
    }
  }

  final buildDirectory = Directory('build/documentation')
    ..createSync(recursive: true);
  final htmlFile = File('${buildDirectory.path}/medicard_documentation.html');
  htmlFile.writeAsStringSync(_buildHtml(root, documents));

  final result = await Process.run('swift', [
    'tool/html_to_pdf.swift',
    htmlFile.absolute.path,
    File(outputPath).absolute.path,
  ], runInShell: false);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    exitCode = result.exitCode;
    return;
  }

  stdout.writeln(
    'PDF documentation is ready: ${File(outputPath).absolute.path}',
  );
}

String _buildHtml(Directory root, List<_SourceDocument> documents) {
  final regularFont = File('assets/fonts/Cairo-Regular.ttf').absolute.uri;
  final semiboldFont = File('assets/fonts/Cairo-SemiBold.ttf').absolute.uri;
  final boldFont = File('assets/fonts/Cairo-Bold.ttf').absolute.uri;
  final generatedOn = _formatDate(DateTime.now());
  final anchors = <String, String>{};

  for (final document in documents) {
    anchors[document.path] = document.anchor;
    anchors[document.path.split('/').last] = document.anchor;
    if (document.path.startsWith('docs/')) {
      anchors[document.path.substring('docs/'.length)] = document.anchor;
    }
  }

  final content = StringBuffer();
  for (final document in documents) {
    final source = File(document.path).readAsStringSync();
    content
      ..writeln('<section class="document-section" id="${document.anchor}">')
      ..writeln(
        _MarkdownRenderer(
          root: root,
          sourcePath: document.path,
          documentAnchors: anchors,
        ).render(source),
      )
      ..writeln('</section>');
  }

  final tocItems = documents
      .map(
        (document) =>
            '<li><a href="#${document.anchor}">${_escape(document.title)}</a></li>',
      )
      .join('\n');

  return '''<!doctype html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="utf-8">
  <title>MediCard — توثيق المشروع الكامل</title>
  <style>
    @font-face { font-family: Cairo; src: url("$regularFont"); font-weight: 400; }
    @font-face { font-family: Cairo; src: url("$semiboldFont"); font-weight: 600; }
    @font-face { font-family: Cairo; src: url("$boldFont"); font-weight: 700; }
    @page { size: A4; margin: 14mm 12mm 16mm; }
    * { box-sizing: border-box; }
    html { direction: rtl; }
    body {
      margin: 0;
      color: #172033;
      background: #fff;
      font-family: Cairo, "Arial Unicode MS", sans-serif;
      font-size: 9.2pt;
      line-height: 1.65;
      direction: rtl;
      text-align: right;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
    }
    .cover {
      min-height: 245mm;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
      page-break-after: always;
      background: linear-gradient(150deg, #f7fbff 0%, #eef7ff 55%, #ffffff 100%);
      border: 2px solid #d9ebf8;
      border-radius: 18px;
      padding: 28mm 18mm;
    }
    .cover img { width: 52mm; max-height: 35mm; object-fit: contain; margin-bottom: 16mm; }
    .cover h1 { margin: 0; color: #086aa7; font-size: 29pt; border: 0; }
    .cover .subtitle { margin-top: 8mm; font-size: 15pt; color: #334d63; }
    .cover .meta { margin-top: 20mm; color: #617487; font-size: 10pt; }
    .front-toc { page-break-after: always; }
    .front-toc ol { columns: 2; column-gap: 12mm; font-size: 12pt; }
    .front-toc li { margin: 4mm 0; break-inside: avoid; }
    .document-section > h1:first-child { page-break-before: always; }
    h1, h2, h3, h4 { color: #075f93; page-break-after: avoid; }
    h1 { font-size: 23pt; border-bottom: 2px solid #8fc8e8; padding-bottom: 4mm; margin: 0 0 9mm; }
    h2 { font-size: 16pt; border-bottom: 1px solid #d7e8f2; padding-bottom: 2mm; margin: 9mm 0 4mm; }
    h3 { font-size: 12.5pt; margin: 6mm 0 2mm; color: #244d68; }
    h4 { font-size: 10.5pt; margin: 4mm 0 1.5mm; }
    p { margin: 2.2mm 0; orphans: 3; widows: 3; }
    ul, ol { margin: 2mm 0; padding-right: 7mm; }
    li { margin: 1mm 0; }
    a { color: #087bbd; text-decoration: none; }
    code {
      direction: ltr;
      unicode-bidi: embed;
      display: inline-block;
      font-family: Menlo, "Courier New", monospace;
      font-size: 8.2pt;
      background: #f0f5f8;
      border: 1px solid #dce8ee;
      border-radius: 3px;
      padding: 0.2mm 1mm;
    }
    pre {
      direction: ltr;
      text-align: left;
      white-space: pre-wrap;
      overflow-wrap: anywhere;
      background: #102a3a;
      color: #eff8fc;
      border-radius: 6px;
      padding: 4mm;
      font: 7.8pt/1.55 Menlo, "Courier New", monospace;
      page-break-inside: avoid;
    }
    pre code { display: inline; color: inherit; background: none; border: 0; padding: 0; }
    blockquote {
      margin: 4mm 0;
      padding: 3mm 4mm;
      background: #f3f9fc;
      border-right: 4px solid #42a6d8;
      color: #3d586a;
    }
    table { width: 100%; border-collapse: collapse; margin: 4mm 0 7mm; font-size: 7.8pt; }
    thead { display: table-header-group; }
    tr { page-break-inside: avoid; }
    th { background: #086a9f; color: white; font-weight: 600; }
    th, td { border: 1px solid #c9dce7; padding: 1.8mm 2mm; vertical-align: top; }
    tbody tr:nth-child(even) { background: #f5f9fb; }
    .document-section { max-width: 100%; }
    #doc-code-reference h3 {
      direction: ltr;
      text-align: left;
      font-family: Menlo, monospace;
      font-size: 9pt;
      overflow-wrap: anywhere;
      background: #f5f8fa;
      padding: 2mm;
      border-radius: 4px;
    }
    #doc-code-reference li { page-break-inside: avoid; font-size: 7.6pt; }
    .source-label { color: #667b89; font-size: 8pt; margin-bottom: 8mm; }
  </style>
</head>
<body>
  <section class="cover">
    <h1>توثيق مشروع MediCard</h1>
    <div class="subtitle">الدليل الفني الكامل لتطبيق Flutter</div>
    <div class="meta">الإصدار 1.0.0 — Build 2<br>تاريخ التوليد: $generatedOn</div>
  </section>
  <section class="front-toc">
    <h1>محتويات الملف</h1>
    <ol>$tocItems</ol>
    <p class="source-label">يتضمن الملف شرح المعمارية والميزات وواجهات API ومسارات التنقل ودليل التطوير ومرجع جميع تصريحات Dart المكتوبة يدويًا.</p>
  </section>
  $content
</body>
</html>
''';
}

String _formatDate(DateTime date) {
  const months = <String>[
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class _SourceDocument {
  const _SourceDocument(this.path, this.title);

  final String path;
  final String title;

  String get anchor {
    final name = path.split('/').last.replaceAll('.md', '').toLowerCase();
    return 'doc-${name.replaceAll('_', '-')}';
  }
}

class _MarkdownRenderer {
  _MarkdownRenderer({
    required this.root,
    required this.sourcePath,
    required this.documentAnchors,
  });

  final Directory root;
  final String sourcePath;
  final Map<String, String> documentAnchors;
  final _usedHeadingIds = <String, int>{};

  String render(String markdown) {
    final lines = const LineSplitter().convert(markdown);
    final output = StringBuffer();
    var index = 0;
    var inCode = false;
    var codeLanguage = '';
    final code = StringBuffer();
    String? listType;

    void closeList() {
      if (listType != null) {
        output.writeln('</$listType>');
        listType = null;
      }
    }

    while (index < lines.length) {
      final line = lines[index];
      final trimmed = line.trim();

      if (trimmed.startsWith('```')) {
        closeList();
        if (!inCode) {
          inCode = true;
          codeLanguage = trimmed.substring(3).trim();
          code.clear();
        } else {
          final languageClass = codeLanguage.isEmpty
              ? ''
              : ' class="language-${_escapeAttribute(codeLanguage)}"';
          output.writeln(
            '<pre dir="ltr"><code$languageClass>${_escape(code.toString().replaceFirst(RegExp(r'\n$'), ''))}</code></pre>',
          );
          inCode = false;
        }
        index++;
        continue;
      }

      if (inCode) {
        code.writeln(line);
        index++;
        continue;
      }

      if (_isTableStart(lines, index)) {
        closeList();
        final tableLines = <String>[line];
        index += 2; // Skip the Markdown separator row.
        while (index < lines.length && lines[index].trim().startsWith('|')) {
          tableLines.add(lines[index]);
          index++;
        }
        output.writeln(_renderTable(tableLines));
        continue;
      }

      final heading = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(trimmed);
      if (heading != null) {
        closeList();
        final level = heading.group(1)!.length;
        final text = heading.group(2)!;
        final id = level == 1 ? _documentAnchor : _uniqueSlug(text);
        output.writeln('<h$level id="$id">${_inline(text)}</h$level>');
        index++;
        continue;
      }

      final bullet = RegExp(r'^[-*]\s+(.+)$').firstMatch(trimmed);
      final numbered = RegExp(r'^\d+\.\s+(.+)$').firstMatch(trimmed);
      if (bullet != null || numbered != null) {
        final desiredType = bullet != null ? 'ul' : 'ol';
        if (listType != desiredType) {
          closeList();
          listType = desiredType;
          output.writeln('<$desiredType>');
        }
        output.writeln('<li>${_inline((bullet ?? numbered)!.group(1)!)}</li>');
        index++;
        continue;
      }

      if (trimmed.startsWith('>')) {
        closeList();
        output.writeln(
          '<blockquote>${_inline(trimmed.substring(1).trim())}</blockquote>',
        );
        index++;
        continue;
      }

      if (trimmed.isEmpty) {
        closeList();
        index++;
        continue;
      }

      closeList();
      final paragraph = StringBuffer(trimmed);
      index++;
      while (index < lines.length && _isParagraphContinuation(lines, index)) {
        paragraph.write(' ${lines[index].trim()}');
        index++;
      }
      output.writeln('<p>${_inline(paragraph.toString())}</p>');
    }

    closeList();
    if (inCode) {
      output.writeln(
        '<pre dir="ltr"><code>${_escape(code.toString())}</code></pre>',
      );
    }
    return output.toString();
  }

  String get _documentAnchor {
    final name = sourcePath.split('/').last.replaceAll('.md', '').toLowerCase();
    return 'doc-${name.replaceAll('_', '-')}';
  }

  bool _isTableStart(List<String> lines, int index) {
    if (!lines[index].trim().startsWith('|') || index + 1 >= lines.length) {
      return false;
    }
    final separator = _tableCells(lines[index + 1]);
    return separator.isNotEmpty &&
        separator.every((cell) => RegExp(r'^:?-{3,}:?$').hasMatch(cell.trim()));
  }

  bool _isParagraphContinuation(List<String> lines, int index) {
    final value = lines[index].trim();
    if (value.isEmpty ||
        value.startsWith('#') ||
        value.startsWith('```') ||
        value.startsWith('>') ||
        value.startsWith('|')) {
      return false;
    }
    return !RegExp(r'^[-*]\s+').hasMatch(value) &&
        !RegExp(r'^\d+\.\s+').hasMatch(value);
  }

  String _renderTable(List<String> lines) {
    final rows = lines.map(_tableCells).toList();
    final output = StringBuffer('<table><thead><tr>');
    for (final cell in rows.first) {
      output.write('<th>${_inline(cell)}</th>');
    }
    output.write('</tr></thead><tbody>');
    for (final row in rows.skip(1)) {
      output.write('<tr>');
      for (final cell in row) {
        output.write('<td>${_inline(cell)}</td>');
      }
      output.write('</tr>');
    }
    output.write('</tbody></table>');
    return output.toString();
  }

  List<String> _tableCells(String line) {
    var value = line.trim();
    if (value.startsWith('|')) value = value.substring(1);
    if (value.endsWith('|')) value = value.substring(0, value.length - 1);
    return value.split('|').map((cell) => cell.trim()).toList();
  }

  String _inline(String text) {
    final links = <String>[];
    var value = text.replaceAllMapped(RegExp(r'\[([^\]]+)\]\(([^)]+)\)'), (
      match,
    ) {
      final label = _styleInline(_escape(match.group(1)!));
      final href = _escapeAttribute(_resolveLink(match.group(2)!));
      final token = '@@LINK${links.length}@@';
      links.add('<a href="$href">$label</a>');
      return token;
    });
    value = _styleInline(_escape(value));
    for (var i = 0; i < links.length; i++) {
      value = value.replaceAll('@@LINK$i@@', links[i]);
    }
    return value;
  }

  String _styleInline(String escaped) {
    var value = escaped.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (match) => '<code>${match.group(1)}</code>',
    );
    value = value.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (match) => '<strong>${match.group(1)}</strong>',
    );
    return value;
  }

  String _resolveLink(String rawLink) {
    if (rawLink.startsWith('http://') ||
        rawLink.startsWith('https://') ||
        rawLink.startsWith('mailto:') ||
        rawLink.startsWith('#')) {
      return rawLink;
    }

    final fragmentIndex = rawLink.indexOf('#');
    final path = fragmentIndex == -1
        ? rawLink
        : rawLink.substring(0, fragmentIndex);
    final fragment = fragmentIndex == -1
        ? ''
        : rawLink.substring(fragmentIndex);
    final normalized = path.startsWith('./') ? path.substring(2) : path;

    final directAnchor =
        documentAnchors[normalized] ??
        documentAnchors[normalized.replaceFirst('docs/', '')];
    if (directAnchor != null) return '#$directAnchor';

    final sourceDirectory = File(sourcePath).parent.path;
    final resolved = File('$sourceDirectory/$path').absolute.uri.toString();
    return '$resolved$fragment';
  }

  String _uniqueSlug(String text) {
    var slug = text
        .replaceAll(RegExp(r'`|\*'), '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.isEmpty) slug = 'section';
    final count = _usedHeadingIds.update(
      slug,
      (value) => value + 1,
      ifAbsent: () => 0,
    );
    return count == 0 ? slug : '$slug-$count';
  }
}

String _escape(String value) =>
    const HtmlEscape(HtmlEscapeMode.element).convert(value);

String _escapeAttribute(String value) =>
    const HtmlEscape(HtmlEscapeMode.attribute).convert(value);
