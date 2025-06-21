import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../viewmodels/vocab_viewmodel.dart';
import '../widgets/vocab_card.dart';
import 'add_word_screen.dart';
import 'edit_vocab_screen.dart';
import '../models/vocab_note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vocab Note',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Word',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWordScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                style: const TextStyle(fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search word...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[700],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<VocabViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }
          final filteredList = _searchQuery.isEmpty
              ? viewModel.vocabList
              : viewModel.vocabList
                  .where((vocab) =>
                      vocab.englishWord.contains(_searchQuery) ||
                      vocab.banglaTranslation.contains(_searchQuery) ||
                      vocab.synonyms.any((s) => s.contains(_searchQuery)) ||
                      vocab.antonyms.any((a) => a.contains(_searchQuery)))
                  .toList();
          if (filteredList.isEmpty) {
            return const Center(child: Text('No words found.'));
          }
          return ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final vocab = filteredList[index];
              return VocabCard(
                vocab: vocab,
                onDelete: () async {
                  final box = await Hive.openBox<VocabNote>('vocabBox');
                  await box.delete(vocab.key);
                  viewModel.loadVocabList();
                },
                onEdit: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditVocabScreen(
                        vocab: vocab,
                        onSave: (updated) async {
                          final box = await Hive.openBox<VocabNote>('vocabBox');
                          await box.put(vocab.key, updated);
                          viewModel.loadVocabList();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
