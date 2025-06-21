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
}
