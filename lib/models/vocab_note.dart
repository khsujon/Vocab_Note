import 'package:hive/hive.dart';

part 'vocab_note.g.dart';

@HiveType(typeId: 0)
class VocabNote extends HiveObject {
  @HiveField(0)
  String englishWord;

  @HiveField(1)
  String banglaTranslation;

  @HiveField(2)
  String partOfSpeech;

  @HiveField(3)
  List<String> synonyms;

  @HiveField(4)
  List<String> antonyms;

  @HiveField(5)
  DateTime createdDate;

  VocabNote({
    required this.englishWord,
    required this.banglaTranslation,
    required this.partOfSpeech,
    required this.synonyms,
    required this.antonyms,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();
}
