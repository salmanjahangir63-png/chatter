import 'package:chatter/core/network/dio_client.dart';
import 'package:chatter/core/network/socket_service.dart';
import 'package:chatter/modules/conversations/models/conversations_model.dart';
import 'package:chatter/modules/conversations/repository/conversation_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final DioClient _dioClient;
  final ConversationRepository _conversationRepository;
  ConversationsCubit({
    required ConversationRepository conversationRepository,
    required DioClient dioClient,
  }) : _conversationRepository = conversationRepository,
       _dioClient = dioClient,
       super(ConversationsState.initial());

  SocketService socketService = SocketService.instance;

  void listenToConversationUpdate() {
    socketService.socket.on(SocketListeners.conversationUpdated, (data) {
      emit(state.copyWith(status: ConversationStatus.updating));

      if (data is! Map) return;
      ConversationModel conversationModel = ConversationModel.fromJson(
        data as Map<String, dynamic>,
      );
      print(conversationModel.content);
      final index = state.conversations.indexWhere(
        (item) => item.id == conversationModel.id,
      );

      if (index != -1) {
        state.conversations.removeAt(index);
      }

      state.conversations.insert(0, conversationModel);
      emit(
        state.copyWith(
          conversations: state.conversations,
          status: ConversationStatus.success,
        ),
      );
    });
  }

  Future<void> getAllConversations() async {
    emit(state.copyWith(status: ConversationStatus.loading));
    try {
      final response = await _conversationRepository.getAllConversations();
      emit(
        state.copyWith(
          conversations: response,
          status: ConversationStatus.success,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ConversationStatus.error, message: '$e'));
    }
  }

  Future<void> initializeSocket() async {
    String? authToken = _dioClient.authToken;
    if (authToken == null) return;

    await socketService.initSocket(
      url: 'http://192.168.8.122:5001',
      token: authToken,
    );
  }

  void joinConversation(String conversationId) {
    socketService.socket.emit(SocketEmit.joinConversation, {
      'conversationId': conversationId,
    });
  }

  void leaveConversation() {
    socketService.socket.emit(SocketEmit.leaveConversation);
  }

  int getCount({required Map<String,dynamic> unreadCount ,required String userId}) {
    return unreadCount[userId]??0;
  }
}
