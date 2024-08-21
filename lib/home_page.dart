import 'package:flutter/material.dart';
import 'package:sqflite_test_3/home_page_details.dart';
import 'package:sqflite_test_3/sql_helper.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('SQL'),
          backgroundColor: Colors.amber,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: _journals_course.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Text(_journals_course[index]['name']),
                        const Spacer(),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePageDetails(
                              _journals_course[index]['name'],
                              _journals_course[index]['id']),
                        ),
                      );
                    },
                  );
                },
              ),
      );
    });
  }
}
