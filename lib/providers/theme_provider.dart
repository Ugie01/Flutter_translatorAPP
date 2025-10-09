import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 앱의 현재 테마 모드(light/dark)를 관리하는 StateNotifierProvider를 생성
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// 앱의 테마 상태(ThemeMode)를 관리하고 로직을 처리하는 클래스
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // 생성자: 초기 상태를 ThemeMode.light로 설정
  ThemeNotifier() : super(ThemeMode.light);

  // 현재 테마를 전환하는 메서드
  void toggleTheme() {
    // 현재 상태가 라이트 모드이면 다크 모드로, 아니면 라이트 모드로 상태를 변경
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
