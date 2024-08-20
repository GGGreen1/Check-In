/*

import 'package:flutter/material.dart';
import 'package:sqflite_test_3/sql_helper.dart';


class AddPersonPaige extends StatefulWidget {
  //const AddPersonPaige({super.key, required this.title});

  //final String title;

  @override
  State<AddPersonPaige> createState() => _AddPersonPaige();
}

class _AddPersonPaige extends State<AddPersonPaige> {
  List<Map<String, dynamic>> _jurnals = [];

  void _refreshJournals() async {
    final data = await SQLHelper.getParticipants(course_id);
    setState(() {
      _jurnals = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    print("...number of items ${_jurnals.length}");
  }

  final TextEditingController _prenameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _matrikelnummerController =
      TextEditingController();
  int course_id = 1;
  int present = 0;

  Future<void> _addItem() async {
    await SQLHelper.createParticipant(
        _prenameController.text,
        _surnameController.text,
        _matrikelnummerController.text,
        course_id,
        present);
    _refreshJournals();
    print("...number of items ${_jurnals.length}");
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateParticipant(id, _prenameController.text,
        _surnameController.text, _matrikelnummerController.text);
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteParticipant(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted ajournal!'),
    ));
    _refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _jurnals.firstWhere((element) => element['id'] == id);
      _prenameController.text = existingJournal['prename'];
      _surnameController.text = existingJournal['surname'];
      _matrikelnummerController.text = existingJournal['matrikelnummer'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _prenameController,
                    decoration: const InputDecoration(hintText: 'Prename'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _surnameController,
                    decoration: const InputDecoration(hintText: 'Surname'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _matrikelnummerController,
                    decoration:
                        const InputDecoration(hintText: 'Matrikelnummer'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addItem();
                        }
                        if (id != null) {
                          await _updateItem(id);
                        }

                        _prenameController.text = '';
                        _surnameController.text = '';
                        _matrikelnummerController.text = '';

                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'))
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL'),
      ),
      body: ListView.builder(
        itemCount: _jurnals.length,
        itemBuilder: (context, index) => Card(
          color: Colors.orange[200],
          margin: const EdgeInsets.all(15),
          child: ListTile(
            title: Text(_jurnals[index]['prename']),
            subtitle: Row(
              children: [
                Text(_jurnals[index]['surname']),
                const SizedBox(
                  width: 20,
                ),
                Text(_jurnals[index]['matrikelnummer']),
                Text('Course Id: ${_jurnals[index]['course_id']}'),
              ],
            ),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showForm(_jurnals[index]['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteItem(_jurnals[index]['id']),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}

*/
