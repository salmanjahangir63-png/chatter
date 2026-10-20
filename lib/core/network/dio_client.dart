import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class DioClient extends DioForNative {
  final String baseUrl;
  String? authToken;

  void setToken(String token) {
    authToken = token;
  }

  DioClient({required this.baseUrl}) {
    options = BaseOptions(baseUrl: baseUrl, responseType: ResponseType.json);
    interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handlers) {
          if (authToken != null) {
            options.headers.putIfAbsent(
              'Authorization',
              () => 'Bearer $authToken',
            );

          }
          handlers.next(options);
        },
      ),
    );
    interceptors.add(
      LogInterceptor(
        responseHeader: true,
        responseBody: true,
        requestHeader: true,
        request: true,
        requestBody: true,
      ),
    );
  }
}
