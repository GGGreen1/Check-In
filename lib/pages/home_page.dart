import 'package:flutter/material.dart';
import 'package:sqflite_test_3/pages/home_page_details.dart';
import 'package:sqflite_test_3/sql/sql_helper.dart';

// Startseite der App

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Leere Liste von Kursen erstellen
  List<Map<String, dynamic>> _journals_course = []; 

  // Variable speichert, ob die Kurse geladen haben
  bool _isLoading = true; 

  // Methode aktualisiert die Liste an Kursen
  void _refreshJournalsCourse() async {
    final data = await SQLHelper.getCourses();

    setState(() {
      _journals_course = data;
      _isLoading = false;
    });
  }

  // Wird einmal beim Aufrufen der Seite ausgeführt; Läd und aktualisiert die Kurse
  @override
  void initState() {
    super.initState();
    _refreshJournalsCourse();
  }

  // UI Elemente
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Check In'),
          backgroundColor: const Color.fromARGB(255, 0, 160, 170),
        ),
        // Liste der Kurse wird angezeigt, wenn sie geladen haben
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _journals_course.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      // jeder Listeneintrag besteht aus einem Text und einem Pfeil-Icon
                      children: [
                        Text(
                          _journals_course[index]['name'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                    // wenn man auf den Listeneintrag tippt, wird eine neue Seite geöffnet, die die Teilnehmer des Kurses anzeigt
                    onTap: () {
                      Navigator.push(
                        context,
                        // Der neuen Seite wird der Name und die ID des Kurses übergeben
                        MaterialPageRoute(
                          builder: (context) => HomePageDetails(
                              _journals_course[index]['name'],
                              _journals_course[index]['id']),
                        ),
                      );
                    },
                  );
                },
                // optischer Trenner
                separatorBuilder: (context, build) => const Divider(
                  thickness: 1,
                ),
              ),
      );
    });
  }
}
