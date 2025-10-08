// lib/widgets/chat_bubble.dart

import 'package:flutter/material.dart';
import 'package:translator_app/models/chat_state.dart';

// 채팅 메시지 하나를 시각적으로 표시하는 위젯
class ChatBubble extends StatelessWidget {
  // 표시할 메시지 데이터를 저장
  final ChatMessage message;

  // ChatBubble 위젯의 생성자
  const ChatBubble({super.key, required this.message});

  // 위젯의 UI를 빌드하는 메서드
  @override
  Widget build(BuildContext context) {
    // 메시지 보낸 사람('left' 또는 'right')에 따라 정렬을 결정
    final alignment = message.sender == MessageSender.left
        ? CrossAxisAlignment.start // 왼쪽 정렬
        : CrossAxisAlignment.end;   // 오른쪽 정렬

    // 메시지 보낸 사람에 따라 말풍선 색상을 결정
    final color = message.sender == MessageSender.left
        ? Colors.white
        : Colors.blue[100];

    // 말풍선 전체의 레이아웃을 구성
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: alignment, // 결정된 정렬 적용
        children: [
          // 실제 말풍선 모양의 컨테이너
          Container(
            padding: const EdgeInsets.all(12.0),
            // 말풍선의 최대 너비를 화면 너비의 70%로 제한
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
                color: color, // 결정된 색상 적용
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade300)
            ),
            // 메시지가 로딩 중인지 여부에 따라 다른 위젯을 표시
            child: message.isLoading
                ? const SizedBox( // 로딩 중일 때 로딩 인디케이터 표시
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Column( // 로딩이 아닐 때 텍스트 표시
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 원본 텍스트를 표시
                Text(
                  message.originalText,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 4),
                // 번역된 텍스트를 표시
                Text(
                  message.translatedText,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}