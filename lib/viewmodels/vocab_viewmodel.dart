import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/vocab_note.dart';
import '../services/dictionary_service.dart';

class VocabViewModel extends ChangeNotifier {
  final DictionaryService _dictionaryService = DictionaryService();
  List<VocabNote> _vocabList = [];
  bool _isLoading = false;
  String? _error;

  // Date grouping and expansion state
  Map<String, List<VocabNote>> _groupedVocab = {};
  Set<String> _expandedDates = {};

  List<VocabNote> get vocabList => _vocabList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, List<VocabNote>> get groupedVocab => _groupedVocab;
  Set<String> get expandedDates => _expandedDates;

  Future<void> loadVocabList() async {
    final box = await Hive.openBox<VocabNote>('vocabBox');
    _vocabList = box.values.toList();

    // Migrate existing entries that don't have createdDate
    await _migrateExistingEntries(box);

    _groupVocabByDate();
    notifyListeners();
  }

  Future<void> _migrateExistingEntries(Box<VocabNote> box) async {
    bool needsMigration = false;
    for (var vocab in _vocabList) {
      try {
        // Check if createdDate exists, if not, it will throw an error
        vocab.createdDate;
      } catch (e) {
        // If createdDate doesn't exist, set it to now and save
        final migratedVocab = VocabNote(
          englishWord: vocab.englishWord,
          banglaTranslation: vocab.banglaTranslation,
          partOfSpeech: vocab.partOfSpeech,
          synonyms: vocab.synonyms,
          antonyms: vocab.antonyms,
          createdDate: DateTime.now(),
        );
        await box.put(vocab.key, migratedVocab);
        needsMigration = true;
      }
    }

    if (needsMigration) {
      _vocabList = box.values.toList();
    }
  }

  void _groupVocabByDate() {
    _groupedVocab.clear();
    for (var vocab in _vocabList) {
      final dateKey = _formatDateKey(vocab.createdDate);
      if (_groupedVocab.containsKey(dateKey)) {
        _groupedVocab[dateKey]!.add(vocab);
      } else {
        _groupedVocab[dateKey] = [vocab];
      }
    }
    // Sort dates in descending order (newest first)
    _groupedVocab = Map.fromEntries(
        _groupedVocab.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String formatDateDisplay(String dateKey) {
    final parts = dateKey.split('-');
    final date =
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  void toggleDateExpansion(String dateKey) {
    if (_expandedDates.contains(dateKey)) {
      _expandedDates.remove(dateKey);
    } else {
      _expandedDates.add(dateKey);
    }
    notifyListeners();
  }

  bool isDateExpanded(String dateKey) {
    return _expandedDates.contains(dateKey);
  }

  List<String> getFilteredDates(String searchQuery) {
    if (searchQuery.isEmpty) {
      return _groupedVocab.keys.toList();
    }

    return _groupedVocab.entries
        .where((entry) {
          return entry.value.any((vocab) =>
              vocab.englishWord
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              vocab.banglaTranslation
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              vocab.synonyms.any(
                  (s) => s.toLowerCase().contains(searchQuery.toLowerCase())) ||
              vocab.antonyms.any(
                  (a) => a.toLowerCase().contains(searchQuery.toLowerCase())));
        })
        .map((entry) => entry.key)
        .toList();
  }

  List<VocabNote> getFilteredWordsForDate(String dateKey, String searchQuery) {
    final words = _groupedVocab[dateKey] ?? [];
    if (searchQuery.isEmpty) {
      return words;
    }

    return words
        .where((vocab) =>
            vocab.englishWord
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            vocab.banglaTranslation
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            vocab.synonyms.any(
                (s) => s.toLowerCase().contains(searchQuery.toLowerCase())) ||
            vocab.antonyms.any(
                (a) => a.toLowerCase().contains(searchQuery.toLowerCase())))
        .toList();
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
        createdDate: DateTime.now(),
      );
      await box.add(vocab);
      _vocabList = box.values.toList();
      _groupVocabByDate();
    } catch (e) {
      _error = 'Error fetching word';
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
