import 'package:chatter/core/di/service_locator.dart';
import 'package:chatter/core/notifications/cloud_messaging_api.dart';
import 'package:chatter/core/notifications/local_notification_api.dart';
import 'package:chatter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Background error: $e');
  }
}

Future<void> initApp() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  await setUpLocator();
  await sl.allReady();
  sl<LocalNotificationsApi>().initialize();
  sl<CloudMessagingApi>().initialize();
}
