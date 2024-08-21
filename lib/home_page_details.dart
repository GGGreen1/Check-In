import 'package:flutter/material.dart';
import 'package:sqflite_test_3/sql_helper.dart';
import 'package:nfc_manager/nfc_manager.dart';

class HomePageDetails extends StatefulWidget {
  final String course_name;
  final int courseId;

  HomePageDetails(this.course_name, this.courseId);

  @override
  State<HomePageDetails> createState() => _HomePageDetails();
}

class _HomePageDetails extends State<HomePageDetails> {
  List<Map<String, dynamic>> _journals = [];

  List<bool> _isChecked = [];

  String _nfcData = 'No NFC data yet';

  bool _isScanning = false;

  String _scannerButtonText = 'Start scanning';

  //Participants Methods
  void _refreshJournals() async {
    final data = await SQLHelper.getParticipantsSameCourse(widget.courseId);

    setState(() {
      _journals = data;
      //_isChecked = List<bool>.filled(_journals.length, false);
      _isChecked = _journals.map((journal) => journal['present'] == 1).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  Future<void> _setPresent(int id, int present) async {
    await SQLHelper.setPresent(id, present);
    //_refreshJournals();
  }

  //NFC Methods
  void _startNFCReading() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        setState(() {
          _isScanning = true;
        });

        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // Extract and display NFC tag data
            setState(() {
              _nfcData = _formatTagData(tag);
            });

            for (int i = 0; i < _journals.length; i++) {
              print('In der Schleife');
              print('_nfcData: $_nfcData');

              String? storedNFCId =
                  await SQLHelper.getNfcId(_journals[i]['id']);
              print('NFC aus Datenbank: ');
              if (_nfcData == storedNFCId) {
                print(' Match gefunden');
                await _setPresent(_journals[i]['present'], 1);
                setState(() {
                  _isChecked[i] = true;
                });
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

  void _stopNFCReading() {
    NfcManager.instance.stopSession();
    setState(() {
      _isScanning = false;
      _nfcData = 'NFC scanning stopped.';
    });
  }

  String _formatTagData(NfcTag tag) {
    // Example: extract and format specific data from the tag
    final isoDep = tag.data['isodep'];
    final nfca = tag.data['nfca'];
    final ndefFormatable = tag.data['ndefformatable'];

    return 'ISO-DEP: $isoDep\nNFC-A: $nfca\nNDEF Formatable: $ndefFormatable';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.course_name}'), actions: <Widget>[
        TextButton(
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
          child: Text(_scannerButtonText),
        )
      ]),
      body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text(
                  '${_journals[index]['prename']} ${_journals[index]['surname']}'),
              value: _isChecked[index],
              onChanged: (bool? value) async {
                setState(() {
                  _isChecked[index] = value!;
                });

                int newPresentValue = value! ? 1 : 0;
                await _setPresent(_journals[index]['id'], newPresentValue);
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
          child: Text('reset'),
          onPressed: () async {
            for (int i = 0; i < _journals.length; i++) {
              await _setPresent(_journals[i]['id'], 0);
            }
            _refreshJournals();
          }),
    );
  }
}
