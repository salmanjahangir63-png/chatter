part of 'chat_cubit.dart';

enum ChatStatus { initial, loading, success,receiving, sending, sent, error }

class ChatState extends Equatable {
  final List<MessageModel> messages;
  final ChatStatus status;
  final String message;

  const ChatState({
    required this.messages,
    required this.status,
    required this.message,
  });

  factory ChatState.initial() {
    return ChatState(messages: [], status: ChatStatus.initial, message: '');
  }

  ChatState copyWith({
    List<MessageModel>? messages,
    ChatStatus? status,
    String? message,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [message, messages, status];
}
