// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_gloss.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDictionaryGlossCollection on Isar {
  IsarCollection<DictionaryGloss> get dictionaryGloss => this.collection();
}

const DictionaryGlossSchema = CollectionSchema(
  name: r'DictionaryGloss',
  id: -8092875381417524919,
  properties: {
    r'dictionaryId': PropertySchema(
      id: 0,
      name: r'dictionaryId',
      type: IsarType.long,
    ),
    r'entryId': PropertySchema(id: 1, name: r'entryId', type: IsarType.long),
    r'glosses': PropertySchema(
      id: 2,
      name: r'glosses',
      type: IsarType.stringList,
    ),
    r'words': PropertySchema(id: 3, name: r'words', type: IsarType.stringList),
  },

  estimateSize: _dictionaryGlossEstimateSize,
  serialize: _dictionaryGlossSerialize,
  deserialize: _dictionaryGlossDeserialize,
  deserializeProp: _dictionaryGlossDeserializeProp,
  idName: r'id',
  indexes: {
    r'entryId': IndexSchema(
      id: 3733379884318738402,
      name: r'entryId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entryId',
          type: IndexType.value,
          caseSensitive: false,
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
    r'words': IndexSchema(
      id: -8729652909246617716,
      name: r'words',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'words',
          type: IndexType.value,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _dictionaryGlossGetId,
  getLinks: _dictionaryGlossGetLinks,
  attach: _dictionaryGlossAttach,
  version: '3.3.2',
);

int _dictionaryGlossEstimateSize(
  DictionaryGloss object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.glosses.length * 3;
  {
    for (var i = 0; i < object.glosses.length; i++) {
      final value = object.glosses[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.words.length * 3;
  {
    for (var i = 0; i < object.words.length; i++) {
      final value = object.words[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _dictionaryGlossSerialize(
  DictionaryGloss object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.dictionaryId);
  writer.writeLong(offsets[1], object.entryId);
  writer.writeStringList(offsets[2], object.glosses);
  writer.writeStringList(offsets[3], object.words);
}

DictionaryGloss _dictionaryGlossDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DictionaryGloss(
    dictionaryId: reader.readLong(offsets[0]),
    entryId: reader.readLong(offsets[1]),
    glosses: reader.readStringList(offsets[2]) ?? [],
    id: id,
    words: reader.readStringList(offsets[3]) ?? [],
  );
  return object;
}

P _dictionaryGlossDeserializeProp<P>(
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
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dictionaryGlossGetId(DictionaryGloss object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _dictionaryGlossGetLinks(DictionaryGloss object) {
  return [];
}

void _dictionaryGlossAttach(
  IsarCollection<dynamic> col,
  Id id,
  DictionaryGloss object,
) {
  object.id = id;
}

extension DictionaryGlossQueryWhereSort
    on QueryBuilder<DictionaryGloss, DictionaryGloss, QWhere> {
  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhere> anyEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'entryId'),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhere>
  anyDictionaryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dictionaryId'),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhere>
  anyWordsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'words'),
      );
    });
  }
}

extension DictionaryGlossQueryWhere
    on QueryBuilder<DictionaryGloss, DictionaryGloss, QWhereClause> {
  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause> idBetween(
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  entryIdEqualTo(int entryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'entryId', value: [entryId]),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  entryIdNotEqualTo(int entryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [],
                upper: [entryId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [entryId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [entryId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entryId',
                lower: [],
                upper: [entryId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  entryIdGreaterThan(int entryId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entryId',
          lower: [entryId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  entryIdLessThan(int entryId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entryId',
          lower: [],
          upper: [entryId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  entryIdBetween(
    int lowerEntryId,
    int upperEntryId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entryId',
          lower: [lowerEntryId],
          includeLower: includeLower,
          upper: [upperEntryId],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  wordsElementEqualTo(String wordsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'words', value: [wordsElement]),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  wordsElementNotEqualTo(String wordsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'words',
                lower: [],
                upper: [wordsElement],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'words',
                lower: [wordsElement],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'words',
                lower: [wordsElement],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'words',
                lower: [],
                upper: [wordsElement],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  wordsElementGreaterThan(String wordsElement, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'words',
          lower: [wordsElement],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  wordsElementLessThan(String wordsElement, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'words',
          lower: [],
          upper: [wordsElement],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  wordsElementBetween(
    String lowerWordsElement,
    String upperWordsElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'words',
          lower: [lowerWordsElement],
          includeLower: includeLower,
          upper: [upperWordsElement],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  wordsElementStartsWith(String WordsElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'words',
          lower: [WordsElementPrefix],
          upper: ['$WordsElementPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  wordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'words', value: ['']),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterWhereClause>
  wordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'words', upper: ['']),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(indexName: r'words', lower: ['']),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(indexName: r'words', lower: ['']),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'words', upper: ['']),
            );
      }
    });
  }
}

extension DictionaryGlossQueryFilter
    on QueryBuilder<DictionaryGloss, DictionaryGloss, QFilterCondition> {
  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  dictionaryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dictionaryId', value: value),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  entryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entryId', value: value),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  entryIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  entryIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  entryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'glosses',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'glosses',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'glosses',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'glosses',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'glosses',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'glosses',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'glosses',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'glosses',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'glosses', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'glosses', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'glosses', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'glosses', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'glosses', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'glosses', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'glosses', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  glossesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'glosses',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
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

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'words',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'words',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'words',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'words',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'words',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'words',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'words',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'words',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'words', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'words', value: ''),
      );
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'words', length, true, length, true);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'words', 0, true, 0, true);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'words', 0, false, 999999, true);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'words', 0, true, length, include);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'words', length, include, 999999, true);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterFilterCondition>
  wordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'words',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension DictionaryGlossQueryObject
    on QueryBuilder<DictionaryGloss, DictionaryGloss, QFilterCondition> {}

extension DictionaryGlossQueryLinks
    on QueryBuilder<DictionaryGloss, DictionaryGloss, QFilterCondition> {}

extension DictionaryGlossQuerySortBy
    on QueryBuilder<DictionaryGloss, DictionaryGloss, QSortBy> {
  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterSortBy>
  sortByDictionaryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryId', Sort.asc);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterSortBy>
  sortByDictionaryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryId', Sort.desc);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterSortBy> sortByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.asc);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterSortBy>
  sortByEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.desc);
    });
  }
}

extension DictionaryGlossQuerySortThenBy
    on QueryBuilder<DictionaryGloss, DictionaryGloss, QSortThenBy> {
  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterSortBy>
  thenByDictionaryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryId', Sort.asc);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterSortBy>
  thenByDictionaryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dictionaryId', Sort.desc);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterSortBy> thenByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.asc);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterSortBy>
  thenByEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryId', Sort.desc);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension DictionaryGlossQueryWhereDistinct
    on QueryBuilder<DictionaryGloss, DictionaryGloss, QDistinct> {
  QueryBuilder<DictionaryGloss, DictionaryGloss, QDistinct>
  distinctByDictionaryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dictionaryId');
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QDistinct>
  distinctByEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryId');
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QDistinct>
  distinctByGlosses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'glosses');
    });
  }

  QueryBuilder<DictionaryGloss, DictionaryGloss, QDistinct> distinctByWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'words');
    });
  }
}

extension DictionaryGlossQueryProperty
    on QueryBuilder<DictionaryGloss, DictionaryGloss, QQueryProperty> {
  QueryBuilder<DictionaryGloss, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DictionaryGloss, int, QQueryOperations> dictionaryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dictionaryId');
    });
  }

  QueryBuilder<DictionaryGloss, int, QQueryOperations> entryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryId');
    });
  }

  QueryBuilder<DictionaryGloss, List<String>, QQueryOperations>
  glossesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'glosses');
    });
  }

  QueryBuilder<DictionaryGloss, List<String>, QQueryOperations>
  wordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'words');
    });
  }
}
