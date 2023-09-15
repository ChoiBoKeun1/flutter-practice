import 'package:flutter/material.dart';
import 'package:todo/pages/to_do_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ToDo App',
      home: DefaultTabController(
        length: 4,
        child: ToDoListPage(),
      ),
    );
  }
}
