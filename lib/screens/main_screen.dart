// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator_app/providers/main_screen_provider.dart';
import 'package:translator_app/providers/theme_provider.dart';
import 'package:translator_app/screens/camera_screen.dart';
import 'package:translator_app/screens/chat_screen.dart';
import 'package:translator_app/screens/translation_screen.dart';
import 'package:translator_app/providers/translation_provider.dart';

// 앱의 메인 화면을 구성하는 ConsumerWidget
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  // 각 탭에 해당하는 화면 위젯 목록을 저장
  static const List<Widget> _widgetOptions = <Widget>[
    TranslationScreen(), // 0번 탭: 번역 화면
    CameraScreen(),      // 1번 탭: 카메라 화면
    ChatScreen(),        // 2번 탭: 채팅 화면
  ];

  // 위젯의 UI를 빌드하는 메서드
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // mainScreenProvider를 통해 현재 선택된 탭의 인덱스를 감시
    final selectedIndex = ref.watch(mainScreenProvider);
    // themeProvider를 통해 현재 테마 모드를 감시
    final currentTheme = ref.watch(themeProvider);
    // 탭 인덱스에 따른 AppBar 제목 목록
    final titles = ['GoSungTalk 번역', '카메라 번역', 'GoSungTalk 채팅'];

    return Scaffold(
      // AppBar를 설정
      appBar: AppBar(
        title: Text(titles[selectedIndex]), // 현재 탭에 맞는 제목을 표시
        centerTitle: true, // 제목을 중앙에 정렬
        actions: [
          // 테마 변경 버튼
          IconButton(
            icon: Icon(currentTheme == ThemeMode.dark
                ? Icons.light_mode_outlined // 다크 모드일 때 밝은 모드 아이콘 표시
                : Icons.dark_mode_outlined), // 밝은 모드일 때 어두운 모드 아이콘 표시
            onPressed: () {
              // 버튼을 누르면 테마를 토글하는 기능을 호출
              ref.read(themeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      // 현재 선택된 탭에 해당하는 화면을 본문에 표시
      body: Center(child: _widgetOptions.elementAt(selectedIndex)),
      // 하단 네비게이션 바를 설정
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.translate), label: '번역'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '카메라'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
        ],
        currentIndex: selectedIndex, // 현재 선택된 탭을 활성화

        
        onTap: (index) {
          // 현재 탭이 번역 탭이고, 이동하려는 탭이 다른 탭일 경우
          if (selectedIndex == 0 && index != 0) {
            // translationProvider의 상태를 강제로 초기화
            // -> 번역 탭에서 출력 박스가 초기화가 안돼서 추가
            ref.invalidate(translationProvider);
          }
          // 선택된 탭의 인덱스를 새로운 값으로 업데이트
          ref.read(mainScreenProvider.notifier).state = index;
        },
      ),
    );
  }
}