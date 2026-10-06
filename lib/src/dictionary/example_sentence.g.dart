// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_sentence.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExampleSentenceCollection on Isar {
  IsarCollection<ExampleSentence> get exampleSentences => this.collection();
}

const ExampleSentenceSchema = CollectionSchema(
  name: r'ExampleSentence',
  id: 5737446170479935289,
  properties: {
    r'english': PropertySchema(id: 0, name: r'english', type: IsarType.string),
    r'japanese': PropertySchema(
      id: 1,
      name: r'japanese',
      type: IsarType.string,
    ),
    r'surfaces': PropertySchema(
      id: 2,
      name: r'surfaces',
      type: IsarType.stringList,
    ),
    r'words': PropertySchema(id: 3, name: r'words', type: IsarType.stringList),
  },

  estimateSize: _exampleSentenceEstimateSize,
  serialize: _exampleSentenceSerialize,
  deserialize: _exampleSentenceDeserialize,
  deserializeProp: _exampleSentenceDeserializeProp,
  idName: r'id',
  indexes: {
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

  getId: _exampleSentenceGetId,
  getLinks: _exampleSentenceGetLinks,
  attach: _exampleSentenceAttach,
  version: '3.3.2',
);

int _exampleSentenceEstimateSize(
  ExampleSentence object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.english.length * 3;
  bytesCount += 3 + object.japanese.length * 3;
  bytesCount += 3 + object.surfaces.length * 3;
  {
    for (var i = 0; i < object.surfaces.length; i++) {
      final value = object.surfaces[i];
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

void _exampleSentenceSerialize(
  ExampleSentence object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.english);
  writer.writeString(offsets[1], object.japanese);
  writer.writeStringList(offsets[2], object.surfaces);
  writer.writeStringList(offsets[3], object.words);
}

ExampleSentence _exampleSentenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExampleSentence(
    english: reader.readString(offsets[0]),
    id: id,
    japanese: reader.readString(offsets[1]),
    surfaces: reader.readStringList(offsets[2]) ?? [],
    words: reader.readStringList(offsets[3]) ?? [],
  );
  return object;
}

P _exampleSentenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _exampleSentenceGetId(ExampleSentence object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _exampleSentenceGetLinks(ExampleSentence object) {
  return [];
}

void _exampleSentenceAttach(
  IsarCollection<dynamic> col,
  Id id,
  ExampleSentence object,
) {
  object.id = id;
}

extension ExampleSentenceQueryWhereSort
    on QueryBuilder<ExampleSentence, ExampleSentence, QWhere> {
  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhere>
  anyWordsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'words'),
      );
    });
  }
}

extension ExampleSentenceQueryWhere
    on QueryBuilder<ExampleSentence, ExampleSentence, QWhereClause> {
  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause> idBetween(
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause>
  wordsElementEqualTo(String wordsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'words', value: [wordsElement]),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause>
  wordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'words', value: ['']),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterWhereClause>
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

extension ExampleSentenceQueryFilter
    on QueryBuilder<ExampleSentence, ExampleSentence, QFilterCondition> {
  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  englishEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'english',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  englishGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'english',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  englishLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'english',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  englishBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'english',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  englishStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'english',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  englishEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'english',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  englishContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'english',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  englishMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'english',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  englishIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'english', value: ''),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  englishIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'english', value: ''),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  japaneseEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'japanese',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  japaneseGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'japanese',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  japaneseLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'japanese',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  japaneseBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'japanese',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  japaneseStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'japanese',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  japaneseEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'japanese',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  japaneseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'japanese',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  japaneseMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'japanese',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  japaneseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'japanese', value: ''),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  japaneseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'japanese', value: ''),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'surfaces',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'surfaces',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'surfaces',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'surfaces',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'surfaces',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'surfaces',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'surfaces',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'surfaces',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'surfaces', value: ''),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'surfaces', value: ''),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'surfaces', length, true, length, true);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'surfaces', 0, true, 0, true);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'surfaces', 0, false, 999999, true);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'surfaces', 0, true, length, include);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'surfaces', length, include, 999999, true);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  surfacesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'surfaces',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  wordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'words', value: ''),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  wordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'words', value: ''),
      );
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  wordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'words', length, true, length, true);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  wordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'words', 0, true, 0, true);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  wordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'words', 0, false, 999999, true);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  wordsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'words', 0, true, length, include);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
  wordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'words', length, include, 999999, true);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterFilterCondition>
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

extension ExampleSentenceQueryObject
    on QueryBuilder<ExampleSentence, ExampleSentence, QFilterCondition> {}

extension ExampleSentenceQueryLinks
    on QueryBuilder<ExampleSentence, ExampleSentence, QFilterCondition> {}

extension ExampleSentenceQuerySortBy
    on QueryBuilder<ExampleSentence, ExampleSentence, QSortBy> {
  QueryBuilder<ExampleSentence, ExampleSentence, QAfterSortBy> sortByEnglish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'english', Sort.asc);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterSortBy>
  sortByEnglishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'english', Sort.desc);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterSortBy>
  sortByJapanese() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'japanese', Sort.asc);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterSortBy>
  sortByJapaneseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'japanese', Sort.desc);
    });
  }
}

extension ExampleSentenceQuerySortThenBy
    on QueryBuilder<ExampleSentence, ExampleSentence, QSortThenBy> {
  QueryBuilder<ExampleSentence, ExampleSentence, QAfterSortBy> thenByEnglish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'english', Sort.asc);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterSortBy>
  thenByEnglishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'english', Sort.desc);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterSortBy>
  thenByJapanese() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'japanese', Sort.asc);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QAfterSortBy>
  thenByJapaneseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'japanese', Sort.desc);
    });
  }
}

extension ExampleSentenceQueryWhereDistinct
    on QueryBuilder<ExampleSentence, ExampleSentence, QDistinct> {
  QueryBuilder<ExampleSentence, ExampleSentence, QDistinct> distinctByEnglish({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'english', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QDistinct> distinctByJapanese({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'japanese', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QDistinct>
  distinctBySurfaces() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surfaces');
    });
  }

  QueryBuilder<ExampleSentence, ExampleSentence, QDistinct> distinctByWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'words');
    });
  }
}

extension ExampleSentenceQueryProperty
    on QueryBuilder<ExampleSentence, ExampleSentence, QQueryProperty> {
  QueryBuilder<ExampleSentence, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExampleSentence, String, QQueryOperations> englishProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'english');
    });
  }

  QueryBuilder<ExampleSentence, String, QQueryOperations> japaneseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'japanese');
    });
  }

  QueryBuilder<ExampleSentence, List<String>, QQueryOperations>
  surfacesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surfaces');
    });
  }

  QueryBuilder<ExampleSentence, List<String>, QQueryOperations>
  wordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'words');
    });
  }
}
