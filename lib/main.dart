import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _dbHelper.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addNote() async {
    if (_formKey.currentState!.validate()) {
      await _dbHelper.insertNote(_noteController.text.trim());
      _noteController.clear();
      await _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your note here',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Note cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addNote,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _notes.isEmpty
                  ? const Center(child: Text('No notes yet.'))
                  : ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return ListTile(
                    title: Text(note['text']),
                    subtitle: Text(
                      'Created at: ${DateTime.parse(note['created_at']).toLocal()}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
