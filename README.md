# todo

- 플러터로 todo list만들기

- 참고한 양식 : https://www.behance.net/gallery/127460643/TO-DO-List?tracking_source=search_projects_views|todolist

- 테스트 한 환경 : Pixel 3 XL API 34
    - Android API 34 Google APIs | x86_64
---
## 1일차 목표
 - 기본 화면 구성 -> 어느정도 ok.
 - todo를 텍스트로 적어 추가 ok.
 
## 1일차 진행상황
 - 사용자 로컬저장소에 할일 목록들을 저장, 다시 실행시 그대로 출력하도록
    - SharedPreferences.getInstance() 활용.
 - to-do 삭제 기능.
    - dismissible 위젯을 사용하여, todo 리스트를 오른쪽에서 왼쪽으로 끌어당기면 자동으로 삭제되도록 설정.
 - 한 일 체크
    - 일이 끝나면 리스트 or 왼쪽의 체크박스를 클릭하면 취소선&이탤릭체로 변환됨
 - important 기능
    - 리스트의 오른쪽 끝에 별 아이콘을 사용하여 중요도를 추가.
 - 상태에 따른 to-do 분류
    - ALL , Completed, inCompleted, Important 로 나눔. (TabBar 위젯 사용.)
 
 ## 1일차 목표 중 못한것
 - 양식에 맞는 색깔
    - 왜 색깔 칠하는게 제일 어려운지 모르겠어요
 - 할일 text를 삭제 할 때 에러 발생
    - todo 목록들을 dismissible 위젯을 사용하였는데, dismissible 위젯은 key가 꼭 필요함.
    - key를 todo.title 을 사용함. 즉 할일 text를 그대로 key로 사용했음
    - 할 일 목록 내용이 정확하게 같으면, 삭제할때 중복되는 key가 존재해서 에러가 남
    - 아니 아까 에러났는데 지금은 왜 에러안나 큰일이야

---
## 2일차 목표
 - 삭제 기능.
 - 끝난 일 취소선 긋기.
 - important 표시.
 - 3가지 기능 모두 1일차에 해결함.

## 2일차 진행상황
 - scaffold background color 설정.
 - input창 색깔 설정.
 - main.dart에 모든 코드를 때려넣었는데, model과 page를 분류함.
   - 주석 일부분 추가.
   - 아직 to_do_list_page.dart 코드 가독성은 떨어짐.
 - 편집 기능 추가.
   - 할일을 왼쪽에서 오른쪽으로 스와이프하면 수정 alert 창이 뜬다. 그 창에 입력하면 입력한 내용으로 수정된다.
   - dismissible 위젯 문제인지, 스와이프를 하고 나면 해당 할일이 잠깐 사라짐.
   - 수정하지 않고 취소를 누르면, 할일이 사라진 채로 있음. 다른 tab으로 넘어갔다가 다시 오면 다시 생긴다.
   - 취소를 눌렀을 때 창을 새로고침 하면 해결이 될듯 함.

---
## 3일차 진행상황
 - 수정 기능 전면 교체
   - 기존 Dismissible 위젯 -> Slidable 위젯 사용.
      - pubspec.yaml 파일에 dependency:   flutter_slidable: ^3.0.0 추가 필요.
      - 원래 삭제기능을 오른쪽에서 왼쪽으로 스와이프 하면 되는 것 처럼 수정기능 또한 왼쪽으로 오른쪽으로 스와이프 하는 것으로 생각함.
      - 그러나 dismissible 위젯은 스와이프를 하면 무조건 UI상에서 dismiss 되게 되어 있음(UI상에서 해당 '할일' 이 없어짐.)
      - UI상에서는 없어지지만, 수정기능은 해당 할일이 사라지면 안되기 때문에 뭔가 충돌나서 에러가 계속 생김
      - dismissed dismissible widget is still part of the tree 에러 발생.
      - chat gpt에게 dismissible 위젯 말고 다른 스와이프 기능 있는 위젯을 알려달라함 -> Slidable 위젯 알려줌
      - Slidable 위젯을 사용하니, 스와이프하면 수정/삭제 버튼이 나오게 하고, 버튼을 누르면 기능을 수행하도록 함.
---
## 4일차 진행상황
 - 색상 설정창.
   - colorPicker 사용.
   - flutter_colorpicker: ^1.0.3
   - Appbar, Scaffold, todoContainer, highlight, text, checkbox 체크 색깔을 변경할 수 있음.
   - 아직 색깔 변경한 것을 local에 저장하는 기능은 넣지 않음. 즉 껐다 키면 초기색상으로 돌아감
   - SharedPreferences.getInstance() 사용하면 가능할것으로 보임.

---
## 5일차 진행상황
 - 색상 설정 로컬 저장소에 저장
   - sharedPreferences.getInstance 사용.
   - 색상 class 새로 만듬.
   - 코드 분리 시도
      - 실패. 너무 어려움