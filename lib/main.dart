// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:translator_app/providers/theme_provider.dart';
import 'package:translator_app/screens/main_screen.dart';

// 앱의 시작점(entry point) 역할을 하는 main 함수
Future<void> main() async {
  // Flutter 엔진과 위젯 트리를 확실하게 초기화하는 기능
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일로부터 환경 변수를 로드하는 기능
  await dotenv.load(fileName: ".env");
  // 앱을 실행하는 함수, ProviderScope로 전체 앱을 감싸 Riverpod를 사용할 수 있게 함
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

// 앱의 최상위 위젯 클래스
class MyApp extends ConsumerWidget {
  // MyApp 위젯의 생성자
  const MyApp({super.key});

  // 위젯의 UI를 빌드하는 메서드
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // themeProvider를 통해 현재 테마 모드를 감시(watch)하는 기능
    final themeMode = ref.watch(themeProvider);

    // MaterialApp 위젯을 반환하여 앱의 기본 구조와 테마를 설정하는 기능
    return MaterialApp(
      title: 'GoSungTalk', // 앱의 제목을 설정
      debugShowCheckedModeBanner: false, // 디버그 배너를 숨김
      // 밝은 테마에 대한 설정
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      // 어두운 테마에 대한 설정
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      // 현재 적용할 테마 모드를 지정
      themeMode: themeMode,
      // 앱의 홈 화면을 MainScreen으로 설정
      home: const MainScreen(),
    );
  }
}