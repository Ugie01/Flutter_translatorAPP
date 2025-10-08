// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator_app/models/translation_state.dart';
import 'package:translator_app/providers/chat_provider.dart';
import 'package:translator_app/widgets/chat_bubble.dart';
import 'package:translator_app/models/chat_state.dart';

// 채팅 화면을 표시하는 ConsumerStatefulWidget
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

// ChatScreen의 상태를 관리하는 클래스
class _ChatScreenState extends ConsumerState<ChatScreen> {
  // 왼쪽, 오른쪽 텍스트 입력 필드를 제어하는 컨트롤러
  final TextEditingController _leftController = TextEditingController();
  final TextEditingController _rightController = TextEditingController();
  // 채팅 목록의 스크롤을 제어하는 컨트롤러
  final ScrollController _scrollController = ScrollController();

  // 위젯이 제거될 때 컨트롤러 리소스를 해제하는 기능
  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 메시지 전송 후 스크롤을 맨 아래로 이동시키는 기능
  void _scrollToBottom() {
    // 위젯 빌드가 완료된 후 스크롤 이동을 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent, // 스크롤 가능한 최대 위치
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 위젯의 UI를 빌드하는 메서드
  @override
  Widget build(BuildContext context) {
    // chatProvider의 상태를 감시
    final chatState = ref.watch(chatProvider);
    // chatProvider의 notifier 인스턴스를 읽어옴
    final chatNotifier = ref.read(chatProvider.notifier);

    // 메시지 목록이 변경될 때마다 스크롤을 맨 아래로 이동시키는 리스너
    ref.listen(chatProvider.select((state) => state.messages), (_, __) {
      _scrollToBottom();
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 언어 선택 UI를 빌드
          _buildLanguageSelectors(context, chatState, chatNotifier),
          const Divider(), // 구분선
          // 채팅 메시지 목록을 빌드
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return ChatBubble(message: message); // 각 메시지를 ChatBubble로 표시
              },
            ),
          ),
          const Divider(), // 구분선
          // 텍스트 입력 UI를 빌드
          _buildTextInputArea(context, chatState, chatNotifier),
        ],
      ),
    );
  }

  // 언어 선택 드롭다운과 교환 버튼 UI를 생성하는 메서드
  Widget _buildLanguageSelectors(
      BuildContext context,
      ChatState state,
      ChatNotifier notifier,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 왼쪽 언어 선택 드롭다운
        Expanded(
          child: _languageDropdown(state.leftLanguage, (value) {
            if (value != null) {
              notifier.setLeftLanguage(value);
            }
          }),
        ),
        // 언어 교환 버튼
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          onPressed: notifier.swapLanguages,
          tooltip: '언어 교환',
        ),
        // 오른쪽 언어 선택 드롭다운
        Expanded(
          child: _languageDropdown(state.rightLanguage, (value) {
            if (value != null) {
              notifier.setRightLanguage(value);
            }
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
        isExpanded: true, // 드롭다운을 확장하여 컨테이너 너비에 맞춤
        // 지원 언어 목록으로 드롭다운 아이템을 생성
        items: TranslationState.supportedLanguages.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.value,
            child: Center(
              child: Text(entry.key, overflow: TextOverflow.ellipsis), // 텍스트가 길면 ...으로 표시
            ),
          );
        }).toList(),
        onChanged: onChanged,
        underline: Container(), // 기본 밑줄 제거
      ),
    );
  }

  // 텍스트 입력 영역 전체(왼쪽, 오른쪽)를 생성하는 메서드
  Widget _buildTextInputArea(
      BuildContext context,
      ChatState state,
      ChatNotifier notifier,
      ) {
    return Column(
      children: [
        // 왼쪽 사용자 입력 필드
        _buildInputField(
          controller: _leftController,
          sender: MessageSender.left,
          hint: '좌측 사용자 메시지',
          state: state,
          notifier: notifier,
          alignment: CrossAxisAlignment.start,
        ),
        const SizedBox(height: 8),
        // 오른쪽 사용자 입력 필드
        _buildInputField(
          controller: _rightController,
          sender: MessageSender.right,
          hint: '우측 사용자 메시지',
          state: state,
          notifier: notifier,
          alignment: CrossAxisAlignment.end,
        ),
      ],
    );
  }

  // 개별 텍스트 입력 필드와 버튼(음성, 전송)을 생성하는 메서드
  Widget _buildInputField({
    required TextEditingController controller,
    required MessageSender sender,
    required String hint,
    required ChatState state,
    required ChatNotifier notifier,
    required CrossAxisAlignment alignment,
  }) {
    // 현재 입력 필드가 음성 입력을 듣고 있는지 여부를 확인
    final isListeningForThisSender = state.isListening &&
        ((sender == MessageSender.left && _leftController.text.isEmpty) ||
            (sender == MessageSender.right && _rightController.text.isEmpty));

    // 보낸 사람(sender)에 따라 버튼과 입력 필드의 순서를 결정
    return Row(
      children: sender == MessageSender.left
          ? [ // 왼쪽 사용자 UI 구성
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        // 음성 입력 버튼
        IconButton(
          icon: Icon(
            isListeningForThisSender ? Icons.mic_off : Icons.mic,
            color: isListeningForThisSender ? Colors.red : null,
          ),
          onPressed: () {
            if (state.isListening) {
              notifier.stopListening();
            } else {
              notifier.startListening(
                sender,
                    (text) => controller.text = text, // 음성 인식 결과를 텍스트 필드에 설정
              );
            }
          },
        ),
        // 메시지 전송 버튼
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            notifier.sendMessage(controller.text, sender);
            controller.clear(); // 전송 후 텍스트 필드 비우기
          },
        ),
      ]
          : [ // 오른쪽 사용자 UI 구성
        // 메시지 전송 버튼
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            notifier.sendMessage(controller.text, sender);
            controller.clear();
          },
        ),
        // 음성 입력 버튼
        IconButton(
          icon: Icon(
            isListeningForThisSender ? Icons.mic_off : Icons.mic,
            color: isListeningForThisSender ? Colors.red : null,
          ),
          onPressed: () {
            if (state.isListening) {
              notifier.stopListening();
            } else {
              notifier.startListening(
                sender,
                    (text) => controller.text = text,
              );
            }
          },
        ),
        Expanded(
          child: TextField(
            controller: controller,
            textAlign: TextAlign.end, // 텍스트 오른쪽 정렬
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}