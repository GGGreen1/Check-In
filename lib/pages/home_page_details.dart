import 'package:flutter/material.dart';
import 'package:sqflite_test_3/sql/sql_helper.dart';
import 'package:nfc_manager/nfc_manager.dart';

// Seite der Kursteilnehmer | Check-In Seite

class HomePageDetails extends StatefulWidget {
  final String courseName;
  final int courseId;

  // Konstruktor von HomePageDetails wird aufgerufen; Kursname und ID werden übergeben
  HomePageDetails(this.courseName, this.courseId);

  @override
  State<HomePageDetails> createState() => _HomePageDetails();
}

class _HomePageDetails extends State<HomePageDetails> {
  // Leere Liste der Teilnehmer wird erstellt
  List<Map<String, dynamic>> _journals = [];

  // Leere bool Liste gibt an, ob ein Teilnehmer anwesend ist, oder nicht
  List<bool> _isChecked = [];

  // ariable speichert die Daten, die vom Studentenausweis übergeben werden
  String _nfcData = 'No NFC data yet';

  // Variable gibt an, ob der NFC-Scanner des Handys läuft
  bool _isScanning = false;

  // Text auf dem Butten, der den Scannprozess aktiviert
  String _scannerButtonText = 'Start scanning';

  // Icon auf dem Butten, der den Scannprozess aktiviert
  Icon _scannerButtonIcon(bool isScanning) {
    if (isScanning == true) {
      return const Icon(
        Icons.stop,
        color: Colors.black,
      );
    } else {
      return const Icon(
        Icons.play_arrow,
        color: Colors.black,
      );
    }
  }

  // Farbe des Butten, der den Scannprozess aktiviert
  Color _scannerButtonColor(bool isScanning) {
    if (isScanning == true) {
      return const Color.fromARGB(255, 238, 100, 92);
    } else {
      return const Color.fromARGB(255, 165, 215, 153);
    }
  }

  /////////////////////////
  // Teilnehmer Methoden //

  // Methode aktualisiert die Liste der Teilnehmer
  void _refreshJournals() async {
    // 'data' speichert die Daten, die aus der Datenbank kommen
    final data = await SQLHelper.getParticipantsSameCourse(widget.courseId);

    setState(() {
      _journals = data;
      //_isChecked = List<bool>.filled(_journals.length, false);
      /*
      Die Liste '_isChecked' wird mit 'true' gefüllt, 
      wenn in der Datenbank in der Zeile 'present eine '1' steht. 
      Steht and er Stelle eine '0' wird in die Liste 'false' eingetragen.
      */
      _isChecked = _journals.map((journal) => journal['present'] == 1).toList();
    });
  }

  // Wird einmal beim Aufrufen der Seite ausgeführt; Läd und aktualisiert die Kurse
  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  // Methode setzt legt den 'Anwesenheitsstatus' eines Teilnehmers fest
  Future<void> _setPresent(int id, int present) async {
    // zugehörige Methode in der Datenbank wird aufgerufen; ID und aktueller Status wird übergeben
    await SQLHelper.setPresent(id, present);
    //_refreshJournals();
  }

  /////////////////
  // NFC Methods //

  // Methode startet das Scannen von NFC-Tags
  void _startNFCReading() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      //Status '_isScanning' wird auf true gesetzt
      if (isAvailable) {
        setState(() {
          _isScanning = true;
        });

        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // Wenn ein NFC-Tag gefunden wurdem, wird '_nfcData' auf die empfangenen Daten gesetzt
            setState(() {
              _nfcData = _formatTagData(tag); // empfangene Daten werden erst noch formatiert
            });

            /*
            Die Teilnehmer werden duchgegangen und es wird nach Übereinstimmungen
            zwischen zwischen dem, was gerade gescannt wurde und dem, was in der
            Datenbank steht.
            */
            for (int i = 0; i < _journals.length; i++) {
              //print('In der Schleife');
              //print('_nfcData: $_nfcData');
              
              // String aus der Datenbank wird tenporär gespeichert
              String? storedNFCId = await SQLHelper.getNfcId(_journals[i]['id']);
              //print('NFC aus Datenbank: ');
              // Vergleich zwischen String aus der Datenbank und dem gerade gescannten NFC-Tag
              if (_nfcData == storedNFCId) {
                //print(' Match gefunden');
                await _setPresent(_journals[i]['present'], 1);
                setState(() {
                  _isChecked[i] = true;
                });
                /*
                Wenn ein Match gefunden wurde, kann die Schleife angebrochen werden, 
                da zwei Teilnehmer nicht den gleichen NFC-Tag haben können.
                */
                break;
              }
            }
          },
        );
      } else {
        setState(() {
          _nfcData = 'NFC not available.';
        });
      }
    } catch (e) {
      setState(() {
        _nfcData = 'Error reading NFC: $e';
      });
    }
  }

  // Methode stoppt das Suchen nach NFC-Tags
  void _stopNFCReading() {
    NfcManager.instance.stopSession();
    setState(() {
      _isScanning = false;
      _nfcData = 'NFC scanning stopped.';
    });
  }

  // Methode formatiert den NFC-Tag
  String _formatTagData(NfcTag tag) {
    final isoDep = tag.data['isodep'];
    final nfca = tag.data['nfca'];
    final ndefFormatable = tag.data['ndefformatable'];

    return 'ISO-DEP: $isoDep\nNFC-A: $nfca\nNDEF Formatable: $ndefFormatable';
  }

  /////////////////
  // UI-Elemente //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseName), actions: <Widget>[
        // In der AppBar ist der Button, der das Scannen von NFC-Tags startet
        TextButton.icon(
          // Button startet oder stoppt das scannen. Dabei wird Text verändert
          onPressed: () {
            if (_isScanning == false) {
              _startNFCReading();
              setState(() {
                _scannerButtonText = 'Stop Scanning';
              });
            } else {
              _stopNFCReading();
              _scannerButtonText = 'Start Scanning';
            }
          },
          style: ButtonStyle(
            // Farbe passt sich Status an
            backgroundColor:
                WidgetStateProperty.all(_scannerButtonColor(_isScanning)),
          ),
          // Icon passt sich Status an
          icon: _scannerButtonIcon(_isScanning),
          label: Text(
            _scannerButtonText,
            style: const TextStyle(color: Colors.black),
          ),
        )
      ]),
      // Liste der Teilnehmer
      body: ListView.separated(
        itemCount: _journals.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            // Vor- und Nachname
            title: Text(
              '${_journals[index]['prename']} ${_journals[index]['surname']}',
              style: const TextStyle(fontSize: 20),
            ),
            // Matrikelnummer
            subtitle:
                Text('Matrikelnummer: ${_journals[index]['matrikelnummer']}'),
            
            // Checkbox ist von '_isChecked' abhängig
            value: _isChecked[index],
            onChanged: (bool? value) async {
              setState(() {
                _isChecked[index] = value!;
              });

              int newPresentValue = value! ? 1 : 0;
              await _setPresent(_journals[index]['id'], newPresentValue);
            },
          );
        },
        // optischer Trenner
        separatorBuilder: (context, build) => const Divider(
          thickness: 1,
        ),
      ),
      // Button setzt alle Checkedboxes auf 'false'
      floatingActionButton: FloatingActionButton(
          child: Text('reset'),
          // Alle Elemente in der Teilnehmerliste werden auf 'false' gesetzt
          onPressed: () async {
            for (int i = 0; i < _journals.length; i++) {
              await _setPresent(_journals[i]['id'], 0);
            }
            _refreshJournals();
          }),
    );
  }
}
