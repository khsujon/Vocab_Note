import 'package:flutter/material.dart';
import '../models/vocab_note.dart';

class VocabCard extends StatefulWidget {
  final VocabNote vocab;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  const VocabCard({Key? key, required this.vocab, this.onDelete, this.onEdit})
      : super(key: key);

  @override
  State<VocabCard> createState() => _VocabCardState();
}

class _VocabCardState extends State<VocabCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 4, horizontal: 12), // Reduced margin
      child: InkWell(
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },
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
                          widget.vocab.englishWord,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium, // Smaller text
                        ),
                        const SizedBox(height: 4), // Reduced spacing
                        Text(
                          'Bangla: ${widget.vocab.banglaTranslation}',
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
                        onPressed: widget.onEdit,
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
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && widget.onDelete != null) {
                            widget.onDelete!();
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
                child: _expanded
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: widget.vocab.partOfSpeech),
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
                                TextSpan(
                                    text: widget.vocab.synonyms.join(", ")),
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
                                TextSpan(
                                    text: widget.vocab.antonyms.join(", ")),
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
  }
}
