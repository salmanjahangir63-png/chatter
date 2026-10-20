import 'package:chatter/core/common/models/common_response_model.dart';
import 'package:chatter/core/di/service_locator.dart';
import 'package:chatter/core/network/socket_service.dart';
import 'package:chatter/extensions/context_extensions.dart';
import 'package:chatter/modules/chat/cubits/chat_cubit.dart';
import 'package:chatter/modules/chat/models/message_model.dart';
import 'package:chatter/ui/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatelessWidget {
  final String recipientId;
  final String conversationId;
  final String recipientName;
  const ChatPage({
    super.key,
    required this.recipientId,
    required this.conversationId,
    required this.recipientName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (_) => ChatCubit(chatRepository: sl()),
      child: ChatView(
        recipientId: recipientId,
        conversationId: conversationId,
        recipientName: recipientName,
      ),
    );
  }
}

class ChatView extends StatefulWidget {
  final String recipientId;
  final String conversationId;
  final String recipientName;
  const ChatView({
    super.key,
    required this.recipientId,
    required this.conversationId,
    required this.recipientName,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // List<MessageModel> messages = [];
  final messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    context.read<ChatCubit>().listenToNewMessage();
    context.read<ChatCubit>().getAllMessages(widget.conversationId);
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 56,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.getCurrentUser;
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state.status == ChatStatus.success) {
          scrollToBottom();
        }
        if (state.status == ChatStatus.sent) {
          scrollToBottom();
          messageController.clear();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Text(
              widget.recipientName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.vertical(
                bottom: Radius.circular(15),
              ),
            ),
          ),
          body: state.status == ChatStatus.loading
              ? LoadingIndicator()
              : state.status == ChatStatus.error
              ? Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: Colors.black, fontSize: 35),
                  ),
                )
              : Column(
                  children: [
                    SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        controller: _scrollController,

                        padding: EdgeInsets.symmetric(horizontal: 8),
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          bool isMe = message.sender == user.id;
                          return Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              BubbleSpecialThree(
                                text: message.content,
                                color: isMe ? Color(0xFF1B97F3) : Colors.grey,
                                tail: true,
                                isSender: isMe,
                                timestamp: DateFormat(
                                  'd MMM hh:mm a',
                                ).format(message.timestamp),
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8),
                        itemCount: state.messages.length,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  context.read<ChatCubit>().sendMessage(
                                    messageController.text.trim(),
                                    widget.recipientId,
                                  );
                                },
                                icon: Icon(Icons.send),
                                color: Colors.deepOrangeAccent,
                              ),
                              filled: true,
                              fillColor: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
}
