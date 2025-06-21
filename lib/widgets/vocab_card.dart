import 'package:flutter/material.dart';
import '../models/vocab_note.dart';
import 'package:provider/provider.dart';

class VocabCardViewModel extends ChangeNotifier {
  bool _expanded = false;
  bool get expanded => _expanded;
  void toggleExpanded() {
    _expanded = !_expanded;
    notifyListeners();
  }
}

class VocabCard extends StatelessWidget {
  final VocabNote vocab;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  const VocabCard({Key? key, required this.vocab, this.onDelete, this.onEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VocabCardViewModel(),
      child: Consumer<VocabCardViewModel>(
        builder: (context, cardViewModel, _) {
          return Card(
            margin: const EdgeInsets.symmetric(
                vertical: 4, horizontal: 12), // Reduced margin
            child: InkWell(
              onTap: cardViewModel.toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.all(10.0), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vocab.englishWord,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium, // Smaller text
                              ),
                              const SizedBox(height: 4), // Reduced spacing
                              Text(
                                'Bangla: ${vocab.banglaTranslation}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Move edit and delete buttons here
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blue, size: 18), // Smaller icon
                              tooltip: 'Edit',
                              onPressed: onEdit,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 18), // Smaller icon
                              tooltip: 'Delete',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Word'),
                                    content: const Text(
                                        'Are you sure you want to delete this word?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true && onDelete != null) {
                                  onDelete!();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: cardViewModel.expanded
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4), // Reduced spacing
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    children: [
                                      const TextSpan(
                                        text: 'Part of Speech: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: vocab.partOfSpeech),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    children: [
                                      const TextSpan(
                                        text: 'Synonyms: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      TextSpan(text: vocab.synonyms.join(", ")),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    children: [
                                      const TextSpan(
                                        text: 'Antonyms: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      TextSpan(text: vocab.antonyms.join(", ")),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
