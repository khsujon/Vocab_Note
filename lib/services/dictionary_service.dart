import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bangla_dictionary/flutter_bangla_dictionary.dart';

class DictionaryService {
  Future<Map<String, dynamic>?> fetchWordData(String word) async {
    final url = 'https://api.dictionaryapi.dev/api/v2/entries/en/$word';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        return data[0];
      }
    }
    return null;
  }

  Future<String?> fetchBanglaTranslation(String word) async {
    final result = await FlutterBanglaDictionary.searchWord(word);
    return result;
  }

  // Extract all unique synonyms from all meanings and definitions
  List<String> extractSynonyms(List<dynamic> meanings) {
    final Set<String> allSynonyms = {};
    for (var meaning in meanings) {
      if (meaning['synonyms'] != null) {
        allSynonyms.addAll(List<String>.from(meaning['synonyms']));
      }
      if (meaning['definitions'] != null) {
        for (var def in meaning['definitions']) {
          if (def['synonyms'] != null) {
            allSynonyms.addAll(List<String>.from(def['synonyms']));
          }
        }
      }
    }
    return allSynonyms.toList();
  }

  // Extract all unique antonyms from all meanings and definitions
  List<String> extractAntonyms(List<dynamic> meanings) {
    final Set<String> allAntonyms = {};
    for (var meaning in meanings) {
      if (meaning['antonyms'] != null) {
        allAntonyms.addAll(List<String>.from(meaning['antonyms']));
      }
      if (meaning['definitions'] != null) {
        for (var def in meaning['definitions']) {
          if (def['antonyms'] != null) {
            allAntonyms.addAll(List<String>.from(def['antonyms']));
          }
        }
      }
    }
    return allAntonyms.toList();
  }
}
