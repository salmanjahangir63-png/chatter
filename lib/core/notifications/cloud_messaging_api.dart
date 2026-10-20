import 'dart:convert';
import 'dart:io';

import 'package:chatter/app/my_app.dart';
import 'package:chatter/core/di/service_locator.dart';
import 'package:chatter/extensions/context_extensions.dart';
import 'package:chatter/modules/chat/pages/chat_page.dart';
import 'package:chatter/modules/conversations/cubits/conversations_cubit.dart';
import 'package:chatter/modules/conversations/models/conversations_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'local_notification_api.dart';

List<String> newTripNotifications = [];

class CloudMessagingApi {
  final FirebaseMessaging _firebaseMessaging;

  CloudMessagingApi({FirebaseMessaging? firebaseMessaging})
    : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  Future<void> initialize() async {
    print('Cloud messaging initialized');
    await _firebaseMessaging.requestPermission();
    if (Platform.isIOS) {
      await _setForegroundNotificationsPresentationOptionsIOS();
      await _requestNotificationPermissionForIOS();
    }

    // Foreground
    _handleOnMessageWhenAppInForeground();

    // Background
    _handleOnMessageOpenedAppFromBackground();

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) {},
      onError: (error) {
        print('[CloudMessagingApi] onTokenRefresh error: $error');
      },
    );
  }

  /// When the app is in foreground [onMessage]
  void _handleOnMessageWhenAppInForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.data['type']);
      print(message.data);
      print(' foreground!');
      print('Message data: ${message.notification}');

      if (message.notification != null) {
        print('Message Notification Body: ${message.notification!.body}');

        _handleShowNotification(message);
      }
    });
  }

  void _handleShowNotification(RemoteMessage message) async {
    AndroidNotification? android = message.notification?.android;

    sl<LocalNotificationsApi>().showNotification(message, android);
  }

  /// When user click from the background state [onMessageOpenedApp]
  void _handleOnMessageOpenedAppFromBackground() async {
    print('Got a message whilst in the BackGround!');
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  /// When notification is clicked from background state...
  void _handleMessage(RemoteMessage message) {
    if (message.notification == null) return;
    if (message.data['type'] == 'chat') {
      final context = navigatorKey.currentContext;
      final conversationCubit = context?.read<ConversationsCubit>();
      final currentUser = context?.getCurrentUser;
      final conversation = ConversationModel.fromJson(
        jsonDecode(message.data['conversation']),
      );
      bool isMe = conversation.sender.id == currentUser?.id;
      conversationCubit?.joinConversation(conversation.id);
      Navigator.push(
        context!,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            recipientId: isMe
                ? conversation.receiver.id
                : conversation.sender.id,
            recipientName: isMe
                ? conversation.receiver.name
                : conversation.sender.name,
            conversationId: conversation.id,
          ),
        ),
      ).then((v) {
        conversationCubit?.leaveConversation();
      });
      print('Conversation is ${conversation.id}');
    }
  }

  Future<RemoteMessage?> getInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    return initialMessage;
  }

  Future<String?> getFcmToken() async {
    try {
      if (Platform.isIOS) {
        final apnsReady = await waitForApnsToken();
        if (!apnsReady) {
          print(
            '[CloudMessagingApi] getFcmToken: APNs token never arrived '
            'within timeout — returning null (this will also be picked '
            'up later via onTokenRefresh once it does arrive).',
          );
          return null;
        }
      }
      final token = await _firebaseMessaging.getToken();
      print(
        '[CloudMessagingApi] getFcmToken: success, '
        'length=${token?.length ?? 0}',
      );
      return token;
    } catch (e, stack) {
      // FIX: log instead of silently swallowing — this is exactly what was
      // hiding the apns-token-not-set failures before.
      print('[CloudMessagingApi] getFcmToken failed: $e');
      print(stack);
      return null;
    }
  }

  /// Polls for the APNs token to become available, bounded to ~10 seconds.
  /// Returns true once it's set, false if the timeout is hit without it
  /// ever arriving.
  ///
  /// Public (not _-prefixed) so other call sites that also need APNs ready
  /// first — e.g. subscribeToTopic() in SplashScreen.dart, which throws the
  /// exact same apns-token-not-set race — can reuse this instead of each
  /// duplicating their own polling logic.
  Future<bool> waitForApnsToken({
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 300),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null) return true;
      await Future.delayed(pollInterval);
    }
    return false;
  }

  Future<void> deleteFcmToken() async {
    _firebaseMessaging.deleteToken();
  }

  Future<void> _setForegroundNotificationsPresentationOptionsIOS() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true, // Required to display a heads up notification
          badge: true,
          sound: true,
        );
  }

  Future<void> _requestNotificationPermissionForIOS() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
}
