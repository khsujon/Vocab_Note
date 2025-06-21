import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vocab_viewmodel.dart';
import '../widgets/vocab_card.dart';
import 'add_word_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocab Note'),
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
      ),
      body: Consumer<VocabViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }
          if (viewModel.vocabList.isEmpty) {
            return const Center(child: Text('No words added yet.'));
          }
          return ListView.builder(
            itemCount: viewModel.vocabList.length,
            itemBuilder: (context, index) {
              return VocabCard(vocab: viewModel.vocabList[index]);
            },
          );
        },
      ),
    );
  }
}
