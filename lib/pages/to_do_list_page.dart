import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/todo.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final _items = <ToDo>[]; // ToDo 객체들 저장할 리스트
  final _todoController = TextEditingController(); // text컨트롤러
  final double _containerWidth = 200.0; // AnimatedContainer의 초기 너비

  @override
  void initState() {
    super.initState();
    _loadTodoList(); // 할일 목록 로드
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

    // '중요' 한 할일 목록을 저장
    final todoListJson =
        _items.map((todo) => jsonEncode(todo.toJson())).toList();
    prefs.setStringList('todoList', todoListJson);
  }

  // 할일 수정 메소드
  Future<void> _modifyTodo(ToDo todo) async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final updatedText = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('할 일 수정'),
          content: TextField(
            controller: _todoController,
            decoration: const InputDecoration(
              hintText: '할 일을 입력하세요.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _todoController.text),
              child: const Text('수정'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );

    if (updatedText != null) {
      setState(() {
        todo.title = updatedText;
      });
    }

    // 수정 한 할일 목록을 저장
    final todoListJson =
        _items.map((todo) => jsonEncode(todo.toJson())).toList();
    prefs.setStringList('todoList', todoListJson);
  }

  void _handleDismiss(DismissDirection direction, ToDo todo) async {
    if (direction == DismissDirection.endToStart) {
      _deleteTodo(todo); // 오른쪽에서 왼쪽으로 스와이프 했을 때, 할일 삭제 메소드 호출
    } else if (direction == DismissDirection.startToEnd) {
      await _modifyTodo(todo); // 왼쪽에서 오른쪽으로 스와이프 했을 때, 할일 수정 메소드 호출
    }
  }

  // Todo 객체를 Dismissible(... child: ListTile) 위젯으로 변경하는 메소드
  Widget _buildItemWidget(ToDo todo) {
    return Dismissible(
      key: Key(todo.title), // 각 아이템의 고유한 키
      onDismissed: (direction) => _handleDismiss(direction, todo), // 삭제 또는 수정
      background: Container(
        // 왼쪽에서 오른쪽으로 스와이프 했을 때 나오는 container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromARGB(255, 65, 138, 233),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(
          Icons.edit_document,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        // 오른쪽에서 왼쪽으로 스와이프 했을 때 나오는 container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xFFE94141),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      child: Container(
        // 할 일 container
        decoration: const BoxDecoration(
          color: Color(0xFF272833),
          borderRadius: BorderRadius.all(Radius.circular(15)),
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
                side:
                    const BorderSide(color: Color(0xFFFFB43A)), // 체크박스 border.
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
      {bool showCompleted = false,
      bool showImportant = false,
      showAll = false}) {
    // 필터링된 할일 목록
    late final List<ToDo> filteredItems;
    if (showAll) {
      filteredItems = _items;
    } else {
      filteredItems = _items.where((item) {
        if (showImportant) {
          return item.isImportant;
        } else if (showCompleted) {
          return item.isDone;
        } else if (!showCompleted) {
          return !item.isDone;
        }
        return true;
      }).toList();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 50.0,
        //bottom: 25,
        left: 20.0,
        right: 20.0,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                // 가장 마지막 할일만 제외하고, 모든 할일 밑에 sizedbox 추가
                // 즉, todo들 사이에 공간을 만드는 역할.
                if (index < filteredItems.length - 1) {
                  return Column(
                    children: [
                      _buildItemWidget(filteredItems[index]),
                      const SizedBox(height: 20),
                    ],
                  );
                } else {
                  return _buildItemWidget(filteredItems[index]);
                }
              },
            ),
          ),
          // input 위젯 생성.
          makeInput(),
        ],
      ),
    );
  }

  // input 위젯을 만드는 메소드.
  Widget makeInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            width: _containerWidth,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB43A).withOpacity(0.2), // input 배경색 설정
              borderRadius: BorderRadius.circular(50), // 모서리 둥근 사각형
              border: Border.all(
                // 테두리 추가
                color: const Color(0xFFFFB43A),
                width: 3,
              ),
            ),
            child: TextField(
              controller: _todoController,
              style: const TextStyle(
                  color: Color(0xFFFFB43A)), // 사용자가 입력하는 text 색깔 설정
              decoration: const InputDecoration(
                border: InputBorder.none, // 입력란의 테두리 제거
                hintText: 'Add tasks...',
                hintStyle: TextStyle(
                    color: Color(0xFFFFB43A)), // hint text 색 설정. (Add tasks...)
                contentPadding:
                    EdgeInsets.only(left: 20), // Add tasks... 왼쪽에 여백 추가
              ),
            ),
          ),
          IconButton(
            //할일 추가 버튼
            onPressed: () {
              if (_todoController.text.isNotEmpty) {
                // text를 입력 했을 때만 할일을 추가.
                _addTodo(ToDo(_todoController.text));
              }
            },
            icon: const Icon(
              Icons.add_circle_outlined,
              color: Color(0xFFFFB43A),
              size: 35,
            ),
          ),
        ],
      ),
    );
  }

  // main app build 메소드
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 다른곳 눌러서 키보드 감추기 가능하게 함.
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('남은 할 일'),
          backgroundColor: Theme.of(context).primaryColor,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFB43A), // tabbar 아래 밑줄 색깔
            unselectedLabelColor: Colors.white, // 선택되지 않은 tab 글자 색깔
            labelColor: Color(0xFFFFB43A), // 선택된 tab 글자 색깔
            labelPadding: EdgeInsets.all(2), // tab text에 padding을 넣음.
            // 이거 안넣으면 글자가 너무 길어서 일부분이 가려짐.
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
            _buildTodoList(showAll: true), // 모든 할일 보여줌
            _buildTodoList(showCompleted: true), // 완료된 할일만 보여줌
            _buildTodoList(showCompleted: false), // 미완료된 할일만 보여줌
            _buildTodoList(showImportant: true), // 중요한 할일만 보여줌
          ],
        ),
      ),
    );
  }
}
