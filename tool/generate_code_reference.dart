import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Generates docs/CODE_REFERENCE.md directly from the Dart syntax tree.
///
/// Run from the repository root:
///   dart run tool/generate_code_reference.dart
void main() {
  final libDirectory = Directory('lib');
  if (!libDirectory.existsSync()) {
    stderr.writeln('Run this command from the repository root.');
    exitCode = 64;
    return;
  }

  final files =
      libDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where((file) => !file.path.endsWith('.g.dart'))
          .where((file) => !file.path.endsWith('.freezed.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final indexedFiles = <_IndexedFile>[];
  for (final file in files) {
    final source = file.readAsStringSync();
    final parsed = parseString(
      content: source,
      path: file.path,
      throwIfDiagnostics: false,
    );
    final collector = _DeclarationCollector(
      filePath: file.path,
      lineInfo: parsed.lineInfo,
    );
    parsed.unit.accept(collector);
    indexedFiles.add(_IndexedFile(file.path, collector.declarations));
  }

  final output = File('docs/CODE_REFERENCE.md');
  output.parent.createSync(recursive: true);
  output.writeAsStringSync(_render(indexedFiles));

  final declarationCount = indexedFiles.fold<int>(
    0,
    (total, file) => total + file.declarations.length,
  );
  stdout.writeln(
    'Generated ${output.path}: ${indexedFiles.length} files, '
    '$declarationCount declarations.',
  );
}

String _render(List<_IndexedFile> files) {
  final buffer = StringBuffer()
    ..writeln('# مرجع الكود الكامل')
    ..writeln()
    ..writeln(
      '> هذا الملف مولّد آليًا من شجرة بناء Dart. لا تعدّله يدويًا؛ شغّل '
      '`dart run tool/generate_code_reference.dart` بعد تغيير الواجهات أو الدوال.',
    )
    ..writeln()
    ..writeln('## طريقة قراءة المرجع')
    ..writeln()
    ..writeln(
      '- يغطي كل ملفات Dart المكتوبة يدويًا داخل `lib/`، بما فيها الدوال الخاصة.',
    )
    ..writeln(
      '- يستبعد ملفات `*.g.dart` و`*.freezed.dart` لأنها ناتج توليد وليست مصدرًا يُعدّل يدويًا.',
    )
    ..writeln(
      '- اضغط على أي توقيع للانتقال إلى مكانه في المصدر. وسم **خاص** يعني أن الاسم يبدأ بـ `_`.',
    )
    ..writeln(
      '- الوصف المختصر يوضح غرض الدالة من اسمها وسياق ملفها؛ المصدر المرتبط هو المرجع النهائي للتفاصيل التنفيذية.',
    )
    ..writeln()
    ..writeln('## الفهرس')
    ..writeln();

  final sections = <String, List<_IndexedFile>>{};
  for (final file in files) {
    final section = _sectionFor(file.path);
    sections.putIfAbsent(section, () => []).add(file);
  }

  for (final section in sections.keys) {
    final anchor = section
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff ]'), '')
        .replaceAll(' ', '-');
    buffer.writeln('- [$section](#$anchor)');
  }

  for (final entry in sections.entries) {
    buffer
      ..writeln()
      ..writeln('## ${entry.key}')
      ..writeln();

    for (final file in entry.value) {
      final relative = file.path.replaceFirst('lib/', '');
      buffer
        ..writeln('### `$relative`')
        ..writeln();

      if (file.declarations.isEmpty) {
        buffer.writeln('- لا يحتوي تصريحات قابلة للفهرسة.');
        buffer.writeln();
        continue;
      }

      for (final declaration in file.declarations) {
        final href = '../${file.path}#L${declaration.line}';
        final privateLabel = declaration.isPrivate ? ' — **خاص**' : '';
        buffer.writeln(
          '- [`${_escapeCode(declaration.signature)}`]($href)$privateLabel — '
          '${declaration.description}',
        );
      }
      buffer.writeln();
    }
  }

  return buffer.toString();
}

String _sectionFor(String path) {
  final parts = path.split('/');
  if (parts.length >= 3 && parts[1] == 'features') {
    return 'Feature: ${parts[2]}';
  }
  if (parts.length >= 3 && parts[1] == 'core') {
    return 'Core: ${parts[2]}';
  }
  if (parts.length >= 2) return 'Module: ${parts[1]}';
  return 'Other';
}

String _escapeCode(String value) => value.replaceAll('`', r'\`');

class _DeclarationCollector extends RecursiveAstVisitor<void> {
  _DeclarationCollector({required this.filePath, required this.lineInfo});

  final String filePath;
  final dynamic lineInfo;
  final declarations = <_Declaration>[];
  final _owners = <String>[];

  int _line(AstNode node) =>
      lineInfo.getLocation(node.offset).lineNumber as int;

  void _addType(String kind, String name, AstNode node) {
    declarations.add(
      _Declaration(
        line: _line(node),
        signature: '$kind $name',
        name: name,
        kind: kind,
        owner: _owners.isEmpty ? null : _owners.last,
        filePath: filePath,
      ),
    );
  }

  void _inside(String owner, void Function() visitChildren) {
    _owners.add(owner);
    visitChildren();
    _owners.removeLast();
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final name = node.namePart.typeName.lexeme;
    _addType('class', name, node);
    _inside(name, () => super.visitClassDeclaration(node));
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    final name = node.name.lexeme;
    _addType('mixin', name, node);
    _inside(name, () => super.visitMixinDeclaration(node));
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    final name = node.namePart.typeName.lexeme;
    _addType('enum', name, node);
    _inside(name, () => super.visitEnumDeclaration(node));
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    final name = node.name?.lexeme ?? '<unnamed extension>';
    _addType('extension', name, node);
    _inside(name, () => super.visitExtensionDeclaration(node));
  }

  @override
  void visitExtensionTypeDeclaration(ExtensionTypeDeclaration node) {
    final name = node.primaryConstructor.typeName.lexeme;
    _addType('extension type', name, node);
    _inside(name, () => super.visitExtensionTypeDeclaration(node));
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final name = node.name.lexeme;
    final returnType = node.returnType?.toSource() ?? 'dynamic';
    final property = node.propertyKeyword?.lexeme;
    final parameters = node.functionExpression.parameters?.toSource() ?? '';
    final signature = property == 'get'
        ? '$returnType get $name'
        : '$returnType ${property == 'set' ? 'set ' : ''}$name$parameters';
    _addCallable(name, signature, node, 'function');
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final name = node.name.lexeme;
    final modifiers = <String>[
      if (node.isStatic) 'static',
      if (node.externalKeyword != null) 'external',
    ];
    final returnType = node.returnType?.toSource() ?? 'dynamic';
    final parameters = node.parameters?.toSource() ?? '';
    final property = node.propertyKeyword?.lexeme;
    final core = property == 'get'
        ? '$returnType get $name'
        : '$returnType ${property == 'set' ? 'set ' : ''}$name$parameters';
    final signature = [...modifiers, core].join(' ');
    _addCallable(name, signature, node, 'method');
    super.visitMethodDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final className = _owners.isEmpty ? '<constructor>' : _owners.last;
    final suffix = node.name == null ? '' : '.${node.name!.lexeme}';
    final modifiers = <String>[
      if (node.constKeyword != null) 'const',
      if (node.factoryKeyword != null) 'factory',
    ];
    final signature = [
      ...modifiers,
      '$className$suffix${node.parameters.toSource()}',
    ].join(' ');
    _addCallable(className, signature, node, 'constructor');
    super.visitConstructorDeclaration(node);
  }

  void _addCallable(String name, String signature, AstNode node, String kind) {
    declarations.add(
      _Declaration(
        line: _line(node),
        signature: signature.replaceAll(RegExp(r'\s+'), ' ').trim(),
        name: name,
        kind: kind,
        owner: _owners.isEmpty ? null : _owners.last,
        filePath: filePath,
      ),
    );
  }
}

class _IndexedFile {
  const _IndexedFile(this.path, this.declarations);

  final String path;
  final List<_Declaration> declarations;
}

class _Declaration {
  const _Declaration({
    required this.line,
    required this.signature,
    required this.name,
    required this.kind,
    required this.owner,
    required this.filePath,
  });

  final int line;
  final String signature;
  final String name;
  final String kind;
  final String? owner;
  final String filePath;

  bool get isPrivate {
    final simpleName = name.split('.').last;
    return simpleName.startsWith('_') || (owner?.startsWith('_') ?? false);
  }

  String get description => _describe(this);
}

String _describe(_Declaration declaration) {
  final name = declaration.name.replaceFirst(RegExp(r'^_+'), '');
  final readableName = _words(name);
  final context = declaration.owner == null
      ? 'هذا الملف'
      : '`${declaration.owner}`';

  if (declaration.kind == 'class') {
    return _typeDescription(declaration.filePath, 'الكلاس', name);
  }
  if (declaration.kind == 'enum') {
    return 'يعرّف القيم الثابتة الخاصة بـ $readableName.';
  }
  if (declaration.kind == 'mixin') {
    return 'يوفّر سلوكًا مشتركًا يمكن دمجه مع أكثر من class.';
  }
  if (declaration.kind.startsWith('extension')) {
    return 'يضيف وظائف مساعدة إلى نوع موجود دون تعديل تعريفه.';
  }
  if (declaration.kind == 'constructor') {
    return 'ينشئ كائنًا من `$name` ويهيّئ الاعتماديات والقيم المطلوبة.';
  }

  const exact = <String, String>{
    'main': 'نقطة بدء التطبيق؛ تهيّئ الخدمات ثم تشغّل واجهة Flutter.',
    'build': 'يبني جزء واجهة Flutter اعتمادًا على الحالة والمدخلات الحالية.',
    'createState': 'ينشئ كائن الحالة المرتبط بالـ StatefulWidget.',
    'initState': 'يهيّئ حالة الـ widget والاشتراكات عند إنشائها.',
    'didChangeDependencies':
        'يحدّث القيم التي تعتمد على BuildContext عند تغيّر الاعتماديات.',
    'didUpdateWidget':
        'يتعامل مع تغيّر إعدادات الـ widget مع الاحتفاظ بالحالة.',
    'dispose': 'يلغي الاشتراكات ويحرّر الموارد عند انتهاء عمر الكائن.',
    'close': 'يغلق الـ Cubit أو الـ streams والموارد التابعة له.',
    'fromJson': 'ينشئ model من استجابة JSON.',
    'toJson': 'يحوّل الكائن إلى JSON صالح للإرسال أو التخزين.',
    'copyWith': 'ينشئ نسخة جديدة مع تغيير القيم المطلوبة فقط.',
    'toString': 'يعيد تمثيلًا نصيًا للكائن.',
    'call': 'ينفّذ الـ use case ويمرّر النتيجة إلى الطبقة المستدعية.',
  };
  if (exact.containsKey(name)) return exact[name]!;

  final lower = name.toLowerCase();
  String action;
  if (lower.startsWith('get') || lower.startsWith('fetch')) {
    action = 'يجلب $readableName من مصدر البيانات المناسب';
  } else if (lower.startsWith('load')) {
    action = 'يحمّل $readableName ويحدّث الحالة المرتبطة';
  } else if (lower.startsWith('search')) {
    action = 'ينفّذ البحث الخاص بـ $readableName';
  } else if (lower.startsWith('create') || lower.startsWith('add')) {
    action = 'ينشئ أو يضيف $readableName';
  } else if (lower.startsWith('update') ||
      lower.startsWith('change') ||
      lower.startsWith('set')) {
    action = 'يحدّث $readableName';
  } else if (lower.startsWith('delete') ||
      lower.startsWith('remove') ||
      lower.startsWith('clear')) {
    action = 'يحذف أو يمسح $readableName';
  } else if (lower.startsWith('refresh') || lower.startsWith('retry')) {
    action = 'يعيد تحميل أو محاولة $readableName';
  } else if (lower.startsWith('login')) {
    action = 'ينفّذ تسجيل الدخول ويتعامل مع نتيجة المصادقة';
  } else if (lower.startsWith('logout')) {
    action = 'ينهي الجلسة الحالية وينظّف بيانات المصادقة';
  } else if (lower.startsWith('register')) {
    action = 'يسجّل $readableName لدى النظام أو الخدمة';
  } else if (lower.startsWith('mark')) {
    action = 'يغيّر علامة أو حالة $readableName';
  } else if (lower.startsWith('select') || lower.startsWith('toggle')) {
    action = 'يغيّر الاختيار الخاص بـ $readableName';
  } else if (lower.startsWith('show') || lower.startsWith('open')) {
    action = 'يعرض أو يفتح $readableName';
  } else if (lower.startsWith('navigate') || lower.startsWith('launch')) {
    action = 'ينفّذ الانتقال أو الفتح الخاص بـ $readableName';
  } else if (lower.startsWith('parse')) {
    action = 'يحلّل $readableName ويحوّله لصيغة قابلة للاستخدام';
  } else if (lower.startsWith('format')) {
    action = 'ينسّق $readableName للعرض أو الإرسال';
  } else if (lower.startsWith('map') || lower.startsWith('to')) {
    action = 'يحوّل $readableName بين طبقات أو صيغ البيانات';
  } else if (lower.startsWith('validate')) {
    action = 'يتحقق من صحة $readableName';
  } else if (lower.startsWith('is') ||
      lower.startsWith('has') ||
      lower.startsWith('can') ||
      lower.startsWith('should')) {
    action = 'يفحص شرط $readableName ويعيد النتيجة';
  } else if (lower.startsWith('handle') || lower.startsWith('on')) {
    action = 'يعالج حدث $readableName';
  } else if (lower.startsWith('submit') || lower.startsWith('send')) {
    action = 'يرسل $readableName إلى الطبقة أو الخدمة المطلوبة';
  } else if (lower.startsWith('cancel')) {
    action = 'يلغي $readableName';
  } else {
    action = 'ينفّذ منطق $readableName';
  }
  return '$action داخل $context.';
}

String _typeDescription(String path, String type, String name) {
  if (path.contains('/presentation/cubit/')) {
    return '$type الذي يدير حالة وتفاعلات ${_words(name)}.';
  }
  if (path.contains('/presentation/pages/') ||
      path.contains('/presentation/screens/')) {
    return '$type الذي يمثل شاشة ${_words(name)}.';
  }
  if (path.contains('/presentation/widgets/') || path.contains('/widgets/')) {
    return '$type الذي يبني مكوّن واجهة قابلًا لإعادة الاستخدام.';
  }
  if (path.contains('/usecase') || path.contains('/use_case')) {
    return '$type الذي يعزل عملية أعمال واحدة: ${_words(name)}.';
  }
  if (path.contains('/repository')) {
    return '$type المسؤول عن عقد أو تنفيذ الوصول إلى بيانات ${_words(name)}.';
  }
  if (path.contains('/data_source') || path.contains('/api/')) {
    return '$type الذي يعرّف الاتصال بمصدر البيانات أو REST API.';
  }
  if (path.contains('/models/') ||
      path.contains('/model/') ||
      path.contains('/dto/') ||
      path.contains('/data/')) {
    return '$type الذي يمثل بيانات ${_words(name)} وينقلها بين الطبقات.';
  }
  if (path.contains('/service')) {
    return '$type الذي يقدّم خدمة ${_words(name)} لباقي التطبيق.';
  }
  return '$type الذي يجمع مسؤوليات ${_words(name)}.';
}

String _words(String value) {
  final withoutGenericSuffix = value.replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ');
  final spaced = withoutGenericSuffix
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .trim()
      .toLowerCase();
  return spaced.isEmpty ? value : '`$spaced`';
}
