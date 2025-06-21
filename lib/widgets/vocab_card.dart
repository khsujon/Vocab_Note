import 'package:flutter/material.dart';
import '../models/vocab_note.dart';

class VocabCard extends StatelessWidget {
  final VocabNote vocab;
  const VocabCard({Key? key, required this.vocab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vocab.englishWord,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Bangla: ${vocab.banglaTranslation}'),
            Text('Part of Speech: ${vocab.partOfSpeech}'),
            Text('Synonyms: ${vocab.synonyms.join(", ")}'),
            Text('Antonyms: ${vocab.antonyms.join(", ")}'),
          ],
        ),
      ),
    );
  }
}
