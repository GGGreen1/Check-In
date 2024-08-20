import 'package:flutter/material.dart';
import 'package:sqflite_test_3/home_page.dart';
import 'add_person_page.dart';
import 'add_course_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch (currentPageIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = AddCoursePaige();

      case 2:
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for $currentPageIndex');
    }

    return Scaffold(
      bottomNavigationBar: Column(
        children: [
          Expanded(
              child: Container(
                  color: Theme.of(context).colorScheme.primary, child: page)),
          NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            indicatorColor: Colors.amber,
            selectedIndex: currentPageIndex,
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                  selectedIcon: Icon(Icons.groups),
                  icon: Icon(Icons.groups_outlined),
                  label: 'Kurse'),
              NavigationDestination(
                  selectedIcon: Icon(Icons.account_circle),
                  icon: Icon(Icons.account_circle_outlined),
                  label: 'Teilnehmer')
            ],
          ),
        ],
      ),
    );
  }
}