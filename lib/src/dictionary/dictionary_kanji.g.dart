// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_kanji.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDictionaryKanjiCollection on Isar {
  IsarCollection<DictionaryKanji> get dictionaryKanjis => this.collection();
}

const DictionaryKanjiSchema = CollectionSchema(
  name: r'DictionaryKanji',
  id: -4120696838533718034,
  properties: {
    r'character': PropertySchema(
      id: 0,
      name: r'character',
      type: IsarType.string,
    ),
    r'dictionaryId': PropertySchema(
      id: 1,
      name: r'dictionaryId',
      type: IsarType.long,
    ),
    r'kunyomi': PropertySchema(
      id: 2,
      name: r'kunyomi',
      type: IsarType.stringList,
    ),
    r'meanings': PropertySchema(
      id: 3,
      name: r'meanings',
      type: IsarType.stringList,
    ),
    r'onyomi': PropertySchema(
      id: 4,
      name: r'onyomi',
      type: IsarType.stringList,
    ),
    r'statKeys': PropertySchema(
      id: 5,
      name: r'statKeys',
      type: IsarType.stringList,
    ),
    r'statValues': PropertySchema(
      id: 6,
      name: r'statValues',
      type: IsarType.stringList,
    ),
    r'tags': PropertySchema(id: 7, name: r'tags', type: IsarType.stringList),
  },

  estimateSize: _dictionaryKanjiEstimateSize,
  serialize: _dictionaryKanjiSerialize,
  deserialize: _dictionaryKanjiDeserialize,
  deserializeProp: _dictionaryKanjiDeserializeProp,
  idName: r'id',
  indexes: {
    r'character': IndexSchema(
      id: 1564562395447198696,
      name: r'character',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'character',
          type: IndexType.value,
          caseSensitive: true,
        ),
      ],
    ),
    r'dictionaryId': IndexSchema(
      id: 3926511253275933290,
      name: r'dictionaryId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dictionaryId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _dictionaryKanjiGetId,
  getLinks: _dictionaryKanjiGetLinks,
  attach: _dictionaryKanjiAttach,
  version: '3.3.2',
);

int _dictionaryKanjiEstimateSize(
  DictionaryKanji object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.character.length * 3;
  bytesCount += 3 + object.kunyomi.length * 3;
  {
    for (var i = 0; i < object.kunyomi.length; i++) {
      final value = object.kunyomi[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.meanings.length * 3;
  {
    for (var i = 0; i < object.meanings.length; i++) {
      final value = object.meanings[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.onyomi.length * 3;
  {
    for (var i = 0; i < object.onyomi.length; i++) {
      final value = object.onyomi[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.statKeys.length * 3;
  {
    for (var i = 0; i < object.statKeys.length; i++) {
      final value = object.statKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.statValues.length * 3;
  {
    for (var i = 0; i < object.statValues.length; i++) {
      final value = object.statValues[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _dictionaryKanjiSerialize(
  DictionaryKanji object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.character);
  writer.writeLong(offsets[1], object.dictionaryId);
  writer.writeStringList(offsets[2], object.kunyomi);
  writer.writeStringList(offsets[3], object.meanings);
  writer.writeStringList(offsets[4], object.onyomi);
  writer.writeStringList(offsets[5], object.statKeys);
  writer.writeStringList(offsets[6], object.statValues);
  writer.writeStringList(offsets[7], object.tags);
}

DictionaryKanji _dictionaryKanjiDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DictionaryKanji(
    character: reader.readString(offsets[0]),
    dictionaryId: reader.readLong(offsets[1]),
    id: id,
    kunyomi: reader.readStringList(offsets[2]) ?? [],
    meanings: reader.readStringList(offsets[3]) ?? [],
    onyomi: reader.readStringList(offsets[4]) ?? [],
    statKeys: reader.readStringList(offsets[5]) ?? [],
    statValues: reader.readStringList(offsets[6]) ?? [],
    tags: reader.readStringList(offsets[7]) ?? [],
  );
  return object;
}

P _dictionaryKanjiDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryKanjiGetId(DictionaryKanji object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dictionaryKanjiGetLinks(DictionaryKanji object) {
  return [];
}

void _dictionaryKanjiAttach(
  IsarCollection<dynamic> col,
  Id id,
  DictionaryKanji object,
) {
  object.id = id;
}

extension DictionaryKanjiQueryWhereSort
    on QueryBuilder<DictionaryKanji, DictionaryKanji, QWhere> {
  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhere> anyCharacter() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'character'),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhere>
  anyDictionaryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dictionaryId'),
      );
    });
  }
}

extension DictionaryKanjiQueryWhere
    on QueryBuilder<DictionaryKanji, DictionaryKanji, QWhereClause> {
  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause> idBetween(
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

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  characterEqualTo(String character) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'character', value: [character]),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  characterNotEqualTo(String character) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'character',
                lower: [],
                upper: [character],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'character',
                lower: [character],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'character',
                lower: [character],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'character',
                lower: [],
                upper: [character],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  characterGreaterThan(String character, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'character',
          lower: [character],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  characterLessThan(String character, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'character',
          lower: [],
          upper: [character],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  characterBetween(
    String lowerCharacter,
    String upperCharacter, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'character',
          lower: [lowerCharacter],
          includeLower: includeLower,
          upper: [upperCharacter],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  characterStartsWith(String CharacterPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'character',
          lower: [CharacterPrefix],
          upper: ['$CharacterPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  characterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'character', value: ['']),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  characterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'character', upper: ['']),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'character',
                lower: [''],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'character',
                lower: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'character', upper: ['']),
            );
      }
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  dictionaryIdEqualTo(int dictionaryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'dictionaryId',
          value: [dictionaryId],
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  dictionaryIdNotEqualTo(int dictionaryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dictionaryId',
                lower: [],
                upper: [dictionaryId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dictionaryId',
                lower: [dictionaryId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dictionaryId',
                lower: [dictionaryId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dictionaryId',
                lower: [],
                upper: [dictionaryId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  dictionaryIdGreaterThan(int dictionaryId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dictionaryId',
          lower: [dictionaryId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  dictionaryIdLessThan(int dictionaryId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dictionaryId',
          lower: [],
          upper: [dictionaryId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterWhereClause>
  dictionaryIdBetween(
    int lowerDictionaryId,
    int upperDictionaryId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dictionaryId',
          lower: [lowerDictionaryId],
          includeLower: includeLower,
          upper: [upperDictionaryId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DictionaryKanjiQueryFilter
    on QueryBuilder<DictionaryKanji, DictionaryKanji, QFilterCondition> {
  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  characterEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'character',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  characterGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'character',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  characterLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'character',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  characterBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'character',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  characterStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'character',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  characterEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'character',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  characterContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'character',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  characterMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'character',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  characterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'character', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  characterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'character', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  dictionaryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dictionaryId', value: value),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  dictionaryIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dictionaryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  dictionaryIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dictionaryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  dictionaryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dictionaryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
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

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  idLessThan(Id? value, {bool include = false}) {
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

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kunyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kunyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kunyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kunyomi',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kunyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kunyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kunyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kunyomi',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kunyomi', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kunyomi', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kunyomi', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kunyomi', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kunyomi', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kunyomi', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kunyomi', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  kunyomiLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'kunyomi',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'meanings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'meanings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'meanings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'meanings',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'meanings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'meanings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'meanings',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'meanings',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'meanings', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'meanings', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'meanings', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'meanings', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'meanings', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'meanings', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'meanings', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  meaningsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'meanings',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'onyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'onyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'onyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'onyomi',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'onyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'onyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'onyomi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'onyomi',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'onyomi', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'onyomi', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'onyomi', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'onyomi', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'onyomi', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'onyomi', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'onyomi', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  onyomiLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'onyomi',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'statKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'statKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'statKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'statKeys',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'statKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'statKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'statKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'statKeys',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'statKeys', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'statKeys', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'statKeys', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'statKeys', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'statKeys', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'statKeys', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'statKeys', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'statKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'statValues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'statValues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'statValues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'statValues',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'statValues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'statValues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'statValues',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'statValues',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'statValues', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'statValues', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'statValues', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'statValues', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'statValues', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'statValues', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'statValues', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  statValuesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'statValues',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tags',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tags',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterFilterCondition>
  tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension DictionaryKanjiQueryObject
    on QueryBuilder<DictionaryKanji, DictionaryKanji, QFilterCondition> {}

extension DictionaryKanjiQueryLinks
    on QueryBuilder<DictionaryKanji, DictionaryKanji, QFilterCondition> {}

extension DictionaryKanjiQuerySortBy
    on QueryBuilder<DictionaryKanji, DictionaryKanji, QSortBy> {
  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterSortBy>
  sortByCharacter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'character', Sort.asc);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterSortBy>
  sortByCharacterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'character', Sort.desc);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterSortBy>
  sortByDictionaryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryId', Sort.asc);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterSortBy>
  sortByDictionaryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryId', Sort.desc);
    });
  }
}

extension DictionaryKanjiQuerySortThenBy
    on QueryBuilder<DictionaryKanji, DictionaryKanji, QSortThenBy> {
  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterSortBy>
  thenByCharacter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'character', Sort.asc);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterSortBy>
  thenByCharacterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'character', Sort.desc);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterSortBy>
  thenByDictionaryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryId', Sort.asc);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterSortBy>
  thenByDictionaryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryId', Sort.desc);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension DictionaryKanjiQueryWhereDistinct
    on QueryBuilder<DictionaryKanji, DictionaryKanji, QDistinct> {
  QueryBuilder<DictionaryKanji, DictionaryKanji, QDistinct>
  distinctByCharacter({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'character', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QDistinct>
  distinctByDictionaryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dictionaryId');
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QDistinct>
  distinctByKunyomi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kunyomi');
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QDistinct>
  distinctByMeanings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'meanings');
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QDistinct> distinctByOnyomi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onyomi');
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QDistinct>
  distinctByStatKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statKeys');
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QDistinct>
  distinctByStatValues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statValues');
    });
  }

  QueryBuilder<DictionaryKanji, DictionaryKanji, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }
}

extension DictionaryKanjiQueryProperty
    on QueryBuilder<DictionaryKanji, DictionaryKanji, QQueryProperty> {
  QueryBuilder<DictionaryKanji, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DictionaryKanji, String, QQueryOperations> characterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'character');
    });
  }

  QueryBuilder<DictionaryKanji, int, QQueryOperations> dictionaryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dictionaryId');
    });
  }

  QueryBuilder<DictionaryKanji, List<String>, QQueryOperations>
  kunyomiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kunyomi');
    });
  }

  QueryBuilder<DictionaryKanji, List<String>, QQueryOperations>
  meaningsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'meanings');
    });
  }

  QueryBuilder<DictionaryKanji, List<String>, QQueryOperations>
  onyomiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onyomi');
    });
  }

  QueryBuilder<DictionaryKanji, List<String>, QQueryOperations>
  statKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statKeys');
    });
  }

  QueryBuilder<DictionaryKanji, List<String>, QQueryOperations>
  statValuesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statValues');
    });
  }

  QueryBuilder<DictionaryKanji, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }
}
