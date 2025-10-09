// lib/screens/translation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator_app/models/translation_state.dart';
import 'package:translator_app/providers/translation_provider.dart';

// 번역 화면을 표시하는 ConsumerStatefulWidget
class TranslationScreen extends ConsumerStatefulWidget {
  const TranslationScreen({super.key});

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

// TranslationScreen의 상태를 관리하는 클래스
class _TranslationScreenState extends ConsumerState<TranslationScreen> {
  // 텍스트 입력 필드를 제어하기 위한 컨트롤러
  late final TextEditingController _textController;

  // 위젯이 생성될 때 한 번 호출되는 초기화 메서드
  @override
  void initState() {
    super.initState();
    // TextEditingController를 초기화
    _textController = TextEditingController();
  }

  // 위젯이 화면에서 제거될 때 컨트롤러 리소스를 해제하는 기능
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // 위젯의 UI를 구성하는 메서드
  @override
  Widget build(BuildContext context) {
    // translationProvider의 상태를 감시(watch)
    final state = ref.watch(translationProvider);
    // translationProvider의 notifier 인스턴스를 읽어옴(read)
    final notifier = ref.read(translationProvider.notifier);

    // translationProvider의 상태 변경을 감지(listen)하여 특정 동작을 수행
    ref.listen<TranslationState>(translationProvider, (previous, next) {
      // 오류 메시지가 새로 발생했을 때 SnackBar를 표시
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }

      // 외부(예: 언어 스왑)에서 텍스트가 변경되었을 때, 컨트롤러에 반영
      if (next.inputText != _textController.text) {
        _textController.text = next.inputText;
      }
    });

    // 화면의 기본 레이아웃을 구성
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 출발/도착 언어 선택 UI를 빌드
              _buildLanguageSelector(context, state, notifier),
              const SizedBox(height: 16),
              // 번역할 텍스트 입력 UI를 빌드
              _buildTextBox(_textController, '번역할 텍스트 입력...', notifier, state),
              const SizedBox(height: 16),
              // 번역 결과 표시 UI를 빌드
              _buildResultBox(state, notifier, context),
            ],
          ),
        ),
      ),
    );
  }

  // 언어 선택 드롭다운과 교환 버튼 UI를 생성하는 메서드
  Widget _buildLanguageSelector(
    BuildContext context,
    TranslationState state,
    TranslationNotifier notifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 출발 언어 선택 드롭다운
        Expanded(
          child: _languageDropdown(state.sourceLanguage, (value) {
            if (value != null) notifier.setSourceLanguage(value);
          }),
        ),
        // 언어 교환 버튼
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          onPressed: notifier.swapLanguages,
          tooltip: '언어 교환',
        ),
        // 도착 언어 선택 드롭다운
        Expanded(
          child: _languageDropdown(state.targetLanguage, (value) {
            if (value != null) notifier.setTargetLanguage(value);
          }),
        ),
      ],
    );
  }

  // 개별 언어 선택 드롭다운 위젯을 생성하는 메서드
  Widget _languageDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        // 지원 언어 목록으로 드롭다운 아이템을 생성
        items: TranslationState.supportedLanguages.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.value,
            child: Center(child: Text(entry.key)),
          );
        }).toList(),
        onChanged: onChanged,
        underline: Container(), // 기본 밑줄 제거
      ),
    );
  }

  // 텍스트 입력 상자와 관련 버튼들을 생성하는 메서드
  Widget _buildTextBox(
    TextEditingController controller,
    String hint,
    TranslationNotifier notifier,
    TranslationState state,
  ) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          // 텍스트 입력 필드
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none, // 테두리 없음
              ),
              maxLines: null,
              // 여러 줄 입력 가능
              onChanged: notifier.setInputText,
              // 텍스트 변경 시 notifier에 알림
              textInputAction: TextInputAction.done,
            ),
          ),
          // 하단 버튼들 (지우기, 음성 입력)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 텍스트 전체 삭제 버튼
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => notifier.setInputText(''),
                tooltip: '지우기',
              ),
              // 음성 입력 시작/정지 버튼
              IconButton(
                icon: Icon(
                  state.isListening ? Icons.mic_off : Icons.mic,
                  color: state.isListening ? Colors.red : null,
                ),
                onPressed: state.isListening
                    ? notifier.stopListening
                    : notifier.startListening,
                tooltip: '음성 입력',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 번역 결과 상자와 관련 버튼들을 생성하는 메서드
  Widget _buildResultBox(
    TranslationState state,
    TranslationNotifier notifier,
    BuildContext context,
  ) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 번역된 텍스트 표시 영역
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                // 로딩 중일 때는 로딩 인디케이터, 아닐 때는 번역된 텍스트를 표시
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SelectableText(
                        // 사용자가 텍스트를 선택/복사할 수 있게 함
                        state.translatedText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16.0,
                        ),
                      ),
              ),
            ),
          ),
          // 하단 버튼들 (복사, 듣기)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 번역된 텍스트 복사 버튼
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  if (state.translatedText.isNotEmpty) {
                    Clipboard.setData(
                      ClipboardData(text: state.translatedText),
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('복사되었습니다.')));
                  }
                },
                tooltip: '복사',
              ),
              // 번역된 텍스트 음성으로 듣기 버튼
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: notifier.speakTranslatedText,
                tooltip: '듣기',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
