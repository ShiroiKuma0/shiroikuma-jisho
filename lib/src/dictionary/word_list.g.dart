// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_list.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWordListCollection on Isar {
  IsarCollection<WordList> get wordLists => this.collection();
}

const WordListSchema = CollectionSchema(
  name: r'WordList',
  id: 2621804160792982594,
  properties: {
    r'created': PropertySchema(id: 0, name: r'created', type: IsarType.long),
    r'name': PropertySchema(id: 1, name: r'name', type: IsarType.string),
  },

  estimateSize: _wordListEstimateSize,
  serialize: _wordListSerialize,
  deserialize: _wordListDeserialize,
  deserializeProp: _wordListDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _wordListGetId,
  getLinks: _wordListGetLinks,
  attach: _wordListAttach,
  version: '3.3.2',
);

int _wordListEstimateSize(
  WordList object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _wordListSerialize(
  WordList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.created);
  writer.writeString(offsets[1], object.name);
}

WordList _wordListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WordList(
    created: reader.readLong(offsets[0]),
    id: id,
    name: reader.readString(offsets[1]),
  );
  return object;
}

P _wordListDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _wordListGetId(WordList object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _wordListGetLinks(WordList object) {
  return [];
}

void _wordListAttach(IsarCollection<dynamic> col, Id id, WordList object) {
  object.id = id;
}

extension WordListByIndex on IsarCollection<WordList> {
  Future<WordList?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  WordList? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<WordList?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<WordList?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(WordList object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(WordList object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<WordList> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<WordList> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension WordListQueryWhereSort on QueryBuilder<WordList, WordList, QWhere> {
  QueryBuilder<WordList, WordList, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WordListQueryWhere on QueryBuilder<WordList, WordList, QWhereClause> {
  QueryBuilder<WordList, WordList, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<WordList, WordList, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WordList, WordList, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'name', value: [name]),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterWhereClause> nameNotEqualTo(
    String name,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [],
                upper: [name],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [name],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [name],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [],
                upper: [name],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension WordListQueryFilter
    on QueryBuilder<WordList, WordList, QFilterCondition> {
  QueryBuilder<WordList, WordList, QAfterFilterCondition> createdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'created', value: value),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> createdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'created',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> createdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'created',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> createdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'created',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<WordList, WordList, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }
}

extension WordListQueryObject
    on QueryBuilder<WordList, WordList, QFilterCondition> {}

extension WordListQueryLinks
    on QueryBuilder<WordList, WordList, QFilterCondition> {}

extension WordListQuerySortBy on QueryBuilder<WordList, WordList, QSortBy> {
  QueryBuilder<WordList, WordList, QAfterSortBy> sortByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.asc);
    });
  }

  QueryBuilder<WordList, WordList, QAfterSortBy> sortByCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.desc);
    });
  }

  QueryBuilder<WordList, WordList, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WordList, WordList, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension WordListQuerySortThenBy
    on QueryBuilder<WordList, WordList, QSortThenBy> {
  QueryBuilder<WordList, WordList, QAfterSortBy> thenByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.asc);
    });
  }

  QueryBuilder<WordList, WordList, QAfterSortBy> thenByCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'created', Sort.desc);
    });
  }

  QueryBuilder<WordList, WordList, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WordList, WordList, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WordList, WordList, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WordList, WordList, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension WordListQueryWhereDistinct
    on QueryBuilder<WordList, WordList, QDistinct> {
  QueryBuilder<WordList, WordList, QDistinct> distinctByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'created');
    });
  }

  QueryBuilder<WordList, WordList, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension WordListQueryProperty
    on QueryBuilder<WordList, WordList, QQueryProperty> {
  QueryBuilder<WordList, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WordList, int, QQueryOperations> createdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'created');
    });
  }

  QueryBuilder<WordList, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWordListEntryCollection on Isar {
  IsarCollection<WordListEntry> get wordListEntrys => this.collection();
}

const WordListEntrySchema = CollectionSchema(
  name: r'WordListEntry',
  id: -7443697307889008498,
  properties: {
    r'added': PropertySchema(id: 0, name: r'added', type: IsarType.long),
    r'listId': PropertySchema(id: 1, name: r'listId', type: IsarType.long),
    r'reading': PropertySchema(id: 2, name: r'reading', type: IsarType.string),
    r'term': PropertySchema(id: 3, name: r'term', type: IsarType.string),
  },

  estimateSize: _wordListEntryEstimateSize,
  serialize: _wordListEntrySerialize,
  deserialize: _wordListEntryDeserialize,
  deserializeProp: _wordListEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'listId_term_reading': IndexSchema(
      id: 46435613206677937,
      name: r'listId_term_reading',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'listId',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'term',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'reading',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'term': IndexSchema(
      id: 5114652110782333408,
      name: r'term',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'term',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _wordListEntryGetId,
  getLinks: _wordListEntryGetLinks,
  attach: _wordListEntryAttach,
  version: '3.3.2',
);

int _wordListEntryEstimateSize(
  WordListEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.reading.length * 3;
  bytesCount += 3 + object.term.length * 3;
  return bytesCount;
}

void _wordListEntrySerialize(
  WordListEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.added);
  writer.writeLong(offsets[1], object.listId);
  writer.writeString(offsets[2], object.reading);
  writer.writeString(offsets[3], object.term);
}

WordListEntry _wordListEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WordListEntry(
    added: reader.readLong(offsets[0]),
    id: id,
    listId: reader.readLong(offsets[1]),
    reading: reader.readString(offsets[2]),
    term: reader.readString(offsets[3]),
  );
  return object;
}

P _wordListEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _wordListEntryGetId(WordListEntry object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _wordListEntryGetLinks(WordListEntry object) {
  return [];
}

void _wordListEntryAttach(
  IsarCollection<dynamic> col,
  Id id,
  WordListEntry object,
) {
  object.id = id;
}

extension WordListEntryByIndex on IsarCollection<WordListEntry> {
  Future<WordListEntry?> getByListIdTermReading(
    int listId,
    String term,
    String reading,
  ) {
    return getByIndex(r'listId_term_reading', [listId, term, reading]);
  }

  WordListEntry? getByListIdTermReadingSync(
    int listId,
    String term,
    String reading,
  ) {
    return getByIndexSync(r'listId_term_reading', [listId, term, reading]);
  }

  Future<bool> deleteByListIdTermReading(
    int listId,
    String term,
    String reading,
  ) {
    return deleteByIndex(r'listId_term_reading', [listId, term, reading]);
  }

  bool deleteByListIdTermReadingSync(int listId, String term, String reading) {
    return deleteByIndexSync(r'listId_term_reading', [listId, term, reading]);
  }

  Future<List<WordListEntry?>> getAllByListIdTermReading(
    List<int> listIdValues,
    List<String> termValues,
    List<String> readingValues,
  ) {
    final len = listIdValues.length;
    assert(
      termValues.length == len && readingValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([listIdValues[i], termValues[i], readingValues[i]]);
    }

    return getAllByIndex(r'listId_term_reading', values);
  }

  List<WordListEntry?> getAllByListIdTermReadingSync(
    List<int> listIdValues,
    List<String> termValues,
    List<String> readingValues,
  ) {
    final len = listIdValues.length;
    assert(
      termValues.length == len && readingValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([listIdValues[i], termValues[i], readingValues[i]]);
    }

    return getAllByIndexSync(r'listId_term_reading', values);
  }

  Future<int> deleteAllByListIdTermReading(
    List<int> listIdValues,
    List<String> termValues,
    List<String> readingValues,
  ) {
    final len = listIdValues.length;
    assert(
      termValues.length == len && readingValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([listIdValues[i], termValues[i], readingValues[i]]);
    }

    return deleteAllByIndex(r'listId_term_reading', values);
  }

  int deleteAllByListIdTermReadingSync(
    List<int> listIdValues,
    List<String> termValues,
    List<String> readingValues,
  ) {
    final len = listIdValues.length;
    assert(
      termValues.length == len && readingValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([listIdValues[i], termValues[i], readingValues[i]]);
    }

    return deleteAllByIndexSync(r'listId_term_reading', values);
  }

  Future<Id> putByListIdTermReading(WordListEntry object) {
    return putByIndex(r'listId_term_reading', object);
  }

  Id putByListIdTermReadingSync(WordListEntry object, {bool saveLinks = true}) {
    return putByIndexSync(r'listId_term_reading', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByListIdTermReading(List<WordListEntry> objects) {
    return putAllByIndex(r'listId_term_reading', objects);
  }

  List<Id> putAllByListIdTermReadingSync(
    List<WordListEntry> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'listId_term_reading',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension WordListEntryQueryWhereSort
    on QueryBuilder<WordListEntry, WordListEntry, QWhere> {
  QueryBuilder<WordListEntry, WordListEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WordListEntryQueryWhere
    on QueryBuilder<WordListEntry, WordListEntry, QWhereClause> {
  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause>
  listIdEqualToAnyTermReading(int listId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'listId_term_reading',
          value: [listId],
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause>
  listIdNotEqualToAnyTermReading(int listId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [],
                upper: [listId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [listId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [listId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [],
                upper: [listId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause>
  listIdGreaterThanAnyTermReading(int listId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'listId_term_reading',
          lower: [listId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause>
  listIdLessThanAnyTermReading(int listId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'listId_term_reading',
          lower: [],
          upper: [listId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause>
  listIdBetweenAnyTermReading(
    int lowerListId,
    int upperListId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'listId_term_reading',
          lower: [lowerListId],
          includeLower: includeLower,
          upper: [upperListId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause>
  listIdTermEqualToAnyReading(int listId, String term) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'listId_term_reading',
          value: [listId, term],
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause>
  listIdEqualToTermNotEqualToAnyReading(int listId, String term) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [listId],
                upper: [listId, term],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [listId, term],
                includeLower: false,
                upper: [listId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [listId, term],
                includeLower: false,
                upper: [listId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [listId],
                upper: [listId, term],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause>
  listIdTermReadingEqualTo(int listId, String term, String reading) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'listId_term_reading',
          value: [listId, term, reading],
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause>
  listIdTermEqualToReadingNotEqualTo(int listId, String term, String reading) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [listId, term],
                upper: [listId, term, reading],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [listId, term, reading],
                includeLower: false,
                upper: [listId, term],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [listId, term, reading],
                includeLower: false,
                upper: [listId, term],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'listId_term_reading',
                lower: [listId, term],
                upper: [listId, term, reading],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause> termEqualTo(
    String term,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'term', value: [term]),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterWhereClause> termNotEqualTo(
    String term,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'term',
                lower: [],
                upper: [term],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'term',
                lower: [term],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'term',
                lower: [term],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'term',
                lower: [],
                upper: [term],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension WordListEntryQueryFilter
    on QueryBuilder<WordListEntry, WordListEntry, QFilterCondition> {
  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  addedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'added', value: value),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  addedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'added',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  addedLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'added',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  addedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'added',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition> idEqualTo(
    Id? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  idGreaterThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  listIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'listId', value: value),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  listIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'listId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  listIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'listId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  listIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'listId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  readingEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reading',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  readingGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reading',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  readingLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reading',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  readingBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reading',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  readingStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'reading',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  readingEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'reading',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  readingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'reading',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  readingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'reading',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  readingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reading', value: ''),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  readingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'reading', value: ''),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition> termEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'term',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  termGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'term',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  termLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'term',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition> termBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'term',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  termStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'term',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  termEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'term',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  termContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'term',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition> termMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'term',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  termIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'term', value: ''),
      );
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterFilterCondition>
  termIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'term', value: ''),
      );
    });
  }
}

extension WordListEntryQueryObject
    on QueryBuilder<WordListEntry, WordListEntry, QFilterCondition> {}

extension WordListEntryQueryLinks
    on QueryBuilder<WordListEntry, WordListEntry, QFilterCondition> {}

extension WordListEntryQuerySortBy
    on QueryBuilder<WordListEntry, WordListEntry, QSortBy> {
  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> sortByAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'added', Sort.asc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> sortByAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'added', Sort.desc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> sortByListId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listId', Sort.asc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> sortByListIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listId', Sort.desc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> sortByReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.asc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> sortByReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.desc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> sortByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> sortByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }
}

extension WordListEntryQuerySortThenBy
    on QueryBuilder<WordListEntry, WordListEntry, QSortThenBy> {
  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> thenByAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'added', Sort.asc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> thenByAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'added', Sort.desc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> thenByListId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listId', Sort.asc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> thenByListIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'listId', Sort.desc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> thenByReading() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.asc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> thenByReadingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reading', Sort.desc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> thenByTerm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.asc);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QAfterSortBy> thenByTermDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'term', Sort.desc);
    });
  }
}

extension WordListEntryQueryWhereDistinct
    on QueryBuilder<WordListEntry, WordListEntry, QDistinct> {
  QueryBuilder<WordListEntry, WordListEntry, QDistinct> distinctByAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'added');
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QDistinct> distinctByListId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'listId');
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QDistinct> distinctByReading({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reading', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WordListEntry, WordListEntry, QDistinct> distinctByTerm({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'term', caseSensitive: caseSensitive);
    });
  }
}

extension WordListEntryQueryProperty
    on QueryBuilder<WordListEntry, WordListEntry, QQueryProperty> {
  QueryBuilder<WordListEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WordListEntry, int, QQueryOperations> addedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'added');
    });
  }

  QueryBuilder<WordListEntry, int, QQueryOperations> listIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'listId');
    });
  }

  QueryBuilder<WordListEntry, String, QQueryOperations> readingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reading');
    });
  }

  QueryBuilder<WordListEntry, String, QQueryOperations> termProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'term');
    });
  }
}
