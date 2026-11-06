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

class $DbSubjectsTable extends DbSubjects
    with TableInfo<$DbSubjectsTable, DbSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbSubjectsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSubject> instance, {
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSubject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DbSubjectsTable createAlias(String alias) {
    return $DbSubjectsTable(attachedDatabase, alias);
  }
}

class DbSubject extends DataClass implements Insertable<DbSubject> {
  final int id;
  final String name;
  final DateTime createdAt;
  const DbSubject({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DbSubjectsCompanion toCompanion(bool nullToAbsent) {
    return DbSubjectsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory DbSubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSubject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbSubject copyWith({int? id, String? name, DateTime? createdAt}) => DbSubject(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  DbSubject copyWithCompanion(DbSubjectsCompanion data) {
    return DbSubject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSubject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSubject &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class DbSubjectsCompanion extends UpdateCompanion<DbSubject> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const DbSubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DbSubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<DbSubject> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DbSubjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return DbSubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
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
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_subjects (id) ON DELETE SET NULL',
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
    subjectId,
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
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
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
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
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
  final int? subjectId;
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
    this.subjectId,
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
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<int>(subjectId);
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
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
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
      subjectId: serializer.fromJson<int?>(json['subjectId']),
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
      'subjectId': serializer.toJson<int?>(subjectId),
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
    Value<int?> subjectId = const Value.absent(),
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
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
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
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
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
          ..write('subjectId: $subjectId, ')
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
    subjectId,
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
          other.subjectId == this.subjectId &&
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
  final Value<int?> subjectId;
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
    this.subjectId = const Value.absent(),
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
    this.subjectId = const Value.absent(),
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
    Expression<int>? subjectId,
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
      if (subjectId != null) 'subject_id': subjectId,
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
    Value<int?>? subjectId,
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
      subjectId: subjectId ?? this.subjectId,
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
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
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
          ..write('subjectId: $subjectId, ')
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

class $DbSettingsTable extends DbSettings
    with TableInfo<$DbSettingsTable, DbSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DbSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $DbSettingsTable createAlias(String alias) {
    return $DbSettingsTable(attachedDatabase, alias);
  }
}

class DbSetting extends DataClass implements Insertable<DbSetting> {
  final String key;
  final String value;
  const DbSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  DbSettingsCompanion toCompanion(bool nullToAbsent) {
    return DbSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory DbSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  DbSetting copyWith({String? key, String? value}) =>
      DbSetting(key: key ?? this.key, value: value ?? this.value);
  DbSetting copyWithCompanion(DbSettingsCompanion data) {
    return DbSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class DbSettingsCompanion extends UpdateCompanion<DbSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const DbSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<DbSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return DbSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbDecksTable extends DbDecks with TableInfo<$DbDecksTable, DbDeck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbDecksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_documents (id) ON DELETE CASCADE',
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
  static const VerificationMeta _materialTypeMeta = const VerificationMeta(
    'materialType',
  );
  @override
  late final GeneratedColumn<String> materialType = GeneratedColumn<String>(
    'material_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalItemsMeta = const VerificationMeta(
    'totalItems',
  );
  @override
  late final GeneratedColumn<int> totalItems = GeneratedColumn<int>(
    'total_items',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    title,
    materialType,
    totalItems,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbDeck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('material_type')) {
      context.handle(
        _materialTypeMeta,
        materialType.isAcceptableOrUnknown(
          data['material_type']!,
          _materialTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_materialTypeMeta);
    }
    if (data.containsKey('total_items')) {
      context.handle(
        _totalItemsMeta,
        totalItems.isAcceptableOrUnknown(data['total_items']!, _totalItemsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalItemsMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbDeck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDeck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      materialType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_type'],
      )!,
      totalItems: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_items'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DbDecksTable createAlias(String alias) {
    return $DbDecksTable(attachedDatabase, alias);
  }
}

class DbDeck extends DataClass implements Insertable<DbDeck> {
  final int id;
  final int documentId;
  final String title;

  /// `GenerationMaterialType.name` (`flashcards`, `mcqs`,
  /// `trueFalse`, `shortAnswers`, `summaries`).
  final String materialType;
  final int totalItems;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DbDeck({
    required this.id,
    required this.documentId,
    required this.title,
    required this.materialType,
    required this.totalItems,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<int>(documentId);
    map['title'] = Variable<String>(title);
    map['material_type'] = Variable<String>(materialType);
    map['total_items'] = Variable<int>(totalItems);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DbDecksCompanion toCompanion(bool nullToAbsent) {
    return DbDecksCompanion(
      id: Value(id),
      documentId: Value(documentId),
      title: Value(title),
      materialType: Value(materialType),
      totalItems: Value(totalItems),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DbDeck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDeck(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<int>(json['documentId']),
      title: serializer.fromJson<String>(json['title']),
      materialType: serializer.fromJson<String>(json['materialType']),
      totalItems: serializer.fromJson<int>(json['totalItems']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<int>(documentId),
      'title': serializer.toJson<String>(title),
      'materialType': serializer.toJson<String>(materialType),
      'totalItems': serializer.toJson<int>(totalItems),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DbDeck copyWith({
    int? id,
    int? documentId,
    String? title,
    String? materialType,
    int? totalItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DbDeck(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    title: title ?? this.title,
    materialType: materialType ?? this.materialType,
    totalItems: totalItems ?? this.totalItems,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DbDeck copyWithCompanion(DbDecksCompanion data) {
    return DbDeck(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      title: data.title.present ? data.title.value : this.title,
      materialType: data.materialType.present
          ? data.materialType.value
          : this.materialType,
      totalItems: data.totalItems.present
          ? data.totalItems.value
          : this.totalItems,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDeck(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('title: $title, ')
          ..write('materialType: $materialType, ')
          ..write('totalItems: $totalItems, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    title,
    materialType,
    totalItems,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDeck &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.title == this.title &&
          other.materialType == this.materialType &&
          other.totalItems == this.totalItems &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DbDecksCompanion extends UpdateCompanion<DbDeck> {
  final Value<int> id;
  final Value<int> documentId;
  final Value<String> title;
  final Value<String> materialType;
  final Value<int> totalItems;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DbDecksCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.title = const Value.absent(),
    this.materialType = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DbDecksCompanion.insert({
    this.id = const Value.absent(),
    required int documentId,
    required String title,
    required String materialType,
    required int totalItems,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : documentId = Value(documentId),
       title = Value(title),
       materialType = Value(materialType),
       totalItems = Value(totalItems),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DbDeck> custom({
    Expression<int>? id,
    Expression<int>? documentId,
    Expression<String>? title,
    Expression<String>? materialType,
    Expression<int>? totalItems,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (title != null) 'title': title,
      if (materialType != null) 'material_type': materialType,
      if (totalItems != null) 'total_items': totalItems,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DbDecksCompanion copyWith({
    Value<int>? id,
    Value<int>? documentId,
    Value<String>? title,
    Value<String>? materialType,
    Value<int>? totalItems,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DbDecksCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      materialType: materialType ?? this.materialType,
      totalItems: totalItems ?? this.totalItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (materialType.present) {
      map['material_type'] = Variable<String>(materialType.value);
    }
    if (totalItems.present) {
      map['total_items'] = Variable<int>(totalItems.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbDecksCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('title: $title, ')
          ..write('materialType: $materialType, ')
          ..write('totalItems: $totalItems, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DbFlashcardsTable extends DbFlashcards
    with TableInfo<$DbFlashcardsTable, DbFlashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbFlashcardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_decks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
    'front',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
    'back',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    front,
    back,
    explanation,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_flashcards';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbFlashcard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('front')) {
      context.handle(
        _frontMeta,
        front.isAcceptableOrUnknown(data['front']!, _frontMeta),
      );
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
        _backMeta,
        back.isAcceptableOrUnknown(data['back']!, _backMeta),
      );
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbFlashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbFlashcard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      front: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}front'],
      )!,
      back: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}back'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $DbFlashcardsTable createAlias(String alias) {
    return $DbFlashcardsTable(attachedDatabase, alias);
  }
}

class DbFlashcard extends DataClass implements Insertable<DbFlashcard> {
  final int id;
  final int deckId;
  final String front;
  final String back;
  final String? explanation;
  final int sortOrder;
  const DbFlashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.explanation,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<int>(deckId);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  DbFlashcardsCompanion toCompanion(bool nullToAbsent) {
    return DbFlashcardsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      front: Value(front),
      back: Value(back),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      sortOrder: Value(sortOrder),
    );
  }

  factory DbFlashcard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbFlashcard(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int>(json['deckId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<int>(deckId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'explanation': serializer.toJson<String?>(explanation),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DbFlashcard copyWith({
    int? id,
    int? deckId,
    String? front,
    String? back,
    Value<String?> explanation = const Value.absent(),
    int? sortOrder,
  }) => DbFlashcard(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    front: front ?? this.front,
    back: back ?? this.back,
    explanation: explanation.present ? explanation.value : this.explanation,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  DbFlashcard copyWithCompanion(DbFlashcardsCompanion data) {
    return DbFlashcard(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbFlashcard(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('explanation: $explanation, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deckId, front, back, explanation, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbFlashcard &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.front == this.front &&
          other.back == this.back &&
          other.explanation == this.explanation &&
          other.sortOrder == this.sortOrder);
}

class DbFlashcardsCompanion extends UpdateCompanion<DbFlashcard> {
  final Value<int> id;
  final Value<int> deckId;
  final Value<String> front;
  final Value<String> back;
  final Value<String?> explanation;
  final Value<int> sortOrder;
  const DbFlashcardsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.explanation = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  DbFlashcardsCompanion.insert({
    this.id = const Value.absent(),
    required int deckId,
    required String front,
    required String back,
    this.explanation = const Value.absent(),
    required int sortOrder,
  }) : deckId = Value(deckId),
       front = Value(front),
       back = Value(back),
       sortOrder = Value(sortOrder);
  static Insertable<DbFlashcard> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? explanation,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (explanation != null) 'explanation': explanation,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  DbFlashcardsCompanion copyWith({
    Value<int>? id,
    Value<int>? deckId,
    Value<String>? front,
    Value<String>? back,
    Value<String?>? explanation,
    Value<int>? sortOrder,
  }) {
    return DbFlashcardsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      explanation: explanation ?? this.explanation,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbFlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('explanation: $explanation, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $DbQuizQuestionsTable extends DbQuizQuestions
    with TableInfo<$DbQuizQuestionsTable, DbQuizQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbQuizQuestionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_decks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsJsonMeta = const VerificationMeta(
    'optionsJson',
  );
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
    'options_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctIndexMeta = const VerificationMeta(
    'correctIndex',
  );
  @override
  late final GeneratedColumn<int> correctIndex = GeneratedColumn<int>(
    'correct_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedAnswerMeta = const VerificationMeta(
    'expectedAnswer',
  );
  @override
  late final GeneratedColumn<String> expectedAnswer = GeneratedColumn<String>(
    'expected_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    prompt,
    type,
    optionsJson,
    correctIndex,
    expectedAnswer,
    explanation,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_quiz_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbQuizQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
        _optionsJsonMeta,
        optionsJson.isAcceptableOrUnknown(
          data['options_json']!,
          _optionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_optionsJsonMeta);
    }
    if (data.containsKey('correct_index')) {
      context.handle(
        _correctIndexMeta,
        correctIndex.isAcceptableOrUnknown(
          data['correct_index']!,
          _correctIndexMeta,
        ),
      );
    }
    if (data.containsKey('expected_answer')) {
      context.handle(
        _expectedAnswerMeta,
        expectedAnswer.isAcceptableOrUnknown(
          data['expected_answer']!,
          _expectedAnswerMeta,
        ),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbQuizQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbQuizQuestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      optionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options_json'],
      )!,
      correctIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_index'],
      ),
      expectedAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_answer'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $DbQuizQuestionsTable createAlias(String alias) {
    return $DbQuizQuestionsTable(attachedDatabase, alias);
  }
}

class DbQuizQuestion extends DataClass implements Insertable<DbQuizQuestion> {
  final int id;
  final int deckId;
  final String prompt;

  /// `QuizQuestionType.name` (`mcq`, `trueFalse`, `shortAnswer`).
  final String type;
  final String optionsJson;
  final int? correctIndex;
  final String? expectedAnswer;
  final String? explanation;
  final int sortOrder;
  const DbQuizQuestion({
    required this.id,
    required this.deckId,
    required this.prompt,
    required this.type,
    required this.optionsJson,
    this.correctIndex,
    this.expectedAnswer,
    this.explanation,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<int>(deckId);
    map['prompt'] = Variable<String>(prompt);
    map['type'] = Variable<String>(type);
    map['options_json'] = Variable<String>(optionsJson);
    if (!nullToAbsent || correctIndex != null) {
      map['correct_index'] = Variable<int>(correctIndex);
    }
    if (!nullToAbsent || expectedAnswer != null) {
      map['expected_answer'] = Variable<String>(expectedAnswer);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  DbQuizQuestionsCompanion toCompanion(bool nullToAbsent) {
    return DbQuizQuestionsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      prompt: Value(prompt),
      type: Value(type),
      optionsJson: Value(optionsJson),
      correctIndex: correctIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(correctIndex),
      expectedAnswer: expectedAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedAnswer),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      sortOrder: Value(sortOrder),
    );
  }

  factory DbQuizQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbQuizQuestion(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int>(json['deckId']),
      prompt: serializer.fromJson<String>(json['prompt']),
      type: serializer.fromJson<String>(json['type']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      correctIndex: serializer.fromJson<int?>(json['correctIndex']),
      expectedAnswer: serializer.fromJson<String?>(json['expectedAnswer']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<int>(deckId),
      'prompt': serializer.toJson<String>(prompt),
      'type': serializer.toJson<String>(type),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'correctIndex': serializer.toJson<int?>(correctIndex),
      'expectedAnswer': serializer.toJson<String?>(expectedAnswer),
      'explanation': serializer.toJson<String?>(explanation),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DbQuizQuestion copyWith({
    int? id,
    int? deckId,
    String? prompt,
    String? type,
    String? optionsJson,
    Value<int?> correctIndex = const Value.absent(),
    Value<String?> expectedAnswer = const Value.absent(),
    Value<String?> explanation = const Value.absent(),
    int? sortOrder,
  }) => DbQuizQuestion(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    prompt: prompt ?? this.prompt,
    type: type ?? this.type,
    optionsJson: optionsJson ?? this.optionsJson,
    correctIndex: correctIndex.present ? correctIndex.value : this.correctIndex,
    expectedAnswer: expectedAnswer.present
        ? expectedAnswer.value
        : this.expectedAnswer,
    explanation: explanation.present ? explanation.value : this.explanation,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  DbQuizQuestion copyWithCompanion(DbQuizQuestionsCompanion data) {
    return DbQuizQuestion(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      type: data.type.present ? data.type.value : this.type,
      optionsJson: data.optionsJson.present
          ? data.optionsJson.value
          : this.optionsJson,
      correctIndex: data.correctIndex.present
          ? data.correctIndex.value
          : this.correctIndex,
      expectedAnswer: data.expectedAnswer.present
          ? data.expectedAnswer.value
          : this.expectedAnswer,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbQuizQuestion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('prompt: $prompt, ')
          ..write('type: $type, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctIndex: $correctIndex, ')
          ..write('expectedAnswer: $expectedAnswer, ')
          ..write('explanation: $explanation, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    prompt,
    type,
    optionsJson,
    correctIndex,
    expectedAnswer,
    explanation,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbQuizQuestion &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.prompt == this.prompt &&
          other.type == this.type &&
          other.optionsJson == this.optionsJson &&
          other.correctIndex == this.correctIndex &&
          other.expectedAnswer == this.expectedAnswer &&
          other.explanation == this.explanation &&
          other.sortOrder == this.sortOrder);
}

class DbQuizQuestionsCompanion extends UpdateCompanion<DbQuizQuestion> {
  final Value<int> id;
  final Value<int> deckId;
  final Value<String> prompt;
  final Value<String> type;
  final Value<String> optionsJson;
  final Value<int?> correctIndex;
  final Value<String?> expectedAnswer;
  final Value<String?> explanation;
  final Value<int> sortOrder;
  const DbQuizQuestionsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.prompt = const Value.absent(),
    this.type = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.correctIndex = const Value.absent(),
    this.expectedAnswer = const Value.absent(),
    this.explanation = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  DbQuizQuestionsCompanion.insert({
    this.id = const Value.absent(),
    required int deckId,
    required String prompt,
    required String type,
    required String optionsJson,
    this.correctIndex = const Value.absent(),
    this.expectedAnswer = const Value.absent(),
    this.explanation = const Value.absent(),
    required int sortOrder,
  }) : deckId = Value(deckId),
       prompt = Value(prompt),
       type = Value(type),
       optionsJson = Value(optionsJson),
       sortOrder = Value(sortOrder);
  static Insertable<DbQuizQuestion> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<String>? prompt,
    Expression<String>? type,
    Expression<String>? optionsJson,
    Expression<int>? correctIndex,
    Expression<String>? expectedAnswer,
    Expression<String>? explanation,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (prompt != null) 'prompt': prompt,
      if (type != null) 'type': type,
      if (optionsJson != null) 'options_json': optionsJson,
      if (correctIndex != null) 'correct_index': correctIndex,
      if (expectedAnswer != null) 'expected_answer': expectedAnswer,
      if (explanation != null) 'explanation': explanation,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  DbQuizQuestionsCompanion copyWith({
    Value<int>? id,
    Value<int>? deckId,
    Value<String>? prompt,
    Value<String>? type,
    Value<String>? optionsJson,
    Value<int?>? correctIndex,
    Value<String?>? expectedAnswer,
    Value<String?>? explanation,
    Value<int>? sortOrder,
  }) {
    return DbQuizQuestionsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      prompt: prompt ?? this.prompt,
      type: type ?? this.type,
      optionsJson: optionsJson ?? this.optionsJson,
      correctIndex: correctIndex ?? this.correctIndex,
      expectedAnswer: expectedAnswer ?? this.expectedAnswer,
      explanation: explanation ?? this.explanation,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (correctIndex.present) {
      map['correct_index'] = Variable<int>(correctIndex.value);
    }
    if (expectedAnswer.present) {
      map['expected_answer'] = Variable<String>(expectedAnswer.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbQuizQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('prompt: $prompt, ')
          ..write('type: $type, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctIndex: $correctIndex, ')
          ..write('expectedAnswer: $expectedAnswer, ')
          ..write('explanation: $explanation, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $DbQuizAttemptsTable extends DbQuizAttempts
    with TableInfo<$DbQuizAttemptsTable, DbQuizAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbQuizAttemptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_decks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    startedAt,
    completedAt,
    score,
    totalQuestions,
    currentIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_quiz_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbQuizAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbQuizAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbQuizAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
    );
  }

  @override
  $DbQuizAttemptsTable createAlias(String alias) {
    return $DbQuizAttemptsTable(attachedDatabase, alias);
  }
}

class DbQuizAttempt extends DataClass implements Insertable<DbQuizAttempt> {
  final int id;
  final int deckId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? score;
  final int totalQuestions;
  final int currentIndex;
  const DbQuizAttempt({
    required this.id,
    required this.deckId,
    required this.startedAt,
    this.completedAt,
    this.score,
    required this.totalQuestions,
    required this.currentIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<int>(deckId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    map['total_questions'] = Variable<int>(totalQuestions);
    map['current_index'] = Variable<int>(currentIndex);
    return map;
  }

  DbQuizAttemptsCompanion toCompanion(bool nullToAbsent) {
    return DbQuizAttemptsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      totalQuestions: Value(totalQuestions),
      currentIndex: Value(currentIndex),
    );
  }

  factory DbQuizAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbQuizAttempt(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int>(json['deckId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      score: serializer.fromJson<int?>(json['score']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<int>(deckId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'score': serializer.toJson<int?>(score),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'currentIndex': serializer.toJson<int>(currentIndex),
    };
  }

  DbQuizAttempt copyWith({
    int? id,
    int? deckId,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> score = const Value.absent(),
    int? totalQuestions,
    int? currentIndex,
  }) => DbQuizAttempt(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    score: score.present ? score.value : this.score,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    currentIndex: currentIndex ?? this.currentIndex,
  );
  DbQuizAttempt copyWithCompanion(DbQuizAttemptsCompanion data) {
    return DbQuizAttempt(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      score: data.score.present ? data.score.value : this.score,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbQuizAttempt(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('score: $score, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('currentIndex: $currentIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    startedAt,
    completedAt,
    score,
    totalQuestions,
    currentIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbQuizAttempt &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.score == this.score &&
          other.totalQuestions == this.totalQuestions &&
          other.currentIndex == this.currentIndex);
}

class DbQuizAttemptsCompanion extends UpdateCompanion<DbQuizAttempt> {
  final Value<int> id;
  final Value<int> deckId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int?> score;
  final Value<int> totalQuestions;
  final Value<int> currentIndex;
  const DbQuizAttemptsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.currentIndex = const Value.absent(),
  });
  DbQuizAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int deckId,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.score = const Value.absent(),
    required int totalQuestions,
    this.currentIndex = const Value.absent(),
  }) : deckId = Value(deckId),
       startedAt = Value(startedAt),
       totalQuestions = Value(totalQuestions);
  static Insertable<DbQuizAttempt> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? score,
    Expression<int>? totalQuestions,
    Expression<int>? currentIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (score != null) 'score': score,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (currentIndex != null) 'current_index': currentIndex,
    });
  }

  DbQuizAttemptsCompanion copyWith({
    Value<int>? id,
    Value<int>? deckId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int?>? score,
    Value<int>? totalQuestions,
    Value<int>? currentIndex,
  }) {
    return DbQuizAttemptsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbQuizAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('score: $score, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('currentIndex: $currentIndex')
          ..write(')'))
        .toString();
  }
}

class $DbQuestionAnswersTable extends DbQuestionAnswers
    with TableInfo<$DbQuestionAnswersTable, DbQuestionAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbQuestionAnswersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<int> attemptId = GeneratedColumn<int>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_quiz_attempts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_quiz_questions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _selectedIndexMeta = const VerificationMeta(
    'selectedIndex',
  );
  @override
  late final GeneratedColumn<int> selectedIndex = GeneratedColumn<int>(
    'selected_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answerTextMeta = const VerificationMeta(
    'answerText',
  );
  @override
  late final GeneratedColumn<String> answerText = GeneratedColumn<String>(
    'answer_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attemptId,
    questionId,
    selectedIndex,
    answerText,
    isCorrect,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_question_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbQuestionAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('selected_index')) {
      context.handle(
        _selectedIndexMeta,
        selectedIndex.isAcceptableOrUnknown(
          data['selected_index']!,
          _selectedIndexMeta,
        ),
      );
    }
    if (data.containsKey('answer_text')) {
      context.handle(
        _answerTextMeta,
        answerText.isAcceptableOrUnknown(data['answer_text']!, _answerTextMeta),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbQuestionAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbQuestionAnswer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      selectedIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_index'],
      ),
      answerText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_text'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      ),
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $DbQuestionAnswersTable createAlias(String alias) {
    return $DbQuestionAnswersTable(attachedDatabase, alias);
  }
}

class DbQuestionAnswer extends DataClass
    implements Insertable<DbQuestionAnswer> {
  final int id;
  final int attemptId;
  final int questionId;
  final int? selectedIndex;
  final String? answerText;
  final bool? isCorrect;
  final DateTime answeredAt;
  const DbQuestionAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    this.selectedIndex,
    this.answerText,
    this.isCorrect,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attempt_id'] = Variable<int>(attemptId);
    map['question_id'] = Variable<int>(questionId);
    if (!nullToAbsent || selectedIndex != null) {
      map['selected_index'] = Variable<int>(selectedIndex);
    }
    if (!nullToAbsent || answerText != null) {
      map['answer_text'] = Variable<String>(answerText);
    }
    if (!nullToAbsent || isCorrect != null) {
      map['is_correct'] = Variable<bool>(isCorrect);
    }
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  DbQuestionAnswersCompanion toCompanion(bool nullToAbsent) {
    return DbQuestionAnswersCompanion(
      id: Value(id),
      attemptId: Value(attemptId),
      questionId: Value(questionId),
      selectedIndex: selectedIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedIndex),
      answerText: answerText == null && nullToAbsent
          ? const Value.absent()
          : Value(answerText),
      isCorrect: isCorrect == null && nullToAbsent
          ? const Value.absent()
          : Value(isCorrect),
      answeredAt: Value(answeredAt),
    );
  }

  factory DbQuestionAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbQuestionAnswer(
      id: serializer.fromJson<int>(json['id']),
      attemptId: serializer.fromJson<int>(json['attemptId']),
      questionId: serializer.fromJson<int>(json['questionId']),
      selectedIndex: serializer.fromJson<int?>(json['selectedIndex']),
      answerText: serializer.fromJson<String?>(json['answerText']),
      isCorrect: serializer.fromJson<bool?>(json['isCorrect']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attemptId': serializer.toJson<int>(attemptId),
      'questionId': serializer.toJson<int>(questionId),
      'selectedIndex': serializer.toJson<int?>(selectedIndex),
      'answerText': serializer.toJson<String?>(answerText),
      'isCorrect': serializer.toJson<bool?>(isCorrect),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  DbQuestionAnswer copyWith({
    int? id,
    int? attemptId,
    int? questionId,
    Value<int?> selectedIndex = const Value.absent(),
    Value<String?> answerText = const Value.absent(),
    Value<bool?> isCorrect = const Value.absent(),
    DateTime? answeredAt,
  }) => DbQuestionAnswer(
    id: id ?? this.id,
    attemptId: attemptId ?? this.attemptId,
    questionId: questionId ?? this.questionId,
    selectedIndex: selectedIndex.present
        ? selectedIndex.value
        : this.selectedIndex,
    answerText: answerText.present ? answerText.value : this.answerText,
    isCorrect: isCorrect.present ? isCorrect.value : this.isCorrect,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  DbQuestionAnswer copyWithCompanion(DbQuestionAnswersCompanion data) {
    return DbQuestionAnswer(
      id: data.id.present ? data.id.value : this.id,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      selectedIndex: data.selectedIndex.present
          ? data.selectedIndex.value
          : this.selectedIndex,
      answerText: data.answerText.present
          ? data.answerText.value
          : this.answerText,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbQuestionAnswer(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('answerText: $answerText, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    attemptId,
    questionId,
    selectedIndex,
    answerText,
    isCorrect,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbQuestionAnswer &&
          other.id == this.id &&
          other.attemptId == this.attemptId &&
          other.questionId == this.questionId &&
          other.selectedIndex == this.selectedIndex &&
          other.answerText == this.answerText &&
          other.isCorrect == this.isCorrect &&
          other.answeredAt == this.answeredAt);
}

class DbQuestionAnswersCompanion extends UpdateCompanion<DbQuestionAnswer> {
  final Value<int> id;
  final Value<int> attemptId;
  final Value<int> questionId;
  final Value<int?> selectedIndex;
  final Value<String?> answerText;
  final Value<bool?> isCorrect;
  final Value<DateTime> answeredAt;
  const DbQuestionAnswersCompanion({
    this.id = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.selectedIndex = const Value.absent(),
    this.answerText = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  DbQuestionAnswersCompanion.insert({
    this.id = const Value.absent(),
    required int attemptId,
    required int questionId,
    this.selectedIndex = const Value.absent(),
    this.answerText = const Value.absent(),
    this.isCorrect = const Value.absent(),
    required DateTime answeredAt,
  }) : attemptId = Value(attemptId),
       questionId = Value(questionId),
       answeredAt = Value(answeredAt);
  static Insertable<DbQuestionAnswer> custom({
    Expression<int>? id,
    Expression<int>? attemptId,
    Expression<int>? questionId,
    Expression<int>? selectedIndex,
    Expression<String>? answerText,
    Expression<bool>? isCorrect,
    Expression<DateTime>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attemptId != null) 'attempt_id': attemptId,
      if (questionId != null) 'question_id': questionId,
      if (selectedIndex != null) 'selected_index': selectedIndex,
      if (answerText != null) 'answer_text': answerText,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  DbQuestionAnswersCompanion copyWith({
    Value<int>? id,
    Value<int>? attemptId,
    Value<int>? questionId,
    Value<int?>? selectedIndex,
    Value<String?>? answerText,
    Value<bool?>? isCorrect,
    Value<DateTime>? answeredAt,
  }) {
    return DbQuestionAnswersCompanion(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      answerText: answerText ?? this.answerText,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<int>(attemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (selectedIndex.present) {
      map['selected_index'] = Variable<int>(selectedIndex.value);
    }
    if (answerText.present) {
      map['answer_text'] = Variable<String>(answerText.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbQuestionAnswersCompanion(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('answerText: $answerText, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $DbCardReviewsTable extends DbCardReviews
    with TableInfo<$DbCardReviewsTable, DbCardReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbCardReviewsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_flashcards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cardId, rating, reviewedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_card_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbCardReview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbCardReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbCardReview(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
    );
  }

  @override
  $DbCardReviewsTable createAlias(String alias) {
    return $DbCardReviewsTable(attachedDatabase, alias);
  }
}

class DbCardReview extends DataClass implements Insertable<DbCardReview> {
  final int id;
  final int cardId;
  final String rating;
  final DateTime reviewedAt;
  const DbCardReview({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['rating'] = Variable<String>(rating);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    return map;
  }

  DbCardReviewsCompanion toCompanion(bool nullToAbsent) {
    return DbCardReviewsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      rating: Value(rating),
      reviewedAt: Value(reviewedAt),
    );
  }

  factory DbCardReview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbCardReview(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      rating: serializer.fromJson<String>(json['rating']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'rating': serializer.toJson<String>(rating),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
    };
  }

  DbCardReview copyWith({
    int? id,
    int? cardId,
    String? rating,
    DateTime? reviewedAt,
  }) => DbCardReview(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    rating: rating ?? this.rating,
    reviewedAt: reviewedAt ?? this.reviewedAt,
  );
  DbCardReview copyWithCompanion(DbCardReviewsCompanion data) {
    return DbCardReview(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbCardReview(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cardId, rating, reviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbCardReview &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.rating == this.rating &&
          other.reviewedAt == this.reviewedAt);
}

class DbCardReviewsCompanion extends UpdateCompanion<DbCardReview> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<String> rating;
  final Value<DateTime> reviewedAt;
  const DbCardReviewsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewedAt = const Value.absent(),
  });
  DbCardReviewsCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required String rating,
    required DateTime reviewedAt,
  }) : cardId = Value(cardId),
       rating = Value(rating),
       reviewedAt = Value(reviewedAt);
  static Insertable<DbCardReview> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<String>? rating,
    Expression<DateTime>? reviewedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (rating != null) 'rating': rating,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
    });
  }

  DbCardReviewsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<String>? rating,
    Value<DateTime>? reviewedAt,
  }) {
    return DbCardReviewsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      rating: rating ?? this.rating,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbCardReviewsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }
}

class $DbStudySessionsTable extends DbStudySessions
    with TableInfo<$DbStudySessionsTable, DbStudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbStudySessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_decks (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cardsReviewedMeta = const VerificationMeta(
    'cardsReviewed',
  );
  @override
  late final GeneratedColumn<int> cardsReviewed = GeneratedColumn<int>(
    'cards_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    startedAt,
    endedAt,
    durationSeconds,
    cardsReviewed,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_study_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbStudySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('cards_reviewed')) {
      context.handle(
        _cardsReviewedMeta,
        cardsReviewed.isAcceptableOrUnknown(
          data['cards_reviewed']!,
          _cardsReviewedMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbStudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbStudySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      cardsReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cards_reviewed'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $DbStudySessionsTable createAlias(String alias) {
    return $DbStudySessionsTable(attachedDatabase, alias);
  }
}

class DbStudySession extends DataClass implements Insertable<DbStudySession> {
  final int id;
  final int? deckId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final int cardsReviewed;
  final String type;
  const DbStudySession({
    required this.id,
    this.deckId,
    required this.startedAt,
    this.endedAt,
    required this.durationSeconds,
    required this.cardsReviewed,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || deckId != null) {
      map['deck_id'] = Variable<int>(deckId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['cards_reviewed'] = Variable<int>(cardsReviewed);
    map['type'] = Variable<String>(type);
    return map;
  }

  DbStudySessionsCompanion toCompanion(bool nullToAbsent) {
    return DbStudySessionsCompanion(
      id: Value(id),
      deckId: deckId == null && nullToAbsent
          ? const Value.absent()
          : Value(deckId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationSeconds: Value(durationSeconds),
      cardsReviewed: Value(cardsReviewed),
      type: Value(type),
    );
  }

  factory DbStudySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbStudySession(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int?>(json['deckId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      cardsReviewed: serializer.fromJson<int>(json['cardsReviewed']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<int?>(deckId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'cardsReviewed': serializer.toJson<int>(cardsReviewed),
      'type': serializer.toJson<String>(type),
    };
  }

  DbStudySession copyWith({
    int? id,
    Value<int?> deckId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? durationSeconds,
    int? cardsReviewed,
    String? type,
  }) => DbStudySession(
    id: id ?? this.id,
    deckId: deckId.present ? deckId.value : this.deckId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    cardsReviewed: cardsReviewed ?? this.cardsReviewed,
    type: type ?? this.type,
  );
  DbStudySession copyWithCompanion(DbStudySessionsCompanion data) {
    return DbStudySession(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      cardsReviewed: data.cardsReviewed.present
          ? data.cardsReviewed.value
          : this.cardsReviewed,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbStudySession(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('cardsReviewed: $cardsReviewed, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    startedAt,
    endedAt,
    durationSeconds,
    cardsReviewed,
    type,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbStudySession &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.cardsReviewed == this.cardsReviewed &&
          other.type == this.type);
}

class DbStudySessionsCompanion extends UpdateCompanion<DbStudySession> {
  final Value<int> id;
  final Value<int?> deckId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationSeconds;
  final Value<int> cardsReviewed;
  final Value<String> type;
  const DbStudySessionsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.cardsReviewed = const Value.absent(),
    this.type = const Value.absent(),
  });
  DbStudySessionsCompanion.insert({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.cardsReviewed = const Value.absent(),
    required String type,
  }) : startedAt = Value(startedAt),
       type = Value(type);
  static Insertable<DbStudySession> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationSeconds,
    Expression<int>? cardsReviewed,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (cardsReviewed != null) 'cards_reviewed': cardsReviewed,
      if (type != null) 'type': type,
    });
  }

  DbStudySessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? deckId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? durationSeconds,
    Value<int>? cardsReviewed,
    Value<String>? type,
  }) {
    return DbStudySessionsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (cardsReviewed.present) {
      map['cards_reviewed'] = Variable<int>(cardsReviewed.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbStudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('cardsReviewed: $cardsReviewed, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $DbRevisionsTable extends DbRevisions
    with TableInfo<$DbRevisionsTable, DbRevision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbRevisionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES db_decks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    scheduledAt,
    note,
    reminderEnabled,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbRevision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
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
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbRevision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbRevision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $DbRevisionsTable createAlias(String alias) {
    return $DbRevisionsTable(attachedDatabase, alias);
  }
}

class DbRevision extends DataClass implements Insertable<DbRevision> {
  final int id;
  final int deckId;
  final DateTime scheduledAt;
  final String? note;
  final bool reminderEnabled;
  final DateTime createdAt;
  final DateTime? completedAt;
  const DbRevision({
    required this.id,
    required this.deckId,
    required this.scheduledAt,
    this.note,
    required this.reminderEnabled,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<int>(deckId);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  DbRevisionsCompanion toCompanion(bool nullToAbsent) {
    return DbRevisionsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      scheduledAt: Value(scheduledAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      reminderEnabled: Value(reminderEnabled),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory DbRevision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbRevision(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int>(json['deckId']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      note: serializer.fromJson<String?>(json['note']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<int>(deckId),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'note': serializer.toJson<String?>(note),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  DbRevision copyWith({
    int? id,
    int? deckId,
    DateTime? scheduledAt,
    Value<String?> note = const Value.absent(),
    bool? reminderEnabled,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => DbRevision(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    note: note.present ? note.value : this.note,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  DbRevision copyWithCompanion(DbRevisionsCompanion data) {
    return DbRevision(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      note: data.note.present ? data.note.value : this.note,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbRevision(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('note: $note, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    scheduledAt,
    note,
    reminderEnabled,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbRevision &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.scheduledAt == this.scheduledAt &&
          other.note == this.note &&
          other.reminderEnabled == this.reminderEnabled &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class DbRevisionsCompanion extends UpdateCompanion<DbRevision> {
  final Value<int> id;
  final Value<int> deckId;
  final Value<DateTime> scheduledAt;
  final Value<String?> note;
  final Value<bool> reminderEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  const DbRevisionsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.note = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  DbRevisionsCompanion.insert({
    this.id = const Value.absent(),
    required int deckId,
    required DateTime scheduledAt,
    this.note = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
  }) : deckId = Value(deckId),
       scheduledAt = Value(scheduledAt),
       createdAt = Value(createdAt);
  static Insertable<DbRevision> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<DateTime>? scheduledAt,
    Expression<String>? note,
    Expression<bool>? reminderEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (note != null) 'note': note,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  DbRevisionsCompanion copyWith({
    Value<int>? id,
    Value<int>? deckId,
    Value<DateTime>? scheduledAt,
    Value<String?>? note,
    Value<bool>? reminderEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
  }) {
    return DbRevisionsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      note: note ?? this.note,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('note: $note, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DbFoldersTable dbFolders = $DbFoldersTable(this);
  late final $DbSubjectsTable dbSubjects = $DbSubjectsTable(this);
  late final $DbDocumentsTable dbDocuments = $DbDocumentsTable(this);
  late final $DbExtractedTextsTable dbExtractedTexts = $DbExtractedTextsTable(
    this,
  );
  late final $DbSettingsTable dbSettings = $DbSettingsTable(this);
  late final $DbDecksTable dbDecks = $DbDecksTable(this);
  late final $DbFlashcardsTable dbFlashcards = $DbFlashcardsTable(this);
  late final $DbQuizQuestionsTable dbQuizQuestions = $DbQuizQuestionsTable(
    this,
  );
  late final $DbQuizAttemptsTable dbQuizAttempts = $DbQuizAttemptsTable(this);
  late final $DbQuestionAnswersTable dbQuestionAnswers =
      $DbQuestionAnswersTable(this);
  late final $DbCardReviewsTable dbCardReviews = $DbCardReviewsTable(this);
  late final $DbStudySessionsTable dbStudySessions = $DbStudySessionsTable(
    this,
  );
  late final $DbRevisionsTable dbRevisions = $DbRevisionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dbFolders,
    dbSubjects,
    dbDocuments,
    dbExtractedTexts,
    dbSettings,
    dbDecks,
    dbFlashcards,
    dbQuizQuestions,
    dbQuizAttempts,
    dbQuestionAnswers,
    dbCardReviews,
    dbStudySessions,
    dbRevisions,
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
        'db_subjects',
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_decks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_flashcards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_quiz_questions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_quiz_attempts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_quiz_attempts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_question_answers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_quiz_questions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_question_answers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_flashcards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_card_reviews', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_study_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'db_decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_revisions', kind: UpdateKind.delete)],
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
                    await $_getPrefetchedDataByColumns<
                      DbFolder,
                      $DbFoldersTable,
                      DbDocument,
                      $DbDocumentsTable
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
                      currentColumn: 'id',
                      referencedColumn: 'folder_id',
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
typedef $$DbSubjectsTableCreateCompanionBuilder =
    DbSubjectsCompanion Function({
      Value<int> id,
      required String name,
      required DateTime createdAt,
    });
typedef $$DbSubjectsTableUpdateCompanionBuilder =
    DbSubjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

final class $$DbSubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $DbSubjectsTable, DbSubject> {
  $$DbSubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DbDocumentsTable, List<DbDocument>>
  _dbDocumentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dbDocuments,
    aliasName: 'db_subjects__id__db_documents__subject_id',
  );

  $$DbDocumentsTableProcessedTableManager get dbDocumentsRefs {
    final manager = $$DbDocumentsTableTableManager(
      $_db,
      $_db.dbDocuments,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbDocumentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbSubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $DbSubjectsTable> {
  $$DbSubjectsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dbDocumentsRefs(
    Expression<bool> Function($$DbDocumentsTableFilterComposer f) f,
  ) {
    final $$DbDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbDocuments,
      getReferencedColumn: (t) => t.subjectId,
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

class $$DbSubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbSubjectsTable> {
  $$DbSubjectsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbSubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbSubjectsTable> {
  $$DbSubjectsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> dbDocumentsRefs<T extends Object>(
    Expression<T> Function($$DbDocumentsTableAnnotationComposer a) f,
  ) {
    final $$DbDocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbDocuments,
      getReferencedColumn: (t) => t.subjectId,
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

class $$DbSubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbSubjectsTable,
          DbSubject,
          $$DbSubjectsTableFilterComposer,
          $$DbSubjectsTableOrderingComposer,
          $$DbSubjectsTableAnnotationComposer,
          $$DbSubjectsTableCreateCompanionBuilder,
          $$DbSubjectsTableUpdateCompanionBuilder,
          (DbSubject, $$DbSubjectsTableReferences),
          DbSubject,
          PrefetchHooks Function({bool dbDocumentsRefs})
        > {
  $$DbSubjectsTableTableManager(_$AppDatabase db, $DbSubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbSubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) =>
                  DbSubjectsCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime createdAt,
              }) => DbSubjectsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbSubjectsTable, DbSubject>(table),
                  $$DbSubjectsTableReferences(db, table, e),
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
                    await $_getPrefetchedDataByColumns<
                      DbSubject,
                      $DbSubjectsTable,
                      DbDocument,
                      $DbDocumentsTable
                    >(
                      currentTable: table,
                      referencedTable: $$DbSubjectsTableReferences
                          ._dbDocumentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DbSubjectsTableReferences(
                            db,
                            table,
                            p0,
                          ).dbDocumentsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'subject_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DbSubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbSubjectsTable,
      DbSubject,
      $$DbSubjectsTableFilterComposer,
      $$DbSubjectsTableOrderingComposer,
      $$DbSubjectsTableAnnotationComposer,
      $$DbSubjectsTableCreateCompanionBuilder,
      $$DbSubjectsTableUpdateCompanionBuilder,
      (DbSubject, $$DbSubjectsTableReferences),
      DbSubject,
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
      Value<int?> subjectId,
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
      Value<int?> subjectId,
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

  static $DbSubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.dbSubjects.createAlias('db_documents__subject_id__db_subjects__id');

  $$DbSubjectsTableProcessedTableManager? get subjectId {
    final $_column = $_itemColumn<int>('subject_id');
    if ($_column == null) return null;
    final manager = $$DbSubjectsTableTableManager(
      $_db,
      $_db.dbSubjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
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

  static MultiTypedResultKey<$DbDecksTable, List<DbDeck>> _dbDecksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.dbDecks,
    aliasName: 'db_documents__id__db_decks__document_id',
  );

  $$DbDecksTableProcessedTableManager get dbDecksRefs {
    final manager = $$DbDecksTableTableManager(
      $_db,
      $_db.dbDecks,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbDecksRefsTable($_db));
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

  $$DbSubjectsTableFilterComposer get subjectId {
    final $$DbSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.dbSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.dbSubjects,
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

  Expression<bool> dbDecksRefs(
    Expression<bool> Function($$DbDecksTableFilterComposer f) f,
  ) {
    final $$DbDecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableFilterComposer(
            $db: $db,
            $table: $db.dbDecks,
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

  $$DbSubjectsTableOrderingComposer get subjectId {
    final $$DbSubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.dbSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbSubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.dbSubjects,
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

  $$DbSubjectsTableAnnotationComposer get subjectId {
    final $$DbSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.dbSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbSubjects,
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

  Expression<T> dbDecksRefs<T extends Object>(
    Expression<T> Function($$DbDecksTableAnnotationComposer a) f,
  ) {
    final $$DbDecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbDecks,
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
          PrefetchHooks Function({
            bool folderId,
            bool subjectId,
            bool dbExtractedTextsRefs,
            bool dbDecksRefs,
          })
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
                Value<int?> subjectId = const Value.absent(),
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
                subjectId: subjectId,
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
                Value<int?> subjectId = const Value.absent(),
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
                subjectId: subjectId,
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
              ({
                folderId = false,
                subjectId = false,
                dbExtractedTextsRefs = false,
                dbDecksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dbExtractedTextsRefs) db.dbExtractedTexts,
                    if (dbDecksRefs) db.dbDecks,
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
                        if (subjectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subjectId,
                                    referencedTable:
                                        $$DbDocumentsTableReferences
                                            ._subjectIdTable(db),
                                    referencedColumn:
                                        $$DbDocumentsTableReferences
                                            ._subjectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dbExtractedTextsRefs)
                        await $_getPrefetchedDataByColumns<
                          DbDocument,
                          $DbDocumentsTable,
                          DbExtractedText,
                          $DbExtractedTextsTable
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
                          currentColumn: 'id',
                          referencedColumn: 'document_id',
                          typedResults: items,
                        ),
                      if (dbDecksRefs)
                        await $_getPrefetchedDataByColumns<
                          DbDocument,
                          $DbDocumentsTable,
                          DbDeck,
                          $DbDecksTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbDocumentsTableReferences
                              ._dbDecksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbDocumentsTableReferences(
                                db,
                                table,
                                p0,
                              ).dbDecksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'document_id',
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
      PrefetchHooks Function({
        bool folderId,
        bool subjectId,
        bool dbExtractedTextsRefs,
        bool dbDecksRefs,
      })
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
typedef $$DbSettingsTableCreateCompanionBuilder =
    DbSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$DbSettingsTableUpdateCompanionBuilder =
    DbSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$DbSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $DbSettingsTable> {
  $$DbSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbSettingsTable> {
  $$DbSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbSettingsTable> {
  $$DbSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$DbSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbSettingsTable,
          DbSetting,
          $$DbSettingsTableFilterComposer,
          $$DbSettingsTableOrderingComposer,
          $$DbSettingsTableAnnotationComposer,
          $$DbSettingsTableCreateCompanionBuilder,
          $$DbSettingsTableUpdateCompanionBuilder,
          (
            DbSetting,
            BaseReferences<_$AppDatabase, $DbSettingsTable, DbSetting>,
          ),
          DbSetting,
          PrefetchHooks Function()
        > {
  $$DbSettingsTableTableManager(_$AppDatabase db, $DbSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => DbSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbSettingsTable, DbSetting>(table),
                  BaseReferences<_$AppDatabase, $DbSettingsTable, DbSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbSettingsTable,
      DbSetting,
      $$DbSettingsTableFilterComposer,
      $$DbSettingsTableOrderingComposer,
      $$DbSettingsTableAnnotationComposer,
      $$DbSettingsTableCreateCompanionBuilder,
      $$DbSettingsTableUpdateCompanionBuilder,
      (DbSetting, BaseReferences<_$AppDatabase, $DbSettingsTable, DbSetting>),
      DbSetting,
      PrefetchHooks Function()
    >;
typedef $$DbDecksTableCreateCompanionBuilder =
    DbDecksCompanion Function({
      Value<int> id,
      required int documentId,
      required String title,
      required String materialType,
      required int totalItems,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$DbDecksTableUpdateCompanionBuilder =
    DbDecksCompanion Function({
      Value<int> id,
      Value<int> documentId,
      Value<String> title,
      Value<String> materialType,
      Value<int> totalItems,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$DbDecksTableReferences
    extends BaseReferences<_$AppDatabase, $DbDecksTable, DbDeck> {
  $$DbDecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbDocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.dbDocuments.createAlias('db_decks__document_id__db_documents__id');

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

  static MultiTypedResultKey<$DbFlashcardsTable, List<DbFlashcard>>
  _dbFlashcardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dbFlashcards,
    aliasName: 'db_decks__id__db_flashcards__deck_id',
  );

  $$DbFlashcardsTableProcessedTableManager get dbFlashcardsRefs {
    final manager = $$DbFlashcardsTableTableManager(
      $_db,
      $_db.dbFlashcards,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbFlashcardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DbQuizQuestionsTable, List<DbQuizQuestion>>
  _dbQuizQuestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dbQuizQuestions,
    aliasName: 'db_decks__id__db_quiz_questions__deck_id',
  );

  $$DbQuizQuestionsTableProcessedTableManager get dbQuizQuestionsRefs {
    final manager = $$DbQuizQuestionsTableTableManager(
      $_db,
      $_db.dbQuizQuestions,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dbQuizQuestionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DbQuizAttemptsTable, List<DbQuizAttempt>>
  _dbQuizAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dbQuizAttempts,
    aliasName: 'db_decks__id__db_quiz_attempts__deck_id',
  );

  $$DbQuizAttemptsTableProcessedTableManager get dbQuizAttemptsRefs {
    final manager = $$DbQuizAttemptsTableTableManager(
      $_db,
      $_db.dbQuizAttempts,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbQuizAttemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DbStudySessionsTable, List<DbStudySession>>
  _dbStudySessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dbStudySessions,
    aliasName: 'db_decks__id__db_study_sessions__deck_id',
  );

  $$DbStudySessionsTableProcessedTableManager get dbStudySessionsRefs {
    final manager = $$DbStudySessionsTableTableManager(
      $_db,
      $_db.dbStudySessions,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dbStudySessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DbRevisionsTable, List<DbRevision>>
  _dbRevisionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dbRevisions,
    aliasName: 'db_decks__id__db_revisions__deck_id',
  );

  $$DbRevisionsTableProcessedTableManager get dbRevisionsRefs {
    final manager = $$DbRevisionsTableTableManager(
      $_db,
      $_db.dbRevisions,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbRevisionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbDecksTableFilterComposer
    extends Composer<_$AppDatabase, $DbDecksTable> {
  $$DbDecksTableFilterComposer({
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

  ColumnFilters<String> get materialType => $composableBuilder(
    column: $table.materialType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalItems => $composableBuilder(
    column: $table.totalItems,
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

  Expression<bool> dbFlashcardsRefs(
    Expression<bool> Function($$DbFlashcardsTableFilterComposer f) f,
  ) {
    final $$DbFlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbFlashcards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbFlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.dbFlashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dbQuizQuestionsRefs(
    Expression<bool> Function($$DbQuizQuestionsTableFilterComposer f) f,
  ) {
    final $$DbQuizQuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbQuizQuestions,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuizQuestionsTableFilterComposer(
            $db: $db,
            $table: $db.dbQuizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dbQuizAttemptsRefs(
    Expression<bool> Function($$DbQuizAttemptsTableFilterComposer f) f,
  ) {
    final $$DbQuizAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbQuizAttempts,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuizAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.dbQuizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dbStudySessionsRefs(
    Expression<bool> Function($$DbStudySessionsTableFilterComposer f) f,
  ) {
    final $$DbStudySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbStudySessions,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbStudySessionsTableFilterComposer(
            $db: $db,
            $table: $db.dbStudySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dbRevisionsRefs(
    Expression<bool> Function($$DbRevisionsTableFilterComposer f) f,
  ) {
    final $$DbRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbRevisions,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.dbRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbDecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DbDecksTable> {
  $$DbDecksTableOrderingComposer({
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

  ColumnOrderings<String> get materialType => $composableBuilder(
    column: $table.materialType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalItems => $composableBuilder(
    column: $table.totalItems,
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

class $$DbDecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbDecksTable> {
  $$DbDecksTableAnnotationComposer({
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

  GeneratedColumn<String> get materialType => $composableBuilder(
    column: $table.materialType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalItems => $composableBuilder(
    column: $table.totalItems,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

  Expression<T> dbFlashcardsRefs<T extends Object>(
    Expression<T> Function($$DbFlashcardsTableAnnotationComposer a) f,
  ) {
    final $$DbFlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbFlashcards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbFlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbFlashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dbQuizQuestionsRefs<T extends Object>(
    Expression<T> Function($$DbQuizQuestionsTableAnnotationComposer a) f,
  ) {
    final $$DbQuizQuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbQuizQuestions,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuizQuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbQuizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dbQuizAttemptsRefs<T extends Object>(
    Expression<T> Function($$DbQuizAttemptsTableAnnotationComposer a) f,
  ) {
    final $$DbQuizAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbQuizAttempts,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuizAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbQuizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dbStudySessionsRefs<T extends Object>(
    Expression<T> Function($$DbStudySessionsTableAnnotationComposer a) f,
  ) {
    final $$DbStudySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbStudySessions,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbStudySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbStudySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dbRevisionsRefs<T extends Object>(
    Expression<T> Function($$DbRevisionsTableAnnotationComposer a) f,
  ) {
    final $$DbRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbRevisions,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbDecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbDecksTable,
          DbDeck,
          $$DbDecksTableFilterComposer,
          $$DbDecksTableOrderingComposer,
          $$DbDecksTableAnnotationComposer,
          $$DbDecksTableCreateCompanionBuilder,
          $$DbDecksTableUpdateCompanionBuilder,
          (DbDeck, $$DbDecksTableReferences),
          DbDeck,
          PrefetchHooks Function({
            bool documentId,
            bool dbFlashcardsRefs,
            bool dbQuizQuestionsRefs,
            bool dbQuizAttemptsRefs,
            bool dbStudySessionsRefs,
            bool dbRevisionsRefs,
          })
        > {
  $$DbDecksTableTableManager(_$AppDatabase db, $DbDecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbDecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbDecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbDecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> documentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> materialType = const Value.absent(),
                Value<int> totalItems = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DbDecksCompanion(
                id: id,
                documentId: documentId,
                title: title,
                materialType: materialType,
                totalItems: totalItems,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int documentId,
                required String title,
                required String materialType,
                required int totalItems,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DbDecksCompanion.insert(
                id: id,
                documentId: documentId,
                title: title,
                materialType: materialType,
                totalItems: totalItems,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbDecksTable, DbDeck>(table),
                  $$DbDecksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                documentId = false,
                dbFlashcardsRefs = false,
                dbQuizQuestionsRefs = false,
                dbQuizAttemptsRefs = false,
                dbStudySessionsRefs = false,
                dbRevisionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dbFlashcardsRefs) db.dbFlashcards,
                    if (dbQuizQuestionsRefs) db.dbQuizQuestions,
                    if (dbQuizAttemptsRefs) db.dbQuizAttempts,
                    if (dbStudySessionsRefs) db.dbStudySessions,
                    if (dbRevisionsRefs) db.dbRevisions,
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
                        if (documentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.documentId,
                                    referencedTable: $$DbDecksTableReferences
                                        ._documentIdTable(db),
                                    referencedColumn: $$DbDecksTableReferences
                                        ._documentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dbFlashcardsRefs)
                        await $_getPrefetchedDataByColumns<
                          DbDeck,
                          $DbDecksTable,
                          DbFlashcard,
                          $DbFlashcardsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbDecksTableReferences
                              ._dbFlashcardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbDecksTableReferences(
                                db,
                                table,
                                p0,
                              ).dbFlashcardsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'deck_id',
                          typedResults: items,
                        ),
                      if (dbQuizQuestionsRefs)
                        await $_getPrefetchedDataByColumns<
                          DbDeck,
                          $DbDecksTable,
                          DbQuizQuestion,
                          $DbQuizQuestionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbDecksTableReferences
                              ._dbQuizQuestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbDecksTableReferences(
                                db,
                                table,
                                p0,
                              ).dbQuizQuestionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'deck_id',
                          typedResults: items,
                        ),
                      if (dbQuizAttemptsRefs)
                        await $_getPrefetchedDataByColumns<
                          DbDeck,
                          $DbDecksTable,
                          DbQuizAttempt,
                          $DbQuizAttemptsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbDecksTableReferences
                              ._dbQuizAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbDecksTableReferences(
                                db,
                                table,
                                p0,
                              ).dbQuizAttemptsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'deck_id',
                          typedResults: items,
                        ),
                      if (dbStudySessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          DbDeck,
                          $DbDecksTable,
                          DbStudySession,
                          $DbStudySessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbDecksTableReferences
                              ._dbStudySessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbDecksTableReferences(
                                db,
                                table,
                                p0,
                              ).dbStudySessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'deck_id',
                          typedResults: items,
                        ),
                      if (dbRevisionsRefs)
                        await $_getPrefetchedDataByColumns<
                          DbDeck,
                          $DbDecksTable,
                          DbRevision,
                          $DbRevisionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbDecksTableReferences
                              ._dbRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbDecksTableReferences(
                                db,
                                table,
                                p0,
                              ).dbRevisionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'deck_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DbDecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbDecksTable,
      DbDeck,
      $$DbDecksTableFilterComposer,
      $$DbDecksTableOrderingComposer,
      $$DbDecksTableAnnotationComposer,
      $$DbDecksTableCreateCompanionBuilder,
      $$DbDecksTableUpdateCompanionBuilder,
      (DbDeck, $$DbDecksTableReferences),
      DbDeck,
      PrefetchHooks Function({
        bool documentId,
        bool dbFlashcardsRefs,
        bool dbQuizQuestionsRefs,
        bool dbQuizAttemptsRefs,
        bool dbStudySessionsRefs,
        bool dbRevisionsRefs,
      })
    >;
typedef $$DbFlashcardsTableCreateCompanionBuilder =
    DbFlashcardsCompanion Function({
      Value<int> id,
      required int deckId,
      required String front,
      required String back,
      Value<String?> explanation,
      required int sortOrder,
    });
typedef $$DbFlashcardsTableUpdateCompanionBuilder =
    DbFlashcardsCompanion Function({
      Value<int> id,
      Value<int> deckId,
      Value<String> front,
      Value<String> back,
      Value<String?> explanation,
      Value<int> sortOrder,
    });

final class $$DbFlashcardsTableReferences
    extends BaseReferences<_$AppDatabase, $DbFlashcardsTable, DbFlashcard> {
  $$DbFlashcardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbDecksTable _deckIdTable(_$AppDatabase db) =>
      db.dbDecks.createAlias('db_flashcards__deck_id__db_decks__id');

  $$DbDecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<int>('deck_id')!;

    final manager = $$DbDecksTableTableManager(
      $_db,
      $_db.dbDecks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DbCardReviewsTable, List<DbCardReview>>
  _dbCardReviewsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dbCardReviews,
    aliasName: 'db_flashcards__id__db_card_reviews__card_id',
  );

  $$DbCardReviewsTableProcessedTableManager get dbCardReviewsRefs {
    final manager = $$DbCardReviewsTableTableManager(
      $_db,
      $_db.dbCardReviews,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbCardReviewsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbFlashcardsTableFilterComposer
    extends Composer<_$AppDatabase, $DbFlashcardsTable> {
  $$DbFlashcardsTableFilterComposer({
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

  ColumnFilters<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$DbDecksTableFilterComposer get deckId {
    final $$DbDecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableFilterComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> dbCardReviewsRefs(
    Expression<bool> Function($$DbCardReviewsTableFilterComposer f) f,
  ) {
    final $$DbCardReviewsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbCardReviews,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbCardReviewsTableFilterComposer(
            $db: $db,
            $table: $db.dbCardReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbFlashcardsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbFlashcardsTable> {
  $$DbFlashcardsTableOrderingComposer({
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

  ColumnOrderings<String> get front => $composableBuilder(
    column: $table.front,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get back => $composableBuilder(
    column: $table.back,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbDecksTableOrderingComposer get deckId {
    final $$DbDecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableOrderingComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbFlashcardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbFlashcardsTable> {
  $$DbFlashcardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$DbDecksTableAnnotationComposer get deckId {
    final $$DbDecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> dbCardReviewsRefs<T extends Object>(
    Expression<T> Function($$DbCardReviewsTableAnnotationComposer a) f,
  ) {
    final $$DbCardReviewsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbCardReviews,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbCardReviewsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbCardReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbFlashcardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbFlashcardsTable,
          DbFlashcard,
          $$DbFlashcardsTableFilterComposer,
          $$DbFlashcardsTableOrderingComposer,
          $$DbFlashcardsTableAnnotationComposer,
          $$DbFlashcardsTableCreateCompanionBuilder,
          $$DbFlashcardsTableUpdateCompanionBuilder,
          (DbFlashcard, $$DbFlashcardsTableReferences),
          DbFlashcard,
          PrefetchHooks Function({bool deckId, bool dbCardReviewsRefs})
        > {
  $$DbFlashcardsTableTableManager(_$AppDatabase db, $DbFlashcardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbFlashcardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbFlashcardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbFlashcardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deckId = const Value.absent(),
                Value<String> front = const Value.absent(),
                Value<String> back = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => DbFlashcardsCompanion(
                id: id,
                deckId: deckId,
                front: front,
                back: back,
                explanation: explanation,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deckId,
                required String front,
                required String back,
                Value<String?> explanation = const Value.absent(),
                required int sortOrder,
              }) => DbFlashcardsCompanion.insert(
                id: id,
                deckId: deckId,
                front: front,
                back: back,
                explanation: explanation,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbFlashcardsTable, DbFlashcard>(table),
                  $$DbFlashcardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deckId = false, dbCardReviewsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dbCardReviewsRefs) db.dbCardReviews,
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
                    if (deckId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deckId,
                                referencedTable: $$DbFlashcardsTableReferences
                                    ._deckIdTable(db),
                                referencedColumn: $$DbFlashcardsTableReferences
                                    ._deckIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dbCardReviewsRefs)
                    await $_getPrefetchedDataByColumns<
                      DbFlashcard,
                      $DbFlashcardsTable,
                      DbCardReview,
                      $DbCardReviewsTable
                    >(
                      currentTable: table,
                      referencedTable: $$DbFlashcardsTableReferences
                          ._dbCardReviewsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DbFlashcardsTableReferences(
                            db,
                            table,
                            p0,
                          ).dbCardReviewsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'card_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DbFlashcardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbFlashcardsTable,
      DbFlashcard,
      $$DbFlashcardsTableFilterComposer,
      $$DbFlashcardsTableOrderingComposer,
      $$DbFlashcardsTableAnnotationComposer,
      $$DbFlashcardsTableCreateCompanionBuilder,
      $$DbFlashcardsTableUpdateCompanionBuilder,
      (DbFlashcard, $$DbFlashcardsTableReferences),
      DbFlashcard,
      PrefetchHooks Function({bool deckId, bool dbCardReviewsRefs})
    >;
typedef $$DbQuizQuestionsTableCreateCompanionBuilder =
    DbQuizQuestionsCompanion Function({
      Value<int> id,
      required int deckId,
      required String prompt,
      required String type,
      required String optionsJson,
      Value<int?> correctIndex,
      Value<String?> expectedAnswer,
      Value<String?> explanation,
      required int sortOrder,
    });
typedef $$DbQuizQuestionsTableUpdateCompanionBuilder =
    DbQuizQuestionsCompanion Function({
      Value<int> id,
      Value<int> deckId,
      Value<String> prompt,
      Value<String> type,
      Value<String> optionsJson,
      Value<int?> correctIndex,
      Value<String?> expectedAnswer,
      Value<String?> explanation,
      Value<int> sortOrder,
    });

final class $$DbQuizQuestionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DbQuizQuestionsTable, DbQuizQuestion> {
  $$DbQuizQuestionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DbDecksTable _deckIdTable(_$AppDatabase db) =>
      db.dbDecks.createAlias('db_quiz_questions__deck_id__db_decks__id');

  $$DbDecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<int>('deck_id')!;

    final manager = $$DbDecksTableTableManager(
      $_db,
      $_db.dbDecks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DbQuestionAnswersTable, List<DbQuestionAnswer>>
  _dbQuestionAnswersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dbQuestionAnswers,
        aliasName: 'db_quiz_questions__id__db_question_answers__question_id',
      );

  $$DbQuestionAnswersTableProcessedTableManager get dbQuestionAnswersRefs {
    final manager = $$DbQuestionAnswersTableTableManager(
      $_db,
      $_db.dbQuestionAnswers,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dbQuestionAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbQuizQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $DbQuizQuestionsTable> {
  $$DbQuizQuestionsTableFilterComposer({
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

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctIndex => $composableBuilder(
    column: $table.correctIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedAnswer => $composableBuilder(
    column: $table.expectedAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$DbDecksTableFilterComposer get deckId {
    final $$DbDecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableFilterComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> dbQuestionAnswersRefs(
    Expression<bool> Function($$DbQuestionAnswersTableFilterComposer f) f,
  ) {
    final $$DbQuestionAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbQuestionAnswers,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuestionAnswersTableFilterComposer(
            $db: $db,
            $table: $db.dbQuestionAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbQuizQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbQuizQuestionsTable> {
  $$DbQuizQuestionsTableOrderingComposer({
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

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctIndex => $composableBuilder(
    column: $table.correctIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedAnswer => $composableBuilder(
    column: $table.expectedAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbDecksTableOrderingComposer get deckId {
    final $$DbDecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableOrderingComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbQuizQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbQuizQuestionsTable> {
  $$DbQuizQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctIndex => $composableBuilder(
    column: $table.correctIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expectedAnswer => $composableBuilder(
    column: $table.expectedAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$DbDecksTableAnnotationComposer get deckId {
    final $$DbDecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> dbQuestionAnswersRefs<T extends Object>(
    Expression<T> Function($$DbQuestionAnswersTableAnnotationComposer a) f,
  ) {
    final $$DbQuestionAnswersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dbQuestionAnswers,
          getReferencedColumn: (t) => t.questionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DbQuestionAnswersTableAnnotationComposer(
                $db: $db,
                $table: $db.dbQuestionAnswers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DbQuizQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbQuizQuestionsTable,
          DbQuizQuestion,
          $$DbQuizQuestionsTableFilterComposer,
          $$DbQuizQuestionsTableOrderingComposer,
          $$DbQuizQuestionsTableAnnotationComposer,
          $$DbQuizQuestionsTableCreateCompanionBuilder,
          $$DbQuizQuestionsTableUpdateCompanionBuilder,
          (DbQuizQuestion, $$DbQuizQuestionsTableReferences),
          DbQuizQuestion,
          PrefetchHooks Function({bool deckId, bool dbQuestionAnswersRefs})
        > {
  $$DbQuizQuestionsTableTableManager(
    _$AppDatabase db,
    $DbQuizQuestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbQuizQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbQuizQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbQuizQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deckId = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> optionsJson = const Value.absent(),
                Value<int?> correctIndex = const Value.absent(),
                Value<String?> expectedAnswer = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => DbQuizQuestionsCompanion(
                id: id,
                deckId: deckId,
                prompt: prompt,
                type: type,
                optionsJson: optionsJson,
                correctIndex: correctIndex,
                expectedAnswer: expectedAnswer,
                explanation: explanation,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deckId,
                required String prompt,
                required String type,
                required String optionsJson,
                Value<int?> correctIndex = const Value.absent(),
                Value<String?> expectedAnswer = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                required int sortOrder,
              }) => DbQuizQuestionsCompanion.insert(
                id: id,
                deckId: deckId,
                prompt: prompt,
                type: type,
                optionsJson: optionsJson,
                correctIndex: correctIndex,
                expectedAnswer: expectedAnswer,
                explanation: explanation,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbQuizQuestionsTable, DbQuizQuestion>(table),
                  $$DbQuizQuestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({deckId = false, dbQuestionAnswersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dbQuestionAnswersRefs) db.dbQuestionAnswers,
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
                        if (deckId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.deckId,
                                    referencedTable:
                                        $$DbQuizQuestionsTableReferences
                                            ._deckIdTable(db),
                                    referencedColumn:
                                        $$DbQuizQuestionsTableReferences
                                            ._deckIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dbQuestionAnswersRefs)
                        await $_getPrefetchedDataByColumns<
                          DbQuizQuestion,
                          $DbQuizQuestionsTable,
                          DbQuestionAnswer,
                          $DbQuestionAnswersTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbQuizQuestionsTableReferences
                              ._dbQuestionAnswersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbQuizQuestionsTableReferences(
                                db,
                                table,
                                p0,
                              ).dbQuestionAnswersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'question_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DbQuizQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbQuizQuestionsTable,
      DbQuizQuestion,
      $$DbQuizQuestionsTableFilterComposer,
      $$DbQuizQuestionsTableOrderingComposer,
      $$DbQuizQuestionsTableAnnotationComposer,
      $$DbQuizQuestionsTableCreateCompanionBuilder,
      $$DbQuizQuestionsTableUpdateCompanionBuilder,
      (DbQuizQuestion, $$DbQuizQuestionsTableReferences),
      DbQuizQuestion,
      PrefetchHooks Function({bool deckId, bool dbQuestionAnswersRefs})
    >;
typedef $$DbQuizAttemptsTableCreateCompanionBuilder =
    DbQuizAttemptsCompanion Function({
      Value<int> id,
      required int deckId,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<int?> score,
      required int totalQuestions,
      Value<int> currentIndex,
    });
typedef $$DbQuizAttemptsTableUpdateCompanionBuilder =
    DbQuizAttemptsCompanion Function({
      Value<int> id,
      Value<int> deckId,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int?> score,
      Value<int> totalQuestions,
      Value<int> currentIndex,
    });

final class $$DbQuizAttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $DbQuizAttemptsTable, DbQuizAttempt> {
  $$DbQuizAttemptsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DbDecksTable _deckIdTable(_$AppDatabase db) =>
      db.dbDecks.createAlias('db_quiz_attempts__deck_id__db_decks__id');

  $$DbDecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<int>('deck_id')!;

    final manager = $$DbDecksTableTableManager(
      $_db,
      $_db.dbDecks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DbQuestionAnswersTable, List<DbQuestionAnswer>>
  _dbQuestionAnswersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dbQuestionAnswers,
        aliasName: 'db_quiz_attempts__id__db_question_answers__attempt_id',
      );

  $$DbQuestionAnswersTableProcessedTableManager get dbQuestionAnswersRefs {
    final manager = $$DbQuestionAnswersTableTableManager(
      $_db,
      $_db.dbQuestionAnswers,
    ).filter((f) => f.attemptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dbQuestionAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DbQuizAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $DbQuizAttemptsTable> {
  $$DbQuizAttemptsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$DbDecksTableFilterComposer get deckId {
    final $$DbDecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableFilterComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> dbQuestionAnswersRefs(
    Expression<bool> Function($$DbQuestionAnswersTableFilterComposer f) f,
  ) {
    final $$DbQuestionAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbQuestionAnswers,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuestionAnswersTableFilterComposer(
            $db: $db,
            $table: $db.dbQuestionAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DbQuizAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbQuizAttemptsTable> {
  $$DbQuizAttemptsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbDecksTableOrderingComposer get deckId {
    final $$DbDecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableOrderingComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbQuizAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbQuizAttemptsTable> {
  $$DbQuizAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  $$DbDecksTableAnnotationComposer get deckId {
    final $$DbDecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> dbQuestionAnswersRefs<T extends Object>(
    Expression<T> Function($$DbQuestionAnswersTableAnnotationComposer a) f,
  ) {
    final $$DbQuestionAnswersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.dbQuestionAnswers,
          getReferencedColumn: (t) => t.attemptId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DbQuestionAnswersTableAnnotationComposer(
                $db: $db,
                $table: $db.dbQuestionAnswers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DbQuizAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbQuizAttemptsTable,
          DbQuizAttempt,
          $$DbQuizAttemptsTableFilterComposer,
          $$DbQuizAttemptsTableOrderingComposer,
          $$DbQuizAttemptsTableAnnotationComposer,
          $$DbQuizAttemptsTableCreateCompanionBuilder,
          $$DbQuizAttemptsTableUpdateCompanionBuilder,
          (DbQuizAttempt, $$DbQuizAttemptsTableReferences),
          DbQuizAttempt,
          PrefetchHooks Function({bool deckId, bool dbQuestionAnswersRefs})
        > {
  $$DbQuizAttemptsTableTableManager(
    _$AppDatabase db,
    $DbQuizAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbQuizAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbQuizAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbQuizAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deckId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
              }) => DbQuizAttemptsCompanion(
                id: id,
                deckId: deckId,
                startedAt: startedAt,
                completedAt: completedAt,
                score: score,
                totalQuestions: totalQuestions,
                currentIndex: currentIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deckId,
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> score = const Value.absent(),
                required int totalQuestions,
                Value<int> currentIndex = const Value.absent(),
              }) => DbQuizAttemptsCompanion.insert(
                id: id,
                deckId: deckId,
                startedAt: startedAt,
                completedAt: completedAt,
                score: score,
                totalQuestions: totalQuestions,
                currentIndex: currentIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbQuizAttemptsTable, DbQuizAttempt>(table),
                  $$DbQuizAttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({deckId = false, dbQuestionAnswersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dbQuestionAnswersRefs) db.dbQuestionAnswers,
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
                        if (deckId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.deckId,
                                    referencedTable:
                                        $$DbQuizAttemptsTableReferences
                                            ._deckIdTable(db),
                                    referencedColumn:
                                        $$DbQuizAttemptsTableReferences
                                            ._deckIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dbQuestionAnswersRefs)
                        await $_getPrefetchedDataByColumns<
                          DbQuizAttempt,
                          $DbQuizAttemptsTable,
                          DbQuestionAnswer,
                          $DbQuestionAnswersTable
                        >(
                          currentTable: table,
                          referencedTable: $$DbQuizAttemptsTableReferences
                              ._dbQuestionAnswersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DbQuizAttemptsTableReferences(
                                db,
                                table,
                                p0,
                              ).dbQuestionAnswersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'attempt_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DbQuizAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbQuizAttemptsTable,
      DbQuizAttempt,
      $$DbQuizAttemptsTableFilterComposer,
      $$DbQuizAttemptsTableOrderingComposer,
      $$DbQuizAttemptsTableAnnotationComposer,
      $$DbQuizAttemptsTableCreateCompanionBuilder,
      $$DbQuizAttemptsTableUpdateCompanionBuilder,
      (DbQuizAttempt, $$DbQuizAttemptsTableReferences),
      DbQuizAttempt,
      PrefetchHooks Function({bool deckId, bool dbQuestionAnswersRefs})
    >;
typedef $$DbQuestionAnswersTableCreateCompanionBuilder =
    DbQuestionAnswersCompanion Function({
      Value<int> id,
      required int attemptId,
      required int questionId,
      Value<int?> selectedIndex,
      Value<String?> answerText,
      Value<bool?> isCorrect,
      required DateTime answeredAt,
    });
typedef $$DbQuestionAnswersTableUpdateCompanionBuilder =
    DbQuestionAnswersCompanion Function({
      Value<int> id,
      Value<int> attemptId,
      Value<int> questionId,
      Value<int?> selectedIndex,
      Value<String?> answerText,
      Value<bool?> isCorrect,
      Value<DateTime> answeredAt,
    });

final class $$DbQuestionAnswersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DbQuestionAnswersTable,
          DbQuestionAnswer
        > {
  $$DbQuestionAnswersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DbQuizAttemptsTable _attemptIdTable(_$AppDatabase db) => db
      .dbQuizAttempts
      .createAlias('db_question_answers__attempt_id__db_quiz_attempts__id');

  $$DbQuizAttemptsTableProcessedTableManager get attemptId {
    final $_column = $_itemColumn<int>('attempt_id')!;

    final manager = $$DbQuizAttemptsTableTableManager(
      $_db,
      $_db.dbQuizAttempts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attemptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DbQuizQuestionsTable _questionIdTable(_$AppDatabase db) => db
      .dbQuizQuestions
      .createAlias('db_question_answers__question_id__db_quiz_questions__id');

  $$DbQuizQuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$DbQuizQuestionsTableTableManager(
      $_db,
      $_db.dbQuizQuestions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbQuestionAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $DbQuestionAnswersTable> {
  $$DbQuestionAnswersTableFilterComposer({
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

  ColumnFilters<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DbQuizAttemptsTableFilterComposer get attemptId {
    final $$DbQuizAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.dbQuizAttempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuizAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.dbQuizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DbQuizQuestionsTableFilterComposer get questionId {
    final $$DbQuizQuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.dbQuizQuestions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuizQuestionsTableFilterComposer(
            $db: $db,
            $table: $db.dbQuizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbQuestionAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $DbQuestionAnswersTable> {
  $$DbQuestionAnswersTableOrderingComposer({
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

  ColumnOrderings<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbQuizAttemptsTableOrderingComposer get attemptId {
    final $$DbQuizAttemptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.dbQuizAttempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuizAttemptsTableOrderingComposer(
            $db: $db,
            $table: $db.dbQuizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DbQuizQuestionsTableOrderingComposer get questionId {
    final $$DbQuizQuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.dbQuizQuestions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuizQuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.dbQuizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbQuestionAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbQuestionAnswersTable> {
  $$DbQuestionAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$DbQuizAttemptsTableAnnotationComposer get attemptId {
    final $$DbQuizAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.dbQuizAttempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuizAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbQuizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DbQuizQuestionsTableAnnotationComposer get questionId {
    final $$DbQuizQuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.dbQuizQuestions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbQuizQuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbQuizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbQuestionAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbQuestionAnswersTable,
          DbQuestionAnswer,
          $$DbQuestionAnswersTableFilterComposer,
          $$DbQuestionAnswersTableOrderingComposer,
          $$DbQuestionAnswersTableAnnotationComposer,
          $$DbQuestionAnswersTableCreateCompanionBuilder,
          $$DbQuestionAnswersTableUpdateCompanionBuilder,
          (DbQuestionAnswer, $$DbQuestionAnswersTableReferences),
          DbQuestionAnswer,
          PrefetchHooks Function({bool attemptId, bool questionId})
        > {
  $$DbQuestionAnswersTableTableManager(
    _$AppDatabase db,
    $DbQuestionAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbQuestionAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbQuestionAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbQuestionAnswersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> attemptId = const Value.absent(),
                Value<int> questionId = const Value.absent(),
                Value<int?> selectedIndex = const Value.absent(),
                Value<String?> answerText = const Value.absent(),
                Value<bool?> isCorrect = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
              }) => DbQuestionAnswersCompanion(
                id: id,
                attemptId: attemptId,
                questionId: questionId,
                selectedIndex: selectedIndex,
                answerText: answerText,
                isCorrect: isCorrect,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int attemptId,
                required int questionId,
                Value<int?> selectedIndex = const Value.absent(),
                Value<String?> answerText = const Value.absent(),
                Value<bool?> isCorrect = const Value.absent(),
                required DateTime answeredAt,
              }) => DbQuestionAnswersCompanion.insert(
                id: id,
                attemptId: attemptId,
                questionId: questionId,
                selectedIndex: selectedIndex,
                answerText: answerText,
                isCorrect: isCorrect,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbQuestionAnswersTable, DbQuestionAnswer>(table),
                  $$DbQuestionAnswersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attemptId = false, questionId = false}) {
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
                    if (attemptId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.attemptId,
                                referencedTable:
                                    $$DbQuestionAnswersTableReferences
                                        ._attemptIdTable(db),
                                referencedColumn:
                                    $$DbQuestionAnswersTableReferences
                                        ._attemptIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable:
                                    $$DbQuestionAnswersTableReferences
                                        ._questionIdTable(db),
                                referencedColumn:
                                    $$DbQuestionAnswersTableReferences
                                        ._questionIdTable(db)
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

typedef $$DbQuestionAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbQuestionAnswersTable,
      DbQuestionAnswer,
      $$DbQuestionAnswersTableFilterComposer,
      $$DbQuestionAnswersTableOrderingComposer,
      $$DbQuestionAnswersTableAnnotationComposer,
      $$DbQuestionAnswersTableCreateCompanionBuilder,
      $$DbQuestionAnswersTableUpdateCompanionBuilder,
      (DbQuestionAnswer, $$DbQuestionAnswersTableReferences),
      DbQuestionAnswer,
      PrefetchHooks Function({bool attemptId, bool questionId})
    >;
typedef $$DbCardReviewsTableCreateCompanionBuilder =
    DbCardReviewsCompanion Function({
      Value<int> id,
      required int cardId,
      required String rating,
      required DateTime reviewedAt,
    });
typedef $$DbCardReviewsTableUpdateCompanionBuilder =
    DbCardReviewsCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<String> rating,
      Value<DateTime> reviewedAt,
    });

final class $$DbCardReviewsTableReferences
    extends BaseReferences<_$AppDatabase, $DbCardReviewsTable, DbCardReview> {
  $$DbCardReviewsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DbFlashcardsTable _cardIdTable(_$AppDatabase db) => db.dbFlashcards
      .createAlias('db_card_reviews__card_id__db_flashcards__id');

  $$DbFlashcardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<int>('card_id')!;

    final manager = $$DbFlashcardsTableTableManager(
      $_db,
      $_db.dbFlashcards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbCardReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $DbCardReviewsTable> {
  $$DbCardReviewsTableFilterComposer({
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

  ColumnFilters<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DbFlashcardsTableFilterComposer get cardId {
    final $$DbFlashcardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.dbFlashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbFlashcardsTableFilterComposer(
            $db: $db,
            $table: $db.dbFlashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbCardReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbCardReviewsTable> {
  $$DbCardReviewsTableOrderingComposer({
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

  ColumnOrderings<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbFlashcardsTableOrderingComposer get cardId {
    final $$DbFlashcardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.dbFlashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbFlashcardsTableOrderingComposer(
            $db: $db,
            $table: $db.dbFlashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbCardReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbCardReviewsTable> {
  $$DbCardReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  $$DbFlashcardsTableAnnotationComposer get cardId {
    final $$DbFlashcardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.dbFlashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbFlashcardsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbFlashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbCardReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbCardReviewsTable,
          DbCardReview,
          $$DbCardReviewsTableFilterComposer,
          $$DbCardReviewsTableOrderingComposer,
          $$DbCardReviewsTableAnnotationComposer,
          $$DbCardReviewsTableCreateCompanionBuilder,
          $$DbCardReviewsTableUpdateCompanionBuilder,
          (DbCardReview, $$DbCardReviewsTableReferences),
          DbCardReview,
          PrefetchHooks Function({bool cardId})
        > {
  $$DbCardReviewsTableTableManager(_$AppDatabase db, $DbCardReviewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbCardReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbCardReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbCardReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<String> rating = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
              }) => DbCardReviewsCompanion(
                id: id,
                cardId: cardId,
                rating: rating,
                reviewedAt: reviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required String rating,
                required DateTime reviewedAt,
              }) => DbCardReviewsCompanion.insert(
                id: id,
                cardId: cardId,
                rating: rating,
                reviewedAt: reviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbCardReviewsTable, DbCardReview>(table),
                  $$DbCardReviewsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
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
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable: $$DbCardReviewsTableReferences
                                    ._cardIdTable(db),
                                referencedColumn: $$DbCardReviewsTableReferences
                                    ._cardIdTable(db)
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

typedef $$DbCardReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbCardReviewsTable,
      DbCardReview,
      $$DbCardReviewsTableFilterComposer,
      $$DbCardReviewsTableOrderingComposer,
      $$DbCardReviewsTableAnnotationComposer,
      $$DbCardReviewsTableCreateCompanionBuilder,
      $$DbCardReviewsTableUpdateCompanionBuilder,
      (DbCardReview, $$DbCardReviewsTableReferences),
      DbCardReview,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$DbStudySessionsTableCreateCompanionBuilder =
    DbStudySessionsCompanion Function({
      Value<int> id,
      Value<int?> deckId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationSeconds,
      Value<int> cardsReviewed,
      required String type,
    });
typedef $$DbStudySessionsTableUpdateCompanionBuilder =
    DbStudySessionsCompanion Function({
      Value<int> id,
      Value<int?> deckId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationSeconds,
      Value<int> cardsReviewed,
      Value<String> type,
    });

final class $$DbStudySessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DbStudySessionsTable, DbStudySession> {
  $$DbStudySessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DbDecksTable _deckIdTable(_$AppDatabase db) =>
      db.dbDecks.createAlias('db_study_sessions__deck_id__db_decks__id');

  $$DbDecksTableProcessedTableManager? get deckId {
    final $_column = $_itemColumn<int>('deck_id');
    if ($_column == null) return null;
    final manager = $$DbDecksTableTableManager(
      $_db,
      $_db.dbDecks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbStudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $DbStudySessionsTable> {
  $$DbStudySessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardsReviewed => $composableBuilder(
    column: $table.cardsReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  $$DbDecksTableFilterComposer get deckId {
    final $$DbDecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableFilterComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbStudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbStudySessionsTable> {
  $$DbStudySessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardsReviewed => $composableBuilder(
    column: $table.cardsReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbDecksTableOrderingComposer get deckId {
    final $$DbDecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableOrderingComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbStudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbStudySessionsTable> {
  $$DbStudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardsReviewed => $composableBuilder(
    column: $table.cardsReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  $$DbDecksTableAnnotationComposer get deckId {
    final $$DbDecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbStudySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbStudySessionsTable,
          DbStudySession,
          $$DbStudySessionsTableFilterComposer,
          $$DbStudySessionsTableOrderingComposer,
          $$DbStudySessionsTableAnnotationComposer,
          $$DbStudySessionsTableCreateCompanionBuilder,
          $$DbStudySessionsTableUpdateCompanionBuilder,
          (DbStudySession, $$DbStudySessionsTableReferences),
          DbStudySession,
          PrefetchHooks Function({bool deckId})
        > {
  $$DbStudySessionsTableTableManager(
    _$AppDatabase db,
    $DbStudySessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbStudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbStudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbStudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> deckId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> cardsReviewed = const Value.absent(),
                Value<String> type = const Value.absent(),
              }) => DbStudySessionsCompanion(
                id: id,
                deckId: deckId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                cardsReviewed: cardsReviewed,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> deckId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> cardsReviewed = const Value.absent(),
                required String type,
              }) => DbStudySessionsCompanion.insert(
                id: id,
                deckId: deckId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                cardsReviewed: cardsReviewed,
                type: type,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbStudySessionsTable, DbStudySession>(table),
                  $$DbStudySessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deckId = false}) {
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
                    if (deckId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deckId,
                                referencedTable:
                                    $$DbStudySessionsTableReferences
                                        ._deckIdTable(db),
                                referencedColumn:
                                    $$DbStudySessionsTableReferences
                                        ._deckIdTable(db)
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

typedef $$DbStudySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbStudySessionsTable,
      DbStudySession,
      $$DbStudySessionsTableFilterComposer,
      $$DbStudySessionsTableOrderingComposer,
      $$DbStudySessionsTableAnnotationComposer,
      $$DbStudySessionsTableCreateCompanionBuilder,
      $$DbStudySessionsTableUpdateCompanionBuilder,
      (DbStudySession, $$DbStudySessionsTableReferences),
      DbStudySession,
      PrefetchHooks Function({bool deckId})
    >;
typedef $$DbRevisionsTableCreateCompanionBuilder =
    DbRevisionsCompanion Function({
      Value<int> id,
      required int deckId,
      required DateTime scheduledAt,
      Value<String?> note,
      Value<bool> reminderEnabled,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
    });
typedef $$DbRevisionsTableUpdateCompanionBuilder =
    DbRevisionsCompanion Function({
      Value<int> id,
      Value<int> deckId,
      Value<DateTime> scheduledAt,
      Value<String?> note,
      Value<bool> reminderEnabled,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
    });

final class $$DbRevisionsTableReferences
    extends BaseReferences<_$AppDatabase, $DbRevisionsTable, DbRevision> {
  $$DbRevisionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbDecksTable _deckIdTable(_$AppDatabase db) =>
      db.dbDecks.createAlias('db_revisions__deck_id__db_decks__id');

  $$DbDecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<int>('deck_id')!;

    final manager = $$DbDecksTableTableManager(
      $_db,
      $_db.dbDecks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $DbRevisionsTable> {
  $$DbRevisionsTableFilterComposer({
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

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DbDecksTableFilterComposer get deckId {
    final $$DbDecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableFilterComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbRevisionsTable> {
  $$DbRevisionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DbDecksTableOrderingComposer get deckId {
    final $$DbDecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableOrderingComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbRevisionsTable> {
  $$DbRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$DbDecksTableAnnotationComposer get deckId {
    final $$DbDecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.dbDecks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbDecksTableAnnotationComposer(
            $db: $db,
            $table: $db.dbDecks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbRevisionsTable,
          DbRevision,
          $$DbRevisionsTableFilterComposer,
          $$DbRevisionsTableOrderingComposer,
          $$DbRevisionsTableAnnotationComposer,
          $$DbRevisionsTableCreateCompanionBuilder,
          $$DbRevisionsTableUpdateCompanionBuilder,
          (DbRevision, $$DbRevisionsTableReferences),
          DbRevision,
          PrefetchHooks Function({bool deckId})
        > {
  $$DbRevisionsTableTableManager(_$AppDatabase db, $DbRevisionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbRevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deckId = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => DbRevisionsCompanion(
                id: id,
                deckId: deckId,
                scheduledAt: scheduledAt,
                note: note,
                reminderEnabled: reminderEnabled,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deckId,
                required DateTime scheduledAt,
                Value<String?> note = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
              }) => DbRevisionsCompanion.insert(
                id: id,
                deckId: deckId,
                scheduledAt: scheduledAt,
                note: note,
                reminderEnabled: reminderEnabled,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DbRevisionsTable, DbRevision>(table),
                  $$DbRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deckId = false}) {
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
                    if (deckId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deckId,
                                referencedTable: $$DbRevisionsTableReferences
                                    ._deckIdTable(db),
                                referencedColumn: $$DbRevisionsTableReferences
                                    ._deckIdTable(db)
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

typedef $$DbRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbRevisionsTable,
      DbRevision,
      $$DbRevisionsTableFilterComposer,
      $$DbRevisionsTableOrderingComposer,
      $$DbRevisionsTableAnnotationComposer,
      $$DbRevisionsTableCreateCompanionBuilder,
      $$DbRevisionsTableUpdateCompanionBuilder,
      (DbRevision, $$DbRevisionsTableReferences),
      DbRevision,
      PrefetchHooks Function({bool deckId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DbFoldersTableTableManager get dbFolders =>
      $$DbFoldersTableTableManager(_db, _db.dbFolders);
  $$DbSubjectsTableTableManager get dbSubjects =>
      $$DbSubjectsTableTableManager(_db, _db.dbSubjects);
  $$DbDocumentsTableTableManager get dbDocuments =>
      $$DbDocumentsTableTableManager(_db, _db.dbDocuments);
  $$DbExtractedTextsTableTableManager get dbExtractedTexts =>
      $$DbExtractedTextsTableTableManager(_db, _db.dbExtractedTexts);
  $$DbSettingsTableTableManager get dbSettings =>
      $$DbSettingsTableTableManager(_db, _db.dbSettings);
  $$DbDecksTableTableManager get dbDecks =>
      $$DbDecksTableTableManager(_db, _db.dbDecks);
  $$DbFlashcardsTableTableManager get dbFlashcards =>
      $$DbFlashcardsTableTableManager(_db, _db.dbFlashcards);
  $$DbQuizQuestionsTableTableManager get dbQuizQuestions =>
      $$DbQuizQuestionsTableTableManager(_db, _db.dbQuizQuestions);
  $$DbQuizAttemptsTableTableManager get dbQuizAttempts =>
      $$DbQuizAttemptsTableTableManager(_db, _db.dbQuizAttempts);
  $$DbQuestionAnswersTableTableManager get dbQuestionAnswers =>
      $$DbQuestionAnswersTableTableManager(_db, _db.dbQuestionAnswers);
  $$DbCardReviewsTableTableManager get dbCardReviews =>
      $$DbCardReviewsTableTableManager(_db, _db.dbCardReviews);
  $$DbStudySessionsTableTableManager get dbStudySessions =>
      $$DbStudySessionsTableTableManager(_db, _db.dbStudySessions);
  $$DbRevisionsTableTableManager get dbRevisions =>
      $$DbRevisionsTableTableManager(_db, _db.dbRevisions);
}
