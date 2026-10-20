import 'package:chatter/core/di/service_locator.dart';
import 'package:chatter/core/network/dio_client.dart';
import 'package:chatter/core/network/socket_service.dart';
import 'package:chatter/extensions/context_extensions.dart';
import 'package:chatter/modules/authentication/screens/login_screen.dart';
import 'package:chatter/modules/chat/pages/chat_page.dart';
import 'package:chatter/modules/conversations/cubits/conversations_cubit.dart';
import 'package:chatter/modules/user/cubits/user_cubit.dart';
import 'package:chatter/ui/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    final conversationCubit = context.read<ConversationsCubit>();
    conversationCubit.initializeSocket();
    conversationCubit.listenToConversationUpdate();
    conversationCubit.getAllConversations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final conversationCubit = context.read<ConversationsCubit>();
    final currentUser = context.getCurrentUser;
    return BlocConsumer<ConversationsCubit, ConversationsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Text(
              'Conversations Page',
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
            actions: [
              BlocListener<UserCubit, UserState>(
                listener: (context, state) {
                  if (state.status == UserStatus.loggedOut) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: IconButton(
                  onPressed: () {
                    context.read<UserCubit>().logout();
                  },
                  icon: Icon(Icons.logout),
                  color: Colors.red,
                  iconSize: 28,
                ),
              ),
            ],
          ),
          body: state.status == ConversationStatus.loading
              ? LoadingIndicator()
              : state.status == ConversationStatus.error
              ? Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: Colors.black, fontSize: 35),
                  ),
                )
              : state.conversations.isEmpty
              ? Center(
                  child: Text(
                    'No chat found',
                    style: TextStyle(color: Colors.black, fontSize: 35),
                  ),
                )
              : ListView.separated(
                  itemBuilder: (context, index) {
                    final currentConversation = state.conversations[index];
                    bool isMe =
                        currentConversation.sender.id == currentUser.id;
                    int count =conversationCubit.getCount(unreadCount: currentConversation.unreadCounts,userId:currentUser.id );
                    return ListTile(
                      onTap: () {
                        conversationCubit.joinConversation(
                          currentConversation.id,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              recipientId: isMe
                                  ? currentConversation.receiver.id
                                  : currentConversation.sender.id,
                              recipientName: isMe
                                  ?currentConversation.receiver.name
                                  :currentConversation.sender.name,
                              conversationId: currentConversation.id,
                            ),
                          ),
                        ).then((v) {
                          conversationCubit.leaveConversation();
                        });
                      },
                      title: Text(
                        isMe
                            ? currentConversation.receiver.name
                            : currentConversation.sender.name,
                      ),
                      subtitle: Text(currentConversation.content),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (count!=0)
                            CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 10,
                              child: Center(
                                child: Text(
                                  count.toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          Text(state.conversations[index].timeAgo),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 16);
                  },
                  itemCount: state.conversations.length,
                ),
        );
      },
    );
  }
}
