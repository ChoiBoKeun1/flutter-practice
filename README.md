# todo

- 플러터로 todo list만들기

- 참고한 양식 : https://www.behance.net/gallery/127460643/TO-DO-List?tracking_source=search_projects_views|todolist

- 테스트 한 환경 : Pixel 3 XL API 34
    - Android API 34 Google APIs | x86_64
---
## 1일차 목표
 - 기본 화면 구성 -> 어느정도 ok.
 - todo를 텍스트로 적어 추가 ok.
 
## 더 진행한 것
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
