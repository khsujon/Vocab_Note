import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vocab_viewmodel.dart';
import '../services/dictionary_service.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({Key? key}) : super(key: key);

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _bangla;
  String? _partOfSpeech;
  String? _error;
  bool _searching = false;

  Future<void> _searchWord(BuildContext context) async {
    setState(() {
      _searching = true;
      _bangla = null;
      _partOfSpeech = null;
      _error = null;
    });
    final word = _controller.text.trim().toLowerCase();
    if (word.isEmpty) {
      setState(() {
        _error = 'Please enter a word.';
        _searching = false;
      });
      return;
    }
    final dictService = DictionaryService();
    final data = await dictService.fetchWordData(word);
    if (data == null) {
      setState(() {
        _error = 'Word not found.';
        _searching = false;
      });
      return;
    }
    final meanings = data['meanings'] as List?;
    final partOfSpeech = meanings != null && meanings.isNotEmpty
        ? meanings[0]['partOfSpeech'] ?? 'N/A'
        : 'N/A';
    final bangla = await dictService.fetchBanglaTranslation(word) ?? 'N/A';
    setState(() {
      _bangla = bangla;
      _partOfSpeech = partOfSpeech;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VocabViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Word')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'English Word',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _searching ? null : () => _searchWord(context),
                    label: _searching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Search'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (_controller.text.isNotEmpty) {
                              final word =
                                  _controller.text.trim().toLowerCase();
                              await viewModel.addWord(word);
                              if (viewModel.error == null) {
                                Navigator.pop(context);
                              }
                            }
                          },
                    label: viewModel.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Add'),
                  ),
                ),
              ],
            ),
            if (_bangla != null || _partOfSpeech != null)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_bangla != null)
                      Text('Bangla: $_bangla',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    if (_partOfSpeech != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Part of Speech: $_partOfSpeech',
                            style: const TextStyle(fontSize: 15)),
                      ),
                  ],
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (viewModel.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(viewModel.error!,
                    style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
