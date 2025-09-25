import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vocab_viewmodel.dart';
import '../services/dictionary_service.dart';

class AddWordViewModel extends ChangeNotifier {
  String? bangla;
  String? partOfSpeech;
  String? error;
  bool searching = false;

  Future<void> searchWord(String word) async {
    searching = true;
    bangla = null;
    partOfSpeech = null;
    error = null;
    notifyListeners();
    if (word.isEmpty) {
      error = 'Please enter a word.';
      searching = false;
      notifyListeners();
      return;
    }
    final dictService = DictionaryService();
    final data = await dictService.fetchWordData(word);
    if (data == null) {
      error = 'Word not found.';
      searching = false;
      notifyListeners();
      return;
    }
    final meanings = data['meanings'] as List?;
    partOfSpeech = meanings != null && meanings.isNotEmpty
        ? meanings[0]['partOfSpeech'] ?? 'N/A'
        : 'N/A';
    bangla = await dictService.fetchBanglaTranslation(word) ?? 'N/A';
    searching = false;
    notifyListeners();
  }
}

class AddWordScreen extends StatelessWidget {
  const AddWordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddWordViewModel(),
      child: const _AddWordScreenBody(),
    );
  }
}

class _AddWordScreenBody extends StatefulWidget {
  const _AddWordScreenBody({Key? key}) : super(key: key);

  @override
  State<_AddWordScreenBody> createState() => _AddWordScreenBodyState();
}

class _AddWordScreenBodyState extends State<_AddWordScreenBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VocabViewModel>(context);
    return Consumer<AddWordViewModel>(
      builder: (context, addViewModel, _) {
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
                        onPressed: addViewModel.searching
                            ? null
                            : () => addViewModel.searchWord(
                                _controller.text.trim().toLowerCase()),
                        label: addViewModel.searching
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
                                  final added = await viewModel.addWord(word);
                                  if (!added) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Word already exists in your note!'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }
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
                if (addViewModel.bangla != null ||
                    addViewModel.partOfSpeech != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (addViewModel.bangla != null)
                          Text('Bangla: ${addViewModel.bangla}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        if (addViewModel.partOfSpeech != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                                'Part of Speech: ${addViewModel.partOfSpeech}',
                                style: const TextStyle(fontSize: 15)),
                          ),
                      ],
                    ),
                  ),
                if (addViewModel.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(addViewModel.error!,
                        style: const TextStyle(color: Colors.red)),
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
      },
    );
  }
}
