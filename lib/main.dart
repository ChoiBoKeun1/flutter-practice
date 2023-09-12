import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDo {
  bool isDone = false;
  bool isImportant = false;
  String title = '';
  int id = 0;

  ToDo(
    this.title,
  );

  // ToDo 객체를 Json 으로 변환하는 메소드
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
      'isImportant': isImportant,
      'id': id,
    };
  }

  ToDo.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        isDone = json['isDone'],
        isImportant = json['isImportant'],
        id = json['id'];
}

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        primaryColor: const Color(0xFF1C1C27),
      ),
      home: const DefaultTabController(
        length: 4,
        child: ToDoListPage(),
      ),
    );
  }
}

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final _items = <ToDo>[]; // ToDo 객체들 저장할 리스트
  final _todoController = TextEditingController(); // 컨트롤러
  final double _containerWidth = 200.0; // AnimatedContainer의 초기 너비

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  @override
  void dispose() {
    _todoController.dispose(); // 컨트롤러는 종료시 반드시 해제
    super.dispose();
  }

  // todo 리스트 로드 메소드
  void _loadTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = prefs.getStringList('todoList') ?? [];

    setState(() {
      _items.clear();
      for (final jsonStr in todoListJson) {
        final todoJson = Map<String, dynamic>.from(jsonDecode(jsonStr));
        final todo = ToDo.fromJson(todoJson);
        _items.add(todo);
      }
    });
  }

  // 할일 추가 메소드
  void _addTodo(ToDo todo) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _items.add(todo);
      _todoController.text = ''; // 할일 추가 후, 리스트 비우기
    });

    // 추가한 할일 목록을 저장
    final todoListJson =
        _items.map((todo) => jsonEncode(todo.toJson())).toList();
    prefs.setStringList('todoList', todoListJson);
  }

  // 할일 삭제 메소드
  void _deleteTodo(ToDo todo) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _items.remove(todo);
    });

    // 삭제한 할일 목록을 저장
    final todoListJson =
        _items.map((todo) => jsonEncode(todo.toJson())).toList();
    prefs.setStringList('todoList', todoListJson);
  }

  // 할일 완료/미완료 토글 메소드
  void _toggleTodo(ToDo todo) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      todo.isDone = !todo.isDone;
    });

    // 토글한 할일 목록을 저장
    final todoListJson =
        _items.map((todo) => jsonEncode(todo.toJson())).toList();
    prefs.setStringList('todoList', todoListJson);
  }

  // 중요한 할일 토글 메소드
  void _toggleImportant(ToDo todo) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      todo.isImportant = !todo.isImportant;
    });

    // '중요' 톡르한 할일 목록을 저장
    final todoListJson =
        _items.map((todo) => jsonEncode(todo.toJson())).toList();
    prefs.setStringList('todoList', todoListJson);
  }

  // 할일 객체를 ListTile 형태로 변경하는 메소드
  Widget _buildItemWidget(ToDo todo) {
    return Dismissible(
      key: Key(todo.title), // 각 아이템의 고유한 키
      direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로 스와이프
      onDismissed: (direction) {
        // 삭제 작업 수행
        _deleteTodo(todo);
      },
      background: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.red,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF272833).withOpacity(0.5),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: ListTile(
          onTap: () => _toggleTodo(todo), // 완료/미완료 상태 변경
          trailing: IconButton(
            //  오른쪽에 중요버튼(별)
            icon: todo.isImportant
                ? const Icon(Icons.star)
                : const Icon(Icons.star_border_outlined),
            onPressed: () => _toggleImportant(todo), // 중요 할일 표시
            color: const Color(0xFFFFB43A),
          ),
          title: Row(
            children: [
              Checkbox(
                value: todo.isDone,
                onChanged: (bool? value) => _toggleTodo(todo),
                checkColor: const Color(0xFFFCFCFC), // 체크 했을 때 체크 표시의 색깔
                activeColor: const Color(0xFFFFB43A), // 체크 했을 때 배경색깔
              ),
              Text(
                todo.title,
                style: todo.isDone
                    ? const TextStyle(
                        // 할 일 완료시
                        decoration: TextDecoration.lineThrough, // 취소선 긋기
                        fontStyle: FontStyle.italic, // 이탤릭체
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )
                    : const TextStyle(
                        // 할일 미완료시
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // todolist build하는 메소드
  Widget _buildTodoList(
      {bool showCompleted = false, bool showImportant = false}) {
    final filteredItems = _items.where((item) {
      if (showCompleted && showImportant) {
        return true;
      } else if (showImportant) {
        return item.isImportant;
      } else if (showCompleted) {
        return item.isDone;
      } else if (!showCompleted) {
        return !item.isDone;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                if (index < filteredItems.length - 1) {
                  return Column(
                    children: [
                      _buildItemWidget(filteredItems[index]),
                      const SizedBox(height: 5),
                    ],
                  );
                } else {
                  return _buildItemWidget(filteredItems[index]);
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _containerWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // 모서리 둥근 사각형
                  border: Border.all(
                    color: const Color(0xFFFFB43A),
                  ), // 테두리 추가
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                      border: InputBorder.none, // 입력란의 테두리 제거
                      hintText: '할일 추가',
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _addTodo(ToDo(_todoController.text));
                },
                icon: const Icon(
                  Icons.add_circle_outlined,
                  color: Color(0xFFFFB43A),
                  size: 35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 다른곳 눌러서 키보드 감추기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('남은 할 일'),
          backgroundColor: Theme.of(context).primaryColor,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Completed'),
              Tab(text: 'Incompleted'),
              Tab(text: 'Important'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTodoList(showCompleted: true, showImportant: true),
            _buildTodoList(showCompleted: true, showImportant: false),
            _buildTodoList(showCompleted: false, showImportant: false),
            _buildTodoList(showCompleted: false, showImportant: true),
          ],
        ),
      ),
    );
  }
}
