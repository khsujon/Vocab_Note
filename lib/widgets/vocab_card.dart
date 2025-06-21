import 'package:flutter/material.dart';
import '../models/vocab_note.dart';

class VocabCard extends StatefulWidget {
  final VocabNote vocab;
  const VocabCard({Key? key, required this.vocab}) : super(key: key);

  @override
  State<VocabCard> createState() => _VocabCardState();
}

class _VocabCardState extends State<VocabCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.vocab.englishWord,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Bangla: ${widget.vocab.banglaTranslation}'),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _expanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text('Part of Speech: ${widget.vocab.partOfSpeech}'),
                          Text('Synonyms: ${widget.vocab.synonyms.join(", ")}'),
                          Text('Antonyms: ${widget.vocab.antonyms.join(", ")}'),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
