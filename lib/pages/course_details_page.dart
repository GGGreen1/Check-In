import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:check_in/sql/sql_helper.dart';
import 'package:nfc_manager/nfc_manager.dart';

// Seite zum hinzufügen/bearbeiten von Kursteilnehmern

class CourseDetailsPage extends StatefulWidget {
  final String course_name;
  final int courseId;

  // Konstruktor von CourseDetailsPage wird aufgerufen; Kursname und ID werden übergeben
  CourseDetailsPage(this.course_name, this.courseId);

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  // Leere Liste der Teilnehmer wird erstellt
  List<Map<String, dynamic>> _journals = [];

  // Methode aktualisiert die Liste der Teilnehmer
  void _refreshJournals() async {
    // 'data' speichert die Daten, die aus der Datenbank kommen
    final data = await SQLHelper.getParticipantsSameCourse(widget.courseId);

    setState(() {
      // Liste der Kurse wird mit den Daten aus der Datenbank gefüllt
      _journals = data;
    });
  }

  // Wird einmal beim Aufrufen der Seite ausgeführt; Läd und aktualisiert die Kurse
  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  ///////////////////////////////////////////
  // Variablen und Methoden für Teilnehmer //

  // Variablen speichern die Eingaben des Nutzers
  final TextEditingController _prenameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _matrikelnummerController =
      TextEditingController();
  String _nfcId = '';
  int present = 0;

  // Variablen für Scanner-Button
  bool _isScanning = false;
  String _scannerButtonText = 'Studentenausweis scannen';
  Icon _scannerButtonIcon = Icon(Icons.play_arrow);

  // Methode fügt neuen Teilnehmer hinzu
  Future<void> _addParticipant() async {
    // zugehörige Methode in der Datenbank wird aufgerufen
    await SQLHelper.createParticipant(
        _prenameController.text,
        _surnameController.text,
        _matrikelnummerController.text,
        _nfcId,
        widget.courseId,
        present);
    // Liste der Teilnehmer wird aktualisiert
    _refreshJournals();
  }

  // Methode aktualisiert Teilnehmer
  Future<void> _updateParticipant(int id) async {
    await SQLHelper.updateParticipant(id, _prenameController.text,
        _surnameController.text, _matrikelnummerController.text);
    _refreshJournals();
  }

  // Methode löscht Teilnehmer
  Future<void> _deleteParticipant(int id) async {
    await SQLHelper.deleteParticipant(id);
    ScaffoldMessenger.of(context).showSnackBar;
    _refreshJournals();
  }

  /////////////////
  // NFC scanner //

  // Methode startet das Scannen von NFC-Tags
  void _startNFCReading() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      //Status '_isScanning' wird auf true gesetzt
      setState(() {
        _isScanning = true;
      });

      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // Wenn ein NFC-Tag gefunden wurdem, wird '_nfcData' auf die empfangenen Daten gesetzt
            setState(() {
              _nfcId = _formatTagData(tag)
                  .toString(); // empfangene Daten werden erst noch formatiert
            });

            // Hinweis, dass NFC-Tag erkannt wurde wird angezeigt
            showAutoDismissAlert(context);
          },
        );
      } else {
        setState(() {
          _nfcId = 'NFC not available.';
        });
      }
    } catch (e) {
      setState(() {
        _nfcId = 'Error reading NFC: $e';
      });
    }
  }

  // Methode stoppt das Suchen nach NFC-Tags
  void _stopNFCReading() {
    NfcManager.instance.stopSession();
    setState(() {
      _isScanning = false;
    });
  }

  // Methode formatiert den NFC-Tag
  String _formatTagData(NfcTag tag) {
    // Example: extract and format specific data from the tag
    final isoDep = tag.data['isodep'];
    final nfca = tag.data['nfca'];
    final ndefFormatable = tag.data['ndefformatable'];

    return 'ISO-DEP: $isoDep\nNFC-A: $nfca\nNDEF Formatable: $ndefFormatable';
  }

  // Methode zeigt Dialog an, dass ein NFC-Tag erkannt wurde
  void showAutoDismissAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          // Dialog wird eine Sekunde angezeigt
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop();
          });

          // Dialog
          return const AlertDialog(
            title: Column(
              children: [
                Text(
                  'Studentenausweis wurde gescannt',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 20,
                ),
                Icon(Icons.check),
              ],
            ),
            backgroundColor: Color.fromARGB(255, 165, 215, 153),
          );
        });
  }

  //////////////////////////////////////////////
  // Formular zum erstellen eines Teilnehmers //
  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _prenameController.text = existingJournal['prename'];
      _surnameController.text = existingJournal['surname'];
      _matrikelnummerController.text = existingJournal['matrikelnummer'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Container(
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
                  // Eingabe des Vornamen
                  TextField(
                    controller: _prenameController,
                    decoration: const InputDecoration(hintText: 'Vorname'),
                  ),
                  // Abstand
                  const SizedBox(
                    height: 10,
                  ),
                  // Eingabe des Nachnamen
                  TextField(
                    controller: _surnameController,
                    decoration: const InputDecoration(hintText: 'Nachname'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Eingabe der Matrikelnummer
                  TextField(
                    controller: _matrikelnummerController,
                    decoration:
                        const InputDecoration(hintText: 'Matrikelnummer'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Button zum scannen des NFC-Tags
                  TextButton.icon(
                    // Button startet oder stoppt das Scannen; Text und Icon werden verändert
                    onPressed: () {
                      if (_isScanning == false) {
                        _startNFCReading();
                        setModalState(
                          () {
                            _scannerButtonText = 'wird gescannt';
                            _scannerButtonIcon = const Icon(Icons.stop);
                          },
                        );
                      } else {
                        _stopNFCReading();
                        setModalState(
                          () {
                            _scannerButtonText = 'Studentenausweis scannen';
                            _scannerButtonIcon = const Icon(Icons.play_arrow);
                          },
                        );
                      }
                    },
                    label: Text(_scannerButtonText),
                    icon: _scannerButtonIcon,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Button fügt Teilnehmer hinzu
                  ElevatedButton(
                      onPressed: () async {
                        /*
                        Es wird überprüft, ob es den Kurs schon gibt.
                        Entweder wird er neu erstellt oder nur aktualisiert.
                        */
                        if (id == null) {
                          await _addParticipant();
                        }
                        if (id != null) {
                          await _updateParticipant(id);
                        }
                        
                        // Eingaben werden zurückgesetzt
                        _prenameController.text = '';
                        _surnameController.text = '';
                        _matrikelnummerController.text = '';
                        _scannerButtonText = 'Studentenausweis scannen';
                        _scannerButtonIcon = const Icon(Icons.play_arrow);

                        _stopNFCReading();

                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Erstellen' : 'Update'))
                ],
              ),
            );
          });
        });
  }

  /////////////////
  // UI-Elemente //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Kursname als Titel
        title: Text('${widget.course_name}'),
      ),
      // Liste der Teilnehmer
      body: ListView.separated(
        itemCount: _journals.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(children: [
              // Name des Teilnehmers
              Text(
                '${_journals[index]['prename']} ${_journals[index]['surname']}',
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              // Button zum bearbeiten eines Teilnehmers
              IconButton(
                // Formular zum bearbeiten wird geöffnet
                onPressed: () => _showForm(_journals[index]['id']),
                icon: const Icon(Icons.edit),
              ),
              // Button zum löschen eines Teilnehmers
              IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  /* 
                  Vor dem Löschen wird noch ein Dialog angezeigt,
                  ob der Kurs wirklich gelöscht werden soll.
                  */
                  onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 50, bottom: 50),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 30.0),
                                    child: Text(
                                      'Delete Participant',
                                      style: DefaultTextStyle.of(context)
                                          .style
                                          .apply(fontSizeFactor: 2.0),
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
                                            // Methode zum löschen des Teilnehmers wird aufgerufen
                                            onPressed: () => {
                                                  _deleteParticipant(
                                                      _journals[index]['id']),
                                                  Navigator.pop(context),
                                                },
                                            child: const Text('Delete')),
                                      ]),
                                ],
                              ))))),
            ]),
            // Matrikelnummer
            subtitle:
                Text('Matrikelnummer: ${_journals[index]['matrikelnummer']}'),
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
        onPressed: () => _showForm(null),
      ),
    );
  }
}
