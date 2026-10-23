// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DbFoldersTable extends DbFolders
    with TableInfo<$DbFoldersTable, DbFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $DbFoldersTable createAlias(String alias) {
    return $DbFoldersTable(attachedDatabase, alias);
  }
}

class DbFolder extends DataClass implements Insertable<DbFolder> {
  final int id;
  final String name;
  const DbFolder({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  DbFoldersCompanion toCompanion(bool nullToAbsent) {
    return DbFoldersCompanion(id: Value(id), name: Value(name));
  }

  factory DbFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbFolder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  DbFolder copyWith({int? id, String? name}) =>
      DbFolder(id: id ?? this.id, name: name ?? this.name);
  DbFolder copyWithCompanion(DbFoldersCompanion data) {
    return DbFolder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbFolder(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbFolder && other.id == this.id && other.name == this.name);
}

class DbFoldersCompanion extends UpdateCompanion<DbFolder> {
  final Value<int> id;
  final Value<String> name;
  const DbFoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  DbFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<DbFolder> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  DbFoldersCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return DbFoldersCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbFoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $DbDocumentsTable extends DbDocuments
    with TableInfo<$DbDocumentsTable, DbDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalFileNameMeta = const VerificationMeta(
    'originalFileName',
  );
  @override
  late final GeneratedColumn<String> originalFileName = GeneratedColumn<String>(
    'original_file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_folders (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storedPathMeta = const VerificationMeta(
    'storedPath',
  );
  @override
  late final GeneratedColumn<String> storedPath = GeneratedColumn<String>(
    'stored_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    originalFileName,
    format,
    sizeBytes,
    pageCount,
    folderId,
    createdAt,
    updatedAt,
    storedPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('original_file_name')) {
      context.handle(
        _originalFileNameMeta,
        originalFileName.isAcceptableOrUnknown(
          data['original_file_name']!,
          _originalFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalFileNameMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('stored_path')) {
      context.handle(
        _storedPathMeta,
        storedPath.isAcceptableOrUnknown(data['stored_path']!, _storedPathMeta),
      );
    } else if (isInserting) {
      context.missing(_storedPathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      originalFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_file_name'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      storedPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stored_path'],
      )!,
    );
  }

  @override
  $DbDocumentsTable createAlias(String alias) {
    return $DbDocumentsTable(attachedDatabase, alias);
  }
}

class DbDocument extends DataClass implements Insertable<DbDocument> {
  final int id;
  final String title;
  final String originalFileName;

  /// `DocumentFormat.name` of the document (`pdf` / `pptx`).
  final String format;
  final int sizeBytes;

  /// Pages for a PDF, slides for a PPTX.
  final int pageCount;
  final int? folderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String storedPath;
  const DbDocument({
    required this.id,
    required this.title,
    required this.originalFileName,
    required this.format,
    required this.sizeBytes,
    required this.pageCount,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
    required this.storedPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['original_file_name'] = Variable<String>(originalFileName);
    map['format'] = Variable<String>(format);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['page_count'] = Variable<int>(pageCount);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<int>(folderId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['stored_path'] = Variable<String>(storedPath);
    return map;
  }

  DbDocumentsCompanion toCompanion(bool nullToAbsent) {
    return DbDocumentsCompanion(
      id: Value(id),
      title: Value(title),
      originalFileName: Value(originalFileName),
      format: Value(format),
      sizeBytes: Value(sizeBytes),
      pageCount: Value(pageCount),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      storedPath: Value(storedPath),
    );
  }

  factory DbDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDocument(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      originalFileName: serializer.fromJson<String>(json['originalFileName']),
      format: serializer.fromJson<String>(json['format']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      folderId: serializer.fromJson<int?>(json['folderId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      storedPath: serializer.fromJson<String>(json['storedPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'originalFileName': serializer.toJson<String>(originalFileName),
      'format': serializer.toJson<String>(format),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'pageCount': serializer.toJson<int>(pageCount),
      'folderId': serializer.toJson<int?>(folderId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'storedPath': serializer.toJson<String>(storedPath),
    };
  }

  DbDocument copyWith({
    int? id,
    String? title,
    String? originalFileName,
    String? format,
    int? sizeBytes,
    int? pageCount,
    Value<int?> folderId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    String? storedPath,
  }) => DbDocument(
    id: id ?? this.id,
    title: title ?? this.title,
    originalFileName: originalFileName ?? this.originalFileName,
    format: format ?? this.format,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    pageCount: pageCount ?? this.pageCount,
    folderId: folderId.present ? folderId.value : this.folderId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    storedPath: storedPath ?? this.storedPath,
  );
  DbDocument copyWithCompanion(DbDocumentsCompanion data) {
    return DbDocument(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      originalFileName: data.originalFileName.present
          ? data.originalFileName.value
          : this.originalFileName,
      format: data.format.present ? data.format.value : this.format,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      storedPath: data.storedPath.present
          ? data.storedPath.value
          : this.storedPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDocument(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('format: $format, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('pageCount: $pageCount, ')
          ..write('folderId: $folderId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('storedPath: $storedPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    originalFileName,
    format,
    sizeBytes,
    pageCount,
    folderId,
    createdAt,
    updatedAt,
    storedPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDocument &&
          other.id == this.id &&
          other.title == this.title &&
          other.originalFileName == this.originalFileName &&
          other.format == this.format &&
          other.sizeBytes == this.sizeBytes &&
          other.pageCount == this.pageCount &&
          other.folderId == this.folderId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.storedPath == this.storedPath);
}

class DbDocumentsCompanion extends UpdateCompanion<DbDocument> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> originalFileName;
  final Value<String> format;
  final Value<int> sizeBytes;
  final Value<int> pageCount;
  final Value<int?> folderId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> storedPath;
  const DbDocumentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.originalFileName = const Value.absent(),
    this.format = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.folderId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.storedPath = const Value.absent(),
  });
  DbDocumentsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String originalFileName,
    required String format,
    required int sizeBytes,
    required int pageCount,
    this.folderId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required String storedPath,
  }) : title = Value(title),
       originalFileName = Value(originalFileName),
       format = Value(format),
       sizeBytes = Value(sizeBytes),
       pageCount = Value(pageCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       storedPath = Value(storedPath);
  static Insertable<DbDocument> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? originalFileName,
    Expression<String>? format,
    Expression<int>? sizeBytes,
    Expression<int>? pageCount,
    Expression<int>? folderId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? storedPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (originalFileName != null) 'original_file_name': originalFileName,
      if (format != null) 'format': format,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (pageCount != null) 'page_count': pageCount,
      if (folderId != null) 'folder_id': folderId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (storedPath != null) 'stored_path': storedPath,
    });
  }

  DbDocumentsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? originalFileName,
    Value<String>? format,
    Value<int>? sizeBytes,
    Value<int>? pageCount,
    Value<int?>? folderId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? storedPath,
  }) {
    return DbDocumentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      originalFileName: originalFileName ?? this.originalFileName,
      format: format ?? this.format,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      pageCount: pageCount ?? this.pageCount,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      storedPath: storedPath ?? this.storedPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (originalFileName.present) {
      map['original_file_name'] = Variable<String>(originalFileName.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (storedPath.present) {
      map['stored_path'] = Variable<String>(storedPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('format: $format, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('pageCount: $pageCount, ')
          ..write('folderId: $folderId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('storedPath: $storedPath')
          ..write(')'))
        .toString();
  }
}

class $DbExtractedTextsTable extends DbExtractedTexts
    with TableInfo<$DbExtractedTextsTable, DbExtractedText> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbExtractedTextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fullTextMeta = const VerificationMeta(
    'fullText',
  );
  @override
  late final GeneratedColumn<String> fullText = GeneratedColumn<String>(
    'full_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _charCountMeta = const VerificationMeta(
    'charCount',
  );
  @override
  late final GeneratedColumn<int> charCount = GeneratedColumn<int>(
    'char_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [documentId, fullText, charCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_extracted_texts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbExtractedText> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    }
    if (data.containsKey('full_text')) {
      context.handle(
        _fullTextMeta,
        fullText.isAcceptableOrUnknown(data['full_text']!, _fullTextMeta),
      );
    } else if (isInserting) {
      context.missing(_fullTextMeta);
    }
    if (data.containsKey('char_count')) {
      context.handle(
        _charCountMeta,
        charCount.isAcceptableOrUnknown(data['char_count']!, _charCountMeta),
      );
    } else if (isInserting) {
      context.missing(_charCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {documentId};
  @override
  DbExtractedText map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbExtractedText(
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
      fullText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_text'],
      )!,
      charCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}char_count'],
      )!,
    );
  }

  @override
  $DbExtractedTextsTable createAlias(String alias) {
    return $DbExtractedTextsTable(attachedDatabase, alias);
  }
}

class DbExtractedText extends DataClass implements Insertable<DbExtractedText> {
  final int documentId;
  final String fullText;
  final int charCount;
  const DbExtractedText({
    required this.documentId,
    required this.fullText,
    required this.charCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['document_id'] = Variable<int>(documentId);
    map['full_text'] = Variable<String>(fullText);
    map['char_count'] = Variable<int>(charCount);
    return map;
  }

  DbExtractedTextsCompanion toCompanion(bool nullToAbsent) {
    return DbExtractedTextsCompanion(
      documentId: Value(documentId),
      fullText: Value(fullText),
      charCount: Value(charCount),
    );
  }

  factory DbExtractedText.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbExtractedText(
      documentId: serializer.fromJson<int>(json['documentId']),
      fullText: serializer.fromJson<String>(json['fullText']),
      charCount: serializer.fromJson<int>(json['charCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'documentId': serializer.toJson<int>(documentId),
      'fullText': serializer.toJson<String>(fullText),
      'charCount': serializer.toJson<int>(charCount),
    };
  }

  DbExtractedText copyWith({
    int? documentId,
    String? fullText,
    int? charCount,
  }) => DbExtractedText(
    documentId: documentId ?? this.documentId,
    fullText: fullText ?? this.fullText,
    charCount: charCount ?? this.charCount,
  );
  DbExtractedText copyWithCompanion(DbExtractedTextsCompanion data) {
    return DbExtractedText(
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      fullText: data.fullText.present ? data.fullText.value : this.fullText,
      charCount: data.charCount.present ? data.charCount.value : this.charCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbExtractedText(')
          ..write('documentId: $documentId, ')
          ..write('fullText: $fullText, ')
          ..write('charCount: $charCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(documentId, fullText, charCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbExtractedText &&
          other.documentId == this.documentId &&
          other.fullText == this.fullText &&
          other.charCount == this.charCount);
}

class DbExtractedTextsCompanion extends UpdateCompanion<DbExtractedText> {
  final Value<int> documentId;
  final Value<String> fullText;
  final Value<int> charCount;
  const DbExtractedTextsCompanion({
    this.documentId = const Value.absent(),
    this.fullText = const Value.absent(),
    this.charCount = const Value.absent(),
  });
  DbExtractedTextsCompanion.insert({
    this.documentId = const Value.absent(),
    required String fullText,
    required int charCount,
  }) : fullText = Value(fullText),
       charCount = Value(charCount);
  static Insertable<DbExtractedText> custom({
    Expression<int>? documentId,
    Expression<String>? fullText,
    Expression<int>? charCount,
  }) {
    return RawValuesInsertable({
      if (documentId != null) 'document_id': documentId,
      if (fullText != null) 'full_text': fullText,
      if (charCount != null) 'char_count': charCount,
    });
  }

  DbExtractedTextsCompanion copyWith({
    Value<int>? documentId,
    Value<String>? fullText,
    Value<int>? charCount,
  }) {
    return DbExtractedTextsCompanion(
      documentId: documentId ?? this.documentId,
      fullText: fullText ?? this.fullText,
      charCount: charCount ?? this.charCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (fullText.present) {
      map['full_text'] = Variable<String>(fullText.value);
    }
    if (charCount.present) {
      map['char_count'] = Variable<int>(charCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbExtractedTextsCompanion(')
          ..write('documentId: $documentId, ')
          ..write('fullText: $fullText, ')
          ..write('charCount: $charCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DbFoldersTable dbFolders = $DbFoldersTable(this);
  late final $DbDocumentsTable dbDocuments = $DbDocumentsTable(this);
  late final $DbExtractedTextsTable dbExtractedTexts = $DbExtractedTextsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dbFolders,
    dbDocuments,
    dbExtractedTexts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_documents', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_extracted_texts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DbFoldersTableCreateCompanionBuilder =
    DbFoldersCompanion Function({Value<int> id, required String name});
typedef $$DbFoldersTableUpdateCompanionBuilder =
    DbFoldersCompanion Function({Value<int> id, Value<String> name});

final class $$DbFoldersTableReferences
    extends BaseReferences<_$AppDatabase, $DbFoldersTable, DbFolder> {
  $$DbFoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DbDocumentsTable, List<DbDocument>>
  _dbDocumentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dbDocuments,
    aliasName: 'db_folders__id__db_documents__folder_id',
  );

  $$DbDocumentsTableProcessedTableManager get dbDocumentsRefs {
    final manager = $$DbDocumentsTableTableManager(
      $_db,
      $_db.dbDocuments,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbDocumentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $DbFoldersTable> {
  $$DbFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dbDocumentsRefs(
    Expression<bool> Function($$DbDocumentsTableFilterComposer f) f,
  ) {
    final $$DbDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbDocuments,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.dbDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $DbFoldersTable> {
  $$DbFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbFoldersTable> {
  $$DbFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> dbDocumentsRefs<T extends Object>(
    Expression<T> Function($$DbDocumentsTableAnnotationComposer a) f,
  ) {
    final $$DbDocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbDocuments,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbFoldersTable,
          DbFolder,
          $$DbFoldersTableFilterComposer,
          $$DbFoldersTableOrderingComposer,
          $$DbFoldersTableAnnotationComposer,
          $$DbFoldersTableCreateCompanionBuilder,
          $$DbFoldersTableUpdateCompanionBuilder,
          (DbFolder, $$DbFoldersTableReferences),
          DbFolder,
          PrefetchHooks Function({bool dbDocumentsRefs})
        > {
  $$DbFoldersTableTableManager(_$AppDatabase db, $DbFoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => DbFoldersCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  DbFoldersCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbFoldersTable, DbFolder>(table),
                  $$DbFoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dbDocumentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dbDocumentsRefs) db.dbDocuments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dbDocumentsRefs)
                    await $_getPrefetchedData<
                      DbFolder,
                      $DbFoldersTable,
                      DbDocument
                    >(
                      currentTable: table,
                      referencedTable: $$DbFoldersTableReferences
                          ._dbDocumentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DbFoldersTableReferences(
                            db,
                            table,
                            p0,
                          ).dbDocumentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DbFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbFoldersTable,
      DbFolder,
      $$DbFoldersTableFilterComposer,
      $$DbFoldersTableOrderingComposer,
      $$DbFoldersTableAnnotationComposer,
      $$DbFoldersTableCreateCompanionBuilder,
      $$DbFoldersTableUpdateCompanionBuilder,
      (DbFolder, $$DbFoldersTableReferences),
      DbFolder,
      PrefetchHooks Function({bool dbDocumentsRefs})
    >;
typedef $$DbDocumentsTableCreateCompanionBuilder =
    DbDocumentsCompanion Function({
      Value<int> id,
      required String title,
      required String originalFileName,
      required String format,
      required int sizeBytes,
      required int pageCount,
      Value<int?> folderId,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String storedPath,
    });
typedef $$DbDocumentsTableUpdateCompanionBuilder =
    DbDocumentsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> originalFileName,
      Value<String> format,
      Value<int> sizeBytes,
      Value<int> pageCount,
      Value<int?> folderId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> storedPath,
    });

final class $$DbDocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DbDocumentsTable, DbDocument> {
  $$DbDocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbFoldersTable _folderIdTable(_$AppDatabase db) =>
      db.dbFolders.createAlias('db_documents__folder_id__db_folders__id');

  $$DbFoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<int>('folder_id');
    if ($_column == null) return null;
    final manager = $$DbFoldersTableTableManager(
      $_db,
      $_db.dbFolders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DbExtractedTextsTable, List<DbExtractedText>>
  _dbExtractedTextsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dbExtractedTexts,
    aliasName: 'db_documents__id__db_extracted_texts__document_id',
  );

  $$DbExtractedTextsTableProcessedTableManager get dbExtractedTextsRefs {
    final manager = $$DbExtractedTextsTableTableManager(
      $_db,
      $_db.dbExtractedTexts,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dbExtractedTextsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DbDocumentsTable> {
  $$DbDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalFileName => $composableBuilder(
    column: $table.originalFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storedPath => $composableBuilder(
    column: $table.storedPath,
    builder: (column) => ColumnFilters(column),
  );

  $$DbFoldersTableFilterComposer get folderId {
    final $$DbFoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.dbFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbFoldersTableFilterComposer(
            $db: $db,
            $table: $db.dbFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> dbExtractedTextsRefs(
    Expression<bool> Function($$DbExtractedTextsTableFilterComposer f) f,
  ) {
    final $$DbExtractedTextsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbExtractedTexts,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbExtractedTextsTableFilterComposer(
            $db: $db,
            $table: $db.dbExtractedTexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbDocumentsTable> {
  $$DbDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalFileName => $composableBuilder(
    column: $table.originalFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storedPath => $composableBuilder(
    column: $table.storedPath,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbFoldersTableOrderingComposer get folderId {
    final $$DbFoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.dbFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbFoldersTableOrderingComposer(
            $db: $db,
            $table: $db.dbFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbDocumentsTable> {
  $$DbDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get originalFileName => $composableBuilder(
    column: $table.originalFileName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get storedPath => $composableBuilder(
    column: $table.storedPath,
    builder: (column) => column,
  );

  $$DbFoldersTableAnnotationComposer get folderId {
    final $$DbFoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.dbFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbFoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.dbFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> dbExtractedTextsRefs<T extends Object>(
    Expression<T> Function($$DbExtractedTextsTableAnnotationComposer a) f,
  ) {
    final $$DbExtractedTextsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbExtractedTexts,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbExtractedTextsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbExtractedTexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbDocumentsTable,
          DbDocument,
          $$DbDocumentsTableFilterComposer,
          $$DbDocumentsTableOrderingComposer,
          $$DbDocumentsTableAnnotationComposer,
          $$DbDocumentsTableCreateCompanionBuilder,
          $$DbDocumentsTableUpdateCompanionBuilder,
          (DbDocument, $$DbDocumentsTableReferences),
          DbDocument,
          PrefetchHooks Function({bool folderId, bool dbExtractedTextsRefs})
        > {
  $$DbDocumentsTableTableManager(_$AppDatabase db, $DbDocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> originalFileName = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> pageCount = const Value.absent(),
                Value<int?> folderId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> storedPath = const Value.absent(),
              }) => DbDocumentsCompanion(
                id: id,
                title: title,
                originalFileName: originalFileName,
                format: format,
                sizeBytes: sizeBytes,
                pageCount: pageCount,
                folderId: folderId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                storedPath: storedPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String originalFileName,
                required String format,
                required int sizeBytes,
                required int pageCount,
                Value<int?> folderId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                required String storedPath,
              }) => DbDocumentsCompanion.insert(
                id: id,
                title: title,
                originalFileName: originalFileName,
                format: format,
                sizeBytes: sizeBytes,
                pageCount: pageCount,
                folderId: folderId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                storedPath: storedPath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbDocumentsTable, DbDocument>(table),
                  $$DbDocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({folderId = false, dbExtractedTextsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dbExtractedTextsRefs) db.dbExtractedTexts,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (folderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.folderId,
                                    referencedTable:
                                        $$DbDocumentsTableReferences
                                            ._folderIdTable(db),
                                    referencedColumn:
                                        $$DbDocumentsTableReferences
                                            ._folderIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dbExtractedTextsRefs)
                        await $_getPrefetchedData<
                          DbDocument,
                          $DbDocumentsTable,
                          DbExtractedText
                        >(
                          currentTable: table,
                          referencedTable: $$DbDocumentsTableReferences
                              ._dbExtractedTextsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbDocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).dbExtractedTextsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.documentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DbDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbDocumentsTable,
      DbDocument,
      $$DbDocumentsTableFilterComposer,
      $$DbDocumentsTableOrderingComposer,
      $$DbDocumentsTableAnnotationComposer,
      $$DbDocumentsTableCreateCompanionBuilder,
      $$DbDocumentsTableUpdateCompanionBuilder,
      (DbDocument, $$DbDocumentsTableReferences),
      DbDocument,
      PrefetchHooks Function({bool folderId, bool dbExtractedTextsRefs})
    >;
typedef $$DbExtractedTextsTableCreateCompanionBuilder =
    DbExtractedTextsCompanion Function({
      Value<int> documentId,
      required String fullText,
      required int charCount,
    });
typedef $$DbExtractedTextsTableUpdateCompanionBuilder =
    DbExtractedTextsCompanion Function({
      Value<int> documentId,
      Value<String> fullText,
      Value<int> charCount,
    });

final class $$DbExtractedTextsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DbExtractedTextsTable, DbExtractedText> {
  $$DbExtractedTextsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DbDocumentsTable _documentIdTable(_$AppDatabase db) => db.dbDocuments
      .createAlias('db_extracted_texts__document_id__db_documents__id');

  $$DbDocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<int>('document_id')!;

    final manager = $$DbDocumentsTableTableManager(
      $_db,
      $_db.dbDocuments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbExtractedTextsTableFilterComposer
    extends Composer<_$AppDatabase, $DbExtractedTextsTable> {
  $$DbExtractedTextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fullText => $composableBuilder(
    column: $table.fullText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charCount => $composableBuilder(
    column: $table.charCount,
    builder: (column) => ColumnFilters(column),
  );

  $$DbDocumentsTableFilterComposer get documentId {
    final $$DbDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.dbDocuments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.dbDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbExtractedTextsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbExtractedTextsTable> {
  $$DbExtractedTextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fullText => $composableBuilder(
    column: $table.fullText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charCount => $composableBuilder(
    column: $table.charCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbDocumentsTableOrderingComposer get documentId {
    final $$DbDocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.dbDocuments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.dbDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbExtractedTextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbExtractedTextsTable> {
  $$DbExtractedTextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fullText =>
      $composableBuilder(column: $table.fullText, builder: (column) => column);

  GeneratedColumn<int> get charCount =>
      $composableBuilder(column: $table.charCount, builder: (column) => column);

  $$DbDocumentsTableAnnotationComposer get documentId {
    final $$DbDocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.dbDocuments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbExtractedTextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbExtractedTextsTable,
          DbExtractedText,
          $$DbExtractedTextsTableFilterComposer,
          $$DbExtractedTextsTableOrderingComposer,
          $$DbExtractedTextsTableAnnotationComposer,
          $$DbExtractedTextsTableCreateCompanionBuilder,
          $$DbExtractedTextsTableUpdateCompanionBuilder,
          (DbExtractedText, $$DbExtractedTextsTableReferences),
          DbExtractedText,
          PrefetchHooks Function({bool documentId})
        > {
  $$DbExtractedTextsTableTableManager(
    _$AppDatabase db,
    $DbExtractedTextsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbExtractedTextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbExtractedTextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbExtractedTextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> documentId = const Value.absent(),
                Value<String> fullText = const Value.absent(),
                Value<int> charCount = const Value.absent(),
              }) => DbExtractedTextsCompanion(
                documentId: documentId,
                fullText: fullText,
                charCount: charCount,
              ),
          createCompanionCallback:
              ({
                Value<int> documentId = const Value.absent(),
                required String fullText,
                required int charCount,
              }) => DbExtractedTextsCompanion.insert(
                documentId: documentId,
                fullText: fullText,
                charCount: charCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbExtractedTextsTable, DbExtractedText>(table),
                  $$DbExtractedTextsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (documentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.documentId,
                                referencedTable:
                                    $$DbExtractedTextsTableReferences
                                        ._documentIdTable(db),
                                referencedColumn:
                                    $$DbExtractedTextsTableReferences
                                        ._documentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DbExtractedTextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbExtractedTextsTable,
      DbExtractedText,
      $$DbExtractedTextsTableFilterComposer,
      $$DbExtractedTextsTableOrderingComposer,
      $$DbExtractedTextsTableAnnotationComposer,
      $$DbExtractedTextsTableCreateCompanionBuilder,
      $$DbExtractedTextsTableUpdateCompanionBuilder,
      (DbExtractedText, $$DbExtractedTextsTableReferences),
      DbExtractedText,
      PrefetchHooks Function({bool documentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DbFoldersTableTableManager get dbFolders =>
      $$DbFoldersTableTableManager(_db, _db.dbFolders);
  $$DbDocumentsTableTableManager get dbDocuments =>
      $$DbDocumentsTableTableManager(_db, _db.dbDocuments);
  $$DbExtractedTextsTableTableManager get dbExtractedTexts =>
      $$DbExtractedTextsTableTableManager(_db, _db.dbExtractedTexts);
}
