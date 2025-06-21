import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vocab_viewmodel.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({Key? key}) : super(key: key);

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final TextEditingController _controller = TextEditingController();

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
            viewModel.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (_controller.text.isNotEmpty) {
                        final word = _controller.text.trim().toLowerCase();
                        await viewModel.addWord(word);
                        if (viewModel.error == null) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('Add'),
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
