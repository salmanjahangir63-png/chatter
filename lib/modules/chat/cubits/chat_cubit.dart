import 'package:chatter/core/common/models/common_response_model.dart';
import 'package:chatter/core/network/socket_service.dart';
import 'package:chatter/modules/chat/models/message_model.dart';
import 'package:chatter/modules/chat/repository/chat_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  ChatCubit({required ChatRepository chatRepository})
    : _chatRepository = chatRepository,
      super(ChatState.initial());
  SocketService socketService = SocketService.instance;

  Future<void> getAllMessages(String conversationId) async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));
      List<MessageModel> messages = await _chatRepository.getAllMessages(
        conversationId,
      );

      emit(state.copyWith(messages: messages, status: ChatStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error, message: '$e'));
    }
  }

  void listenToNewMessage() {
    socketService.socket.on(SocketListeners.receiveMessage, (data) {

        emit(state.copyWith(status: ChatStatus.receiving));
        if (data is! Map) return;
        CommonResponseModel commonResponseModel = CommonResponseModel.fromJson(
          data as Map<String, dynamic>,
        );
        MessageModel newMessage = MessageModel.fromJson(
          commonResponseModel.data,
        );
        state.messages.add(newMessage);

        emit(
          state.copyWith(messages: state.messages, status: ChatStatus.success),
        );

    });
  }

  void sendMessage(String content, String recipientID) {
    emit(state.copyWith(status: ChatStatus.sending));
    socketService.socket.emit(SocketEmit.sendMessage, {
      "type": "private",
      "recipientId": recipientID,
      "content": content,
    });
    emit(state.copyWith(status: ChatStatus.sent));
  }

  @override
  Future<void> close() {
    socketService.socket.off(SocketListeners.receiveMessage);
    return super.close();
  }
}
