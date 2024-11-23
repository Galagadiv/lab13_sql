import 'package:flutter/material.dart';
import '../db_helper.dart';
import 'package:intl/intl.dart';
// Без мілісекунд /\

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

//управління станом екрану
class _NotesScreenState extends State<NotesScreen> {
  //ключ форми що дозволяє нею керувати
  final _formKey = GlobalKey<FormState>();

  //для інпута
  final _noteController = TextEditingController();
  //екземпляр класу
  final DatabaseHelper _dbHelper = DatabaseHelper();
  //список нотаток
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  //отримує нотатки
  Future<void> _loadNotes() async {
    final notes = await _dbHelper.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  //додавання запису
  Future<void> _addNote() async {
    //чи заповнене поле?
    if (_formKey.currentState!.validate()) {
      await _dbHelper.insertNote(_noteController.text.trim());
      //очищає поле
      _noteController.clear();
      //одразу виводить
      await _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(203, 177, 250, 1),
        title: Container(
          alignment: Alignment.center,
          child: const Text('Notes App'),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(13.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                  //INPUT NOTE
                    Expanded(
                    child: TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your note here',
                        border: OutlineInputBorder(),
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
                  // SUBMIT BUTTON
                    FilledButton(
                      onPressed: _addNote,
                      child: const Text('Add'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(203, 177, 250, 1),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _notes.isEmpty
                  ? const Center(child: Text('No notes yet.'))
                  : ListView.builder(
                  itemCount: _notes.length,
                  //як будуватиметься кожен item
                  itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(244, 236, 247, 1),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(note['text']),
                      subtitle: Text(
                        '${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(note['created_at']).toLocal())}',
                        textAlign: TextAlign.right,
                      ),
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