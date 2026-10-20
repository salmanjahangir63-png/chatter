import 'package:chatter/core/common/repositories/session_repository.dart';
import 'package:chatter/core/network/dio_client.dart';
import 'package:chatter/core/notifications/cloud_messaging_api.dart';
import 'package:chatter/core/notifications/local_notification_api.dart';
import 'package:chatter/core/security/secured_auth_storage.dart';
import 'package:chatter/core/storage_service/storage_service.dart';
import 'package:chatter/modules/authentication/repository/auth_repository.dart';
import 'package:chatter/modules/chat/repository/chat_repository.dart';
import 'package:chatter/modules/conversations/repository/conversation_repository.dart';
import 'package:chatter/modules/user/repository/user_account_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> setUpLocator() async {
  /// ==================== Notifications =========================
  sl.registerLazySingleton<LocalNotificationsApi>(
    () => LocalNotificationsApi(),
  );
  sl.registerLazySingleton<CloudMessagingApi>(() => CloudMessagingApi());

  /// ==================== Shared Pref =========================
  sl.registerSingletonAsync<SharedPreferences>(
    () async => SharedPreferences.getInstance(),
  );

  /// ==================== DataBase ===========================
  sl.registerLazySingleton<SecuredAuthStorage>(() => SecuredAuthStorage());

  sl.registerSingletonWithDependencies<StorageService>(
    () => StorageService(sharedPreferences: sl<SharedPreferences>()),
    dependsOn: [SharedPreferences],
  );

  /// ==================== Networking ===========================
  sl.registerLazySingleton<DioClient>(
    () => DioClient(baseUrl: 'http://192.168.8.122:5001/api/'),
  );

  /// ==================== Modules ===========================

  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepository(
      storageService: sl<StorageService>(),
      securedAuthStorage: sl<SecuredAuthStorage>(),
    ),
  );

  sl.registerLazySingleton<UserAccountRepository>(
    () => UserAccountRepository(
      storageService: sl<StorageService>(),
      sessionRepository: sl<SessionRepository>(),
      dioClient: sl<DioClient>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      dioClient: sl<DioClient>(),
      sessionRepository: sl<SessionRepository>(),
      userAccountRepository: sl<UserAccountRepository>(),
    ),
  );

  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepository(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepository(dioClient: sl<DioClient>()),
  );
}
