import 'package:flutter/material.dart';
import '../models/vocab_note.dart';

class EditVocabScreen extends StatefulWidget {
  final VocabNote vocab;
  final void Function(VocabNote updatedVocab) onSave;
  const EditVocabScreen({Key? key, required this.vocab, required this.onSave})
      : super(key: key);

  @override
  State<EditVocabScreen> createState() => _EditVocabScreenState();
}

class _EditVocabScreenState extends State<EditVocabScreen> {
  late TextEditingController _englishController;
  late TextEditingController _banglaController;
  late TextEditingController _posController;
  late TextEditingController _synonymsController;
  late TextEditingController _antonymsController;

  @override
  void initState() {
    super.initState();
    _englishController = TextEditingController(text: widget.vocab.englishWord);
    _banglaController =
        TextEditingController(text: widget.vocab.banglaTranslation);
    _posController = TextEditingController(text: widget.vocab.partOfSpeech);
    _synonymsController =
        TextEditingController(text: widget.vocab.synonyms.join(", "));
    _antonymsController =
        TextEditingController(text: widget.vocab.antonyms.join(", "));
  }

  @override
  void dispose() {
    _englishController.dispose();
    _banglaController.dispose();
    _posController.dispose();
    _synonymsController.dispose();
    _antonymsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Vocab')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _englishController,
              decoration: const InputDecoration(labelText: 'English Word'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _banglaController,
              decoration:
                  const InputDecoration(labelText: 'Bangla Translation'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _posController,
              decoration: const InputDecoration(labelText: 'Part of Speech'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _synonymsController,
              decoration: const InputDecoration(
                  labelText: 'Synonyms (comma separated)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _antonymsController,
              decoration: const InputDecoration(
                  labelText: 'Antonyms (comma separated)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final updated = VocabNote(
                  englishWord: _englishController.text.trim().toLowerCase(),
                  banglaTranslation: _banglaController.text.trim(),
                  partOfSpeech: _posController.text.trim(),
                  synonyms: _synonymsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  antonyms: _antonymsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  createdDate: widget
                      .vocab.createdDate, // Preserve original creation date
                );
                widget.onSave(updated);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
