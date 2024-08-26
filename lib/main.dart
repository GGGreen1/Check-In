import 'package:flutter/material.dart';
import 'package:sqflite_test_3/pages/home_page.dart';
import 'pages/add_course_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 0, 160, 170),
      child: SafeArea(
        top: true,
        bottom: false,
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 160, 170)),
            useMaterial3: true,
          ),
          home: MyHomePage(),
        ),
      ),
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
            indicatorColor: const Color.fromARGB(255, 0, 160, 170),
            selectedIndex: currentPageIndex,
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.how_to_reg),
                icon: Icon(Icons.how_to_reg_outlined),
                label: 'Check In',
              ),
              NavigationDestination(
                  selectedIcon: Icon(Icons.groups),
                  icon: Icon(Icons.groups_outlined),
                  label: 'Kurse'),

            ],
          ),
        ],
      ),
    );
  }
}