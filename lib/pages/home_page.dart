import 'package:flutter/material.dart';
import 'package:todo/pages/to_do_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        primaryColor: const Color(0xFF1C1C27),
        scaffoldBackgroundColor: const Color(0xFF1C1C27).withOpacity(0.7),
      ),
      home: const DefaultTabController(
        length: 4,
        child: ToDoListPage(),
      ),
    );
  }
}
