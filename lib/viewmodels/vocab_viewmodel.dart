import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/vocab_note.dart';
import '../services/dictionary_service.dart';

class VocabViewModel extends ChangeNotifier {
  final DictionaryService _dictionaryService = DictionaryService();
  List<VocabNote> _vocabList = [];
  bool _isLoading = false;
  String? _error;

  List<VocabNote> get vocabList => _vocabList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVocabList() async {
    final box = await Hive.openBox<VocabNote>('vocabBox');
    _vocabList = box.values.toList();
    notifyListeners();
  }

  Future<bool> addWord(String word) async {
    word = word.toLowerCase();
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final box = await Hive.openBox<VocabNote>('vocabBox');
      final exists = box.values.any((v) => v.englishWord == word);
      if (exists) {
        _isLoading = false;
        notifyListeners();
        return false; // Word already exists
      }
      final data = await _dictionaryService.fetchWordData(word);
      if (data == null) {
        _error = 'Word not found';
        _isLoading = false;
        notifyListeners();
        return true;
      }
      final meanings = data['meanings'] as List?;
      final partOfSpeech = meanings != null && meanings.isNotEmpty
          ? meanings[0]['partOfSpeech'] ?? 'N/A'
          : 'N/A';
      final synonyms = meanings != null && meanings.isNotEmpty
          ? _dictionaryService.extractSynonyms(meanings)
          : [];
      final antonyms = meanings != null && meanings.isNotEmpty
          ? _dictionaryService.extractAntonyms(meanings)
          : [];
      final bangla =
          await _dictionaryService.fetchBanglaTranslation(word) ?? 'N/A';
      final vocab = VocabNote(
        englishWord: word,
        banglaTranslation: bangla,
        partOfSpeech: partOfSpeech,
        synonyms: synonyms.isNotEmpty ? List<String>.from(synonyms) : ['N/A'],
        antonyms: antonyms.isNotEmpty ? List<String>.from(antonyms) : ['N/A'],
      );
      await box.add(vocab);
      _vocabList = box.values.toList();
    } catch (e) {
      _error = 'Error fetching word';
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
