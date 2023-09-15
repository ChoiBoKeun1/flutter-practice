import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  final double _inputContainerWidth = 200.0; // 입력창 Container 너비

  Map<String, Color> colorMap = {
    'Appbar Color': const Color(0xFF1C1C27),
    'Scaffold Background Color': const Color(0xFF1C1C27).withOpacity(0.7),
    'Todo Container Color': const Color(0xFF272833),
    'Highlight Color': const Color(0xFFFFB43A),
    'Text Color': const Color(0xFFFCFCFC),
    'My Check Color': const Color(0xFFFCFCFC),
  };

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
    final oldText = todo.title;

    if (!mounted) return;

    _todoController.text = oldText;

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
              onPressed: () => Navigator.pop(context, oldText),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );

    // 수정한 text 받아온 후에는 contoller 비워줌.
    _todoController.text = '';

    // 수정한 할일이 기존 할일과 다르면 할일을 수정.
    if (updatedText != null && updatedText != oldText) {
      setState(() {
        todo.title = updatedText;
      });
    } else {
      return;
    }

    // 수정 한 할일 목록을 저장
    final todoListJson =
        _items.map((todo) => jsonEncode(todo.toJson())).toList();
    prefs.setStringList('todoList', todoListJson);
  }

  // Todo 객체를 Slidable(... child: ListTile) 위젯으로 변경하는 메소드
  Widget _buildItemWidget(ToDo todo) {
    return Slidable(
      //key: Key(todo.title), // 각 아이템의 고유한 키
      // 왼쪽에서 오른쪽으로 스와이프
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _modifyTodo(todo),
            backgroundColor: const Color.fromARGB(255, 65, 138, 233),
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(15),
            icon: Icons.edit_document,
            label: 'MODIFY',
          ),
        ],
      ),
      // 오른쪽에서 왼쪽으로 스와이프
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _deleteTodo(todo),
            backgroundColor: const Color(0xFFE94141),
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(15),
            icon: Icons.delete,
            label: 'DELETE',
          ),
        ],
      ),
      child: Container(
        // 할 일 container
        decoration: BoxDecoration(
          color: colorMap['Todo Container Color'],
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
            color: colorMap['Highlight Color'],
          ),
          title: Row(
            children: [
              Checkbox(
                value: todo.isDone,
                onChanged: (bool? value) => _toggleTodo(todo),
                checkColor: colorMap['My Check Color'], // 체크 했을 때 체크 표시의 색깔
                activeColor: colorMap['Highlight Color'], // 체크 했을 때 배경색깔
                side: BorderSide(
                    color: colorMap['Highlight Color']!), // 체크박스 border.
              ),
              Text(
                todo.title,
                style: todo.isDone
                    ? TextStyle(
                        // 할 일 완료시
                        decoration: TextDecoration.lineThrough, // 취소선 긋기
                        fontStyle: FontStyle.italic, // 이탤릭체
                        color: colorMap['Text Color'],
                        fontWeight: FontWeight.bold,
                      )
                    : TextStyle(
                        // 할일 미완료시
                        color: colorMap['Text Color'],
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
    filteredItems = filteringItems(showAll, showImportant, showCompleted);

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
                  return Column(
                    children: [
                      _buildItemWidget(filteredItems[index]),
                    ],
                  );
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

  List<ToDo> filteringItems(showAll, bool showImportant, bool showCompleted) {
    List<ToDo> filteredItems;

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
    return filteredItems;
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
            width: _inputContainerWidth,
            decoration: BoxDecoration(
              color:
                  colorMap['Highlight Color']!.withOpacity(0.2), // input 배경색 설정
              borderRadius: BorderRadius.circular(50), // 모서리 둥근 사각형
              border: Border.all(
                // 테두리 추가
                color: colorMap['Highlight Color']!,
                width: 3,
              ),
            ),
            child: TextField(
              controller: _todoController,
              style: TextStyle(
                  color: colorMap['Highlight Color']), // 사용자가 입력하는 text 색깔 설정
              decoration: InputDecoration(
                border: InputBorder.none, // 입력란의 테두리 제거
                hintText: 'Add tasks...',
                hintStyle: TextStyle(
                    color: colorMap[
                        'Highlight Color']), // hint text 색 설정. (Add tasks...)
                contentPadding:
                    const EdgeInsets.only(left: 20), // Add tasks... 왼쪽에 여백 추가
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
            icon: Icon(
              Icons.add_circle_outlined,
              color: colorMap['Highlight Color'],
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
        backgroundColor: colorMap['Scaffold Background Color'],
        appBar: AppBar(
          centerTitle: true,
          title: const Text('남은 할 일'),
          backgroundColor: colorMap['Appbar Color'],
          actions: [
            IconButton(
              onPressed: _showSettings,
              icon: const Icon(Icons.settings),
            ),
          ],
          bottom: TabBar(
            indicatorColor: colorMap['Highlight Color'], // tabbar 아래 밑줄 색깔
            unselectedLabelColor: colorMap['Text Color'], // 선택되지 않은 tab 글자 색깔
            labelColor: colorMap['Highlight Color'], // 선택된 tab 글자 색깔
            labelPadding: const EdgeInsets.all(2), // tab text에 padding을 넣음.
            // 이거 안넣으면 글자가 너무 길어서 일부분이 가려짐.
            tabs: const [
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

  void _showSettings() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('색상 설정'),
          content: Column(
            children: [
              _buildColorOption('Appbar Color'),
              _buildColorOption('Scaffold Background Color'),
              _buildColorOption('Todo Container Color'),
              _buildColorOption('Highlight Color'),
              _buildColorOption('Text Color'),
              _buildColorOption('My Check Color'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorOption(String label) {
    return ListTile(
      title: Text(label),
      onTap: () {
        _showColorPickerDialog(label, colorMap[label]!);
      },
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: colorMap[label],
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }

  void _showColorPickerDialog(String label, Color currentColor) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (newColor) {
                setState(() => pickerColor = newColor);
              },
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('확인'),
              onPressed: () {
                setState(() {
                  currentColor = pickerColor;
                  colorMap[label] = currentColor;
                });
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
