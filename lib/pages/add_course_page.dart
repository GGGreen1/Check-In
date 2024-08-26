import 'package:flutter/material.dart';
import 'package:sqflite_test_3/pages/course_details_page.dart';
import 'package:sqflite_test_3/sql/sql_helper.dart';

// Seite zum Erstellen und Bearbeiten der Kurse

class AddCoursePaige extends StatefulWidget {
  //const AddPersonPaige({super.key, required this.title});

  //final String title;

  @override
  State<AddCoursePaige> createState() => _AddCoursePaige();
}

class _AddCoursePaige extends State<AddCoursePaige> {
  //////////////////////////////////////
  // Variablen und Methoden für Kurse //

  // Leere Liste der Kurse wird erstellt
  List<Map<String, dynamic>> _journals_course = [];

  // Variable speichert, ob die Kurse geladen haben
  bool _isLoading = true;

  // Methode aktualisiert die Liste der Kurse
  void _refreshJournalsCourse() async {
    // 'data' speichert die Daten, die aus der Datenbank kommen
    final data = await SQLHelper.getCourses();

    setState(() {
      // Liste der Kurse wird mit den Daten aus der Datenbank gefüllt
      _journals_course = data;
      _isLoading = false;
    });
  }

  // Wird einmal beim Aufrufen der Seite ausgeführt; Läd und aktualisiert die Kurse
  @override
  void initState() {
    super.initState();
    _refreshJournalsCourse();
    print("...number of items ${_journals_course.length}");
  }

  // Variable speichert die Eingabe des Nutzers
  final TextEditingController _nameController = TextEditingController();

  // Methode fügt neuen Kurs hinzu
  Future<void> _addItemCourse() async {
    // Zugehörige Methode in der Datenbank wird geöffnet
    await SQLHelper.createCourse(_nameController.text);

    // Liste der Kurse wird aktualisiert
    _refreshJournalsCourse();
  }

  // Methode aktualisiert Kurs
  Future<void> _updateItemCourse(int id) async {
    await SQLHelper.updateCourse(
      id,
      _nameController.text,
    );
    _refreshJournalsCourse();
  }

  // Methode löscht Kurs
  void _deleteItemCourse(int id) async {
    await SQLHelper.deleteCourse(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted ajournal!'),
    ));
    _refreshJournalsCourse();
  }

  /////////////////////////////////////////
  // Formular zum erstellen eines Kurses //
  void _showFormCourse(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals_course.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
    }

    // UI-Elemente des Formulars
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
                  // Eingabe des Kursnamen
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Kursname'),
                  ),
                  // Abstand
                  const SizedBox(
                    height: 10,
                  ),
                  // Button fügt Kurs hinzu
                  ElevatedButton(
                      onPressed: () async {
                        /*
                        Es wird überprüft, ob es den Kurs schon gibt.
                        Entweder wird er neu erstellt oder nur aktualisiert.
                        */
                        if (id == null) {
                          await _addItemCourse();
                        }
                        if (id != null) {
                          await _updateItemCourse(id);
                        }

                        // Eingabe wird zurückgesetzt
                        _nameController.text = '';
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'))
                ],
              ),
            ));
  }

  /////////////////
  // UI-Elemente //
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kurse bearbeiten'),
          backgroundColor: const Color.fromARGB(255, 0, 160, 170),
        ),
        // Liste der Kurse
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.separated(
                padding: const EdgeInsets.only(top: 10, left: 10),
                itemCount: _journals_course.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        // Kursname
                        Text(
                          _journals_course[index]['name'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        const Spacer(),
                        // Button zum bearbeiten des Kurses
                        IconButton(
                          icon: const Icon(Icons.edit),
                          // Formular zum bearbeiten wird geöffnet
                          onPressed: () =>
                              _showFormCourse(_journals_course[index]['id']),
                        ),
                        // Button zum löschen des Kurses
                        IconButton(
                          icon: const Icon(Icons.delete),
                          /* 
                          Vor dem Löschen wird noch ein Dialog angezeigt,
                          ob der Kurs wirklich gelöscht werden soll.
                          */
                          onPressed: () => showDialog(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 50, bottom: 50),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 30.0),
                                            child: Text(
                                              'Delete Course',
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style
                                                      .apply(
                                                          fontSizeFactor: 2.0),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel')),
                                              OutlinedButton(
                                                  // Methode zum löschen des Kurses wird aufgerufen
                                                  onPressed: () => {
                                                        _deleteItemCourse(
                                                            _journals_course[
                                                                index]['id']),
                                                        Navigator.pop(context),
                                                      },
                                                  child: const Text('Delete')),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                        ),
                        // Button öffnet neue Seite zum hinzufügen/bearbeiten von Kursteilnehmern
                        IconButton(
                          onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Seite wird geöffnet; Kursname und ID werden übergeben
                                builder: (context) => CourseDetailsPage(
                                    _journals_course[index]['name'],
                                    _journals_course[index]['id']),
                              ),
                            ),
                          },
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  );
                },
                // optischer Trenner
                separatorBuilder: (context, build) => const Divider(
                  thickness: 1,
                ),
              ),
        // Button öffnet Formular zum hinzufügen eines neuen Kurses
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showFormCourse(null),
        ),
      );
    });
  }
}
