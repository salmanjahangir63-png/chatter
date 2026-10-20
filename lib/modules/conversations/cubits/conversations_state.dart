part of 'conversations_cubit.dart';

enum ConversationStatus { initial, loading,updating, success, error }

class ConversationsState extends Equatable {
  final List<ConversationModel> conversations;
  final ConversationStatus status;
  final String message;

  const ConversationsState({
    required this.conversations,
    required this.status,
    required this.message,
  });

  factory ConversationsState.initial() {
    return ConversationsState(
      conversations: [],
      status: ConversationStatus.initial,
      message: '',
    );
  }

  ConversationsState copyWith({
    List<ConversationModel>? conversations,
    ConversationStatus? status,
    String? message,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      status: status ?? this.status,
      message: message ?? '',
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [conversations, status, message];
}
