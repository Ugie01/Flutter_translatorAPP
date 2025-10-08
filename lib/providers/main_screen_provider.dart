import 'package:flutter_riverpod/flutter_riverpod.dart';

// MainScreen의 현재 선택된 탭 인덱스를 관리하는 StateProvider를 생성
// 초기값은 0 (번역 탭)으로 설정
final mainScreenProvider = StateProvider<int>((ref) => 0);