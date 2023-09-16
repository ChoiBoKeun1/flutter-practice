import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/my_color.dart';
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

  var colorList =
      <MyColor>[]; // color 리스트. 이 리스트는 sharedPreferences 사용하여 저장하는데에만 씀.

  // 실제 widget들에 사용하는 색깔 객체들
  late MyColor appbarColor;
  late MyColor scaffoldBackgroundColor;
  late MyColor todoContainerColor;
  late MyColor highlightColor;
  late MyColor textColor;
  late MyColor myCheckColor;

  @override
  void initState() {
    super.initState();
    _loadTodoList(); // 할일 목록 로드
    _initColor(); // 색상 초기화
    _loadColor(); // 색상 로드
  }

  @override
  void dispose() {
    _todoController.dispose(); // 컨트롤러는 종료시 반드시 해제
    super.dispose();
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
        backgroundColor: scaffoldBackgroundColor.color,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '남은 할 일',
            style: TextStyle(
              color: textColor.color,
            ),
          ),
          backgroundColor: appbarColor.color,
          actions: [
            IconButton(
              onPressed: _showSettings,
              icon: Icon(
                Icons.settings,
                color: textColor.color,
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: highlightColor.color, // tabbar 아래 밑줄 색깔
            unselectedLabelColor: textColor.color, // 선택되지 않은 tab 글자 색깔
            labelColor: highlightColor.color, // 선택된 tab 글자 색깔
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
            buildTodoList(showAll: true), // 모든 할일 보여줌
            buildTodoList(showCompleted: true), // 완료된 할일만 보여줌
            buildTodoList(showCompleted: false), // 미완료된 할일만 보여줌
            buildTodoList(showImportant: true), // 중요한 할일만 보여줌
          ],
        ),
      ),
    );
  }

  // 초기 색상 지정 메소드
  void _initColor() {
    setState(() {});
    appbarColor = MyColor(
      title: 'Appbar Color',
      color: const Color(0xFF1C1C27),
    );
    scaffoldBackgroundColor = MyColor(
      title: 'Scaffold Background Color',
      color: const Color(0xFF1C1C27).withOpacity(0.7),
    );
    todoContainerColor = MyColor(
      title: 'Todo Container Color',
      color: const Color(0xFF272833),
    );
    highlightColor = MyColor(
      title: 'Highlight Color',
      color: const Color(0xFFFFB43A),
    );
    textColor = MyColor(
      title: 'Text Color',
      color: const Color(0xFFFCFCFC),
    );
    myCheckColor = MyColor(
      title: 'My Check Color',
      color: const Color(0xFFFCFCFC),
    );

    // colorList에 색상들 추가.
    colorList.add(appbarColor);
    colorList.add(scaffoldBackgroundColor);
    colorList.add(todoContainerColor);
    colorList.add(highlightColor);
    colorList.add(textColor);
    colorList.add(myCheckColor);
  }

  // 색상 로드 메소드
  void _loadColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorJson = prefs.getStringList('colorList') ?? [];

    // 만약 키 : colorList 로 저장한 data가 있으면 로드한다.
    if (colorJson.isNotEmpty) {
      setState(() {
        colorList.clear();
        for (final jsonStr in colorJson) {
          final colorJson = Map<String, dynamic>.from(jsonDecode(jsonStr));
          print('제이슨 : $colorJson');
          final color = MyColor.fromJson(colorJson);
          colorList.add(color);
        }

        appbarColor = colorList[0];
        scaffoldBackgroundColor = colorList[1];
        todoContainerColor = colorList[2];
        highlightColor = colorList[3];
        textColor = colorList[4];
        myCheckColor = colorList[5];
      });
    }
  }

  // 설정창에서 색상을 지정한 뒤 저장하는 메소드.
  void _saveColor() async {
    final prefs = await SharedPreferences.getInstance();

    colorList[0] = appbarColor;
    colorList[1] = scaffoldBackgroundColor;
    colorList[2] = todoContainerColor;
    colorList[3] = highlightColor;
    colorList[4] = textColor;
    colorList[5] = myCheckColor;

    final colorListJson =
        colorList.map((myColor) => jsonEncode(myColor.toJson())).toList();
    prefs.setStringList('colorList', colorListJson);
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
  void addTodo(ToDo todo) async {
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
  void deleteTodo(ToDo todo) async {
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
  void toggleTodo(ToDo todo) async {
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
  void toggleImportant(ToDo todo) async {
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
  Future<void> modifyTodo(ToDo todo) async {
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

  // 1. (filteringItems 메소드 사용) _items 리스트의 할일들을 필터링 한 후,
  // 2. (buildItemWidget 위젯 사용) 필터링된 모든 할일들을 출력한다.
  Widget buildTodoList(
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
                      buildItemWidget(filteredItems[index]),
                      const SizedBox(height: 20),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      buildItemWidget(filteredItems[index]),
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

// _items 리스트 필터링하는 메소드.
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

  // Todo 객체를 Slidable(... child: ListTile) 위젯으로 변경하는 메소드
  Widget buildItemWidget(ToDo todo) {
    return Slidable(
      //key: Key(todo.title), // 각 아이템의 고유한 키
      // 왼쪽에서 오른쪽으로 스와이프
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => modifyTodo(todo),
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
            onPressed: (context) => deleteTodo(todo),
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
          color: todoContainerColor.color,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: ListTile(
          onTap: () => toggleTodo(todo), // 완료/미완료 상태 변경
          trailing: IconButton(
            //  오른쪽에 중요버튼(별)
            icon: todo.isImportant
                ? const Icon(Icons.star)
                : const Icon(Icons.star_border_outlined),
            onPressed: () => toggleImportant(todo), // 중요 할일 표시
            color: highlightColor.color,
          ),
          title: Row(
            children: [
              Checkbox(
                value: todo.isDone,
                onChanged: (bool? value) => toggleTodo(todo),
                checkColor: myCheckColor.color, // 체크 했을 때 체크 표시의 색깔
                activeColor: highlightColor.color, // 체크 했을 때 배경색깔
                side: BorderSide(color: highlightColor.color), // 체크박스 border.
              ),
              Text(
                todo.title,
                style: todo.isDone
                    ? TextStyle(
                        // 할 일 완료시
                        decoration: TextDecoration.lineThrough, // 취소선 긋기
                        fontStyle: FontStyle.italic, // 이탤릭체
                        color: textColor.color,
                        fontWeight: FontWeight.bold,
                      )
                    : TextStyle(
                        // 할일 미완료시
                        color: textColor.color,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ],
          ),
        ),
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
            width: _inputContainerWidth,
            decoration: BoxDecoration(
              color: highlightColor.color.withOpacity(0.2), // input 배경색 설정
              borderRadius: BorderRadius.circular(50), // 모서리 둥근 사각형
              border: Border.all(
                // 테두리 추가
                color: highlightColor.color,
                width: 3,
              ),
            ),
            child: TextField(
              controller: _todoController,
              style: TextStyle(
                  color: highlightColor.color), // 사용자가 입력하는 text 색깔 설정
              decoration: InputDecoration(
                border: InputBorder.none, // 입력란의 테두리 제거
                hintText: 'Add tasks...',
                hintStyle: TextStyle(
                    color:
                        highlightColor.color), // hint text 색 설정. (Add tasks...)
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
                addTodo(ToDo(_todoController.text));
              }
            },
            icon: Icon(
              Icons.add_circle_outlined,
              color: highlightColor.color,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }

  // 색상 설정창을 띄우는 메소드
  void _showSettings() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('색상 설정'),
          content: Column(
            children: [
              _buildColorOption(appbarColor), // appbar color
              _buildColorOption(
                  scaffoldBackgroundColor), // scaffold background color
              _buildColorOption(todoContainerColor), // todo container color
              _buildColorOption(highlightColor), // highlight color
              _buildColorOption(textColor), // text color
              _buildColorOption(myCheckColor), // my check color
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

  // 색상 설정창을 띄우는 메소드(실제 list 출력)
  Widget _buildColorOption(MyColor myColor) {
    return ListTile(
      title: Text(myColor.title),
      onTap: () {
        _showColorPickerDialog(myColor);
      },
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: myColor.color,
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }

  // 색상 선택하면 color picker dialog 띄우는 메소드
  void _showColorPickerDialog(MyColor myColor) {
    Color pickedColor = myColor.color;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              hexInputBar: true,
              pickerColor: myColor.color,
              onColorChanged: (newColor) {
                setState(() => pickedColor = newColor);
              },
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('확인'),
              onPressed: () {
                setState(() {
                  myColor.color = pickedColor;
                  _saveColor();
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
