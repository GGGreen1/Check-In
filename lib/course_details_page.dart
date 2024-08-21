import 'package:flutter/material.dart';
import 'package:sqflite_test_3/sql_helper.dart';
import 'package:nfc_manager/nfc_manager.dart';

class CourseDetailsPage extends StatefulWidget {
  final String course_name;
  final int courseId;

  CourseDetailsPage(this.course_name, this.courseId);

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  List<Map<String, dynamic>> _journals = [];

  void _refreshJournals() async {
    final data = await SQLHelper.getParticipantsSameCourse(widget.courseId);

    setState(() {
      _journals = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _prenameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _matrikelnummerController =
      TextEditingController();
  String _nfcId = '';
  int present = 0;

  Future<void> _addParticipant() async {
    await SQLHelper.createParticipant(
        _prenameController.text,
        _surnameController.text,
        _matrikelnummerController.text,
        _nfcId,
        widget.courseId,
        present);
    _refreshJournals();
  }

  Future<void> _updateParticipant(int id) async {
    await SQLHelper.updateParticipant(id, _prenameController.text,
        _surnameController.text, _matrikelnummerController.text);
    _refreshJournals();
  }

  Future<void> _deleteParticipant(int id) async {
    await SQLHelper.deleteParticipant(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully deleted a participant')));
    _refreshJournals();
  }

  ////////////////
  //NFC scanner
  void _startNFCReading() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // Extract and display NFC tag data
            setState(() {
              _nfcId = _formatTagData(tag).toString();
            });
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

  String _formatTagData(NfcTag tag) {
    // Example: extract and format specific data from the tag
    final isoDep = tag.data['isodep'];
    final nfca = tag.data['nfca'];
    final ndefFormatable = tag.data['ndefformatable'];

    return 'ISO-DEP: $isoDep\nNFC-A: $nfca\nNDEF Formatable: $ndefFormatable';
  }

  //////////////////

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
                  TextButton(
                      onPressed: _startNFCReading,
                      child: const Text('Scan Studentenausweis')),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addParticipant();
                        }
                        if (id != null) {
                          await _updateParticipant(id);
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
        title: Text('${widget.course_name}' + ' ' + widget.courseId.toString()),
      ),
      body: ListView.separated(
          itemCount: _journals.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Row(children: [
                Text(
                    '${_journals[index]['prename']} ${_journals[index]['surname']}',
                    style: const TextStyle(fontSize: 16),),
                const Spacer(),
                IconButton(
                  onPressed: () => _showForm(_journals[index]['id']),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                    icon: const Icon(
                      Icons.delete,
                    ),
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
                                              onPressed: () => {
                                                    _deleteParticipant(
                                                        _journals[index]['id']),
                                                    Navigator.pop(context),
                                                  },
                                              child: Text('Delete')),
                                        ]),
                                  ],
                                ))))),
              ]),
              subtitle:
                  Text('Matrikelnummer: ${_journals[index]['matrikelnummer']}'),
            );
          },
          separatorBuilder: (context, build) => const Divider(
            thickness: 1 ,
          ),
        ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
