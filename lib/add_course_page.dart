import 'package:flutter/material.dart';
import 'package:sqflite_test_3/course_details_page.dart';
import 'package:sqflite_test_3/sql_helper.dart';


class AddCoursePaige extends StatefulWidget {
  //const AddPersonPaige({super.key, required this.title});

  //final String title;

  @override
  State<AddCoursePaige> createState() => _AddCoursePaige();
}

class _AddCoursePaige extends State<AddCoursePaige> {
  //Course functions

  List<Map<String, dynamic>> _journals_course = [];

  bool _isLoading = true;

  void _refreshJournalsCourse() async {
    final data = await SQLHelper.getCourses();

    setState(() {
      _journals_course = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournalsCourse();
    print("...number of items ${_journals_course.length}");
  }

  final TextEditingController _nameController = TextEditingController();

  Future<void> _addItemCourse() async {
    await SQLHelper.createCourse(_nameController.text);
    _refreshJournalsCourse();
    print("...number of items ${_journals_course.length}");
  }

  Future<void> _updateItemCourse(int id) async {
    await SQLHelper.updateCourse(
      id,
      _nameController.text,
    );
    _refreshJournalsCourse();
  }

  void _deleteItemCourse(int id) async {
    await SQLHelper.deleteCourse(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted ajournal!'),
    ));
    _refreshJournalsCourse();
  }

  //ShowFormCourse

  void _showFormCourse(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals_course.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
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
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Coursename'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addItemCourse() ;
                        }
                        if (id != null) {
                          await _updateItemCourse(id);
                        }

                        _nameController.text = '';
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'))
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kurse bearbeiten'),
          backgroundColor:  const Color.fromARGB(255, 0, 160, 170),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.separated(
              padding: const EdgeInsets.only(top: 10, left: 10) ,
              itemCount: _journals_course.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    children: [
                      Text(_journals_course[index]['name'],
                      style: const TextStyle(fontSize: 20),),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showFormCourse(_journals_course[index]['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
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
                                              _deleteItemCourse(
                                                  _journals_course[
                                                  index]['id']),
                                              Navigator.pop(context),
                                            },
                                            child: Text('Delete')),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ),
                      IconButton(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  CourseDetailsPage(_journals_course[index]['name'],_journals_course[index]['id']),
                            ),
                          ),
                        },
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  //subtitle: ,

                );
              },
              separatorBuilder: (context, build) => const Divider(
                thickness: 1 ,
              ),
            ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showFormCourse(null),
        ),
      );
    });
  }
}
