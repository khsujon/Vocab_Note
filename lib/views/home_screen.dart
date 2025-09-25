import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../viewmodels/vocab_viewmodel.dart';
import '../widgets/vocab_card.dart';
import '../widgets/date_group_header.dart';
import 'add_word_screen.dart';
import 'edit_vocab_screen.dart';
import '../models/vocab_note.dart';

class HomeScreenViewModel extends ChangeNotifier {
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearchQuery(String value) {
    _searchQuery = value.trim().toLowerCase();
    notifyListeners();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeScreenViewModel(),
      child: const _HomeScreenBody(),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vocab Note',
          style: TextStyle(
            color: Colors.white,
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
            child: Consumer<HomeScreenViewModel>(
              builder: (context, homeViewModel, _) {
                return SizedBox(
                  height: 40,
                  child: TextField(
                    controller: searchController,
                    onChanged: homeViewModel.setSearchQuery,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search word...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.blue[700],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer2<VocabViewModel, HomeScreenViewModel>(
        builder: (context, vocabViewModel, homeViewModel, child) {
          if (vocabViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vocabViewModel.error != null) {
            return Center(child: Text(vocabViewModel.error!));
          }

          final filteredDates =
              vocabViewModel.getFilteredDates(homeViewModel.searchQuery);

          if (filteredDates.isEmpty) {
            return const Center(child: Text('No words found.'));
          }

          return ListView.builder(
            itemCount: filteredDates.length,
            itemBuilder: (context, index) {
              final dateKey = filteredDates[index];
              final wordsForDate = vocabViewModel.getFilteredWordsForDate(
                  dateKey, homeViewModel.searchQuery);
              final isExpanded = vocabViewModel.isDateExpanded(dateKey);

              return Column(
                children: [
                  DateGroupHeader(
                    dateDisplay: vocabViewModel.formatDateDisplay(dateKey),
                    wordCount: wordsForDate.length,
                    isExpanded: isExpanded,
                    onTap: () => vocabViewModel.toggleDateExpansion(dateKey),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedOpacity(
                      opacity: isExpanded ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: isExpanded
                          ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children:
                                    wordsForDate.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final vocab = entry.value;
                                  return AnimatedContainer(
                                    duration: Duration(
                                        milliseconds: 300 + (idx * 50)),
                                    curve: Curves.easeOutBack,
                                    transform: Matrix4.translationValues(
                                      isExpanded ? 0 : -50,
                                      0,
                                      0,
                                    ),
                                    child: VocabCard(
                                      vocab: vocab,
                                      onDelete: () async {
                                        final box =
                                            await Hive.openBox<VocabNote>(
                                                'vocabBox');
                                        await box.delete(vocab.key);
                                        vocabViewModel.loadVocabList();
                                      },
                                      onEdit: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditVocabScreen(
                                              vocab: vocab,
                                              onSave: (updated) async {
                                                final box = await Hive.openBox<
                                                    VocabNote>('vocabBox');
                                                await box.put(
                                                    vocab.key, updated);
                                                vocabViewModel.loadVocabList();
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
