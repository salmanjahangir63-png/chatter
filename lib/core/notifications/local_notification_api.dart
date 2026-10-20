import 'dart:convert';

import 'package:chatter/app/my_app.dart';
import 'package:chatter/extensions/context_extensions.dart';
import 'package:chatter/modules/chat/pages/chat_page.dart';
import 'package:chatter/modules/conversations/cubits/conversations_cubit.dart';
import 'package:chatter/modules/conversations/models/conversations_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsApi {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  LocalNotificationsApi({
    FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin,
  }) : _flutterLocalNotificationsPlugin =
           flutterLocalNotificationsPlugin ?? FlutterLocalNotificationsPlugin();

  ///create channel
  final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'notification_channel', // id
    'App Channel', // title
    description:
        'This channel is used for important notifications', // description
    importance: Importance.high,
  );

  /// Initialize
  Future<void> initialize() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
    print('Local messaging initialized');
    await _initSetting();
  }

  /// Show Notification
  void showNotification(
    RemoteMessage remoteMessage,
    AndroidNotification? android,
  ) async {
    RemoteNotification? notification = remoteMessage.notification;

    if (notification != null && android != null) {
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
            // Without file extension
          );
      // DarwinNotificationDetails iOSPlatformChannelSpecifics =
      //     DarwinNotificationDetails(
      //   sound: 'noti.wav', // Must be .wav for iOS
      // );
      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,

        // iOS: iOSPlatformChannelSpecifics
      );
      await _flutterLocalNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: notificationDetails,
        payload: jsonEncode(remoteMessage.data),
      );
    }
  }

  /// Remove Notification
  Future<void> removeNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
  }

  /// Initialize Settings
  Future<void> _initSetting() async {
    // android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    // darwin/IOS
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          defaultPresentSound: true,
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    // initializationSettings for Android/IOS
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );
    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  /// On select notification
  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    print('Payload is clicked}');
    if (notificationResponse.payload != null) {
      Map<String, dynamic> jsonResponse = jsonDecode(payload!);
      if (jsonResponse['type'] == 'chat') {
        final context = navigatorKey.currentContext;
        final conversationCubit = context?.read<ConversationsCubit>();
        final currentUser = context?.getCurrentUser;

        final conversation = ConversationModel.fromJson(
          json.decode(jsonResponse['conversation']),
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
  }
}
