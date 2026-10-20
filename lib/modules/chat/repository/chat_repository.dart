import 'package:chatter/constants/api_endpoints.dart';
import 'package:chatter/core/common/models/common_response_model.dart';
import 'package:chatter/core/exceptions/api_error.dart';
import 'package:chatter/core/network/dio_client.dart';
import 'package:chatter/modules/chat/models/message_model.dart';
import 'package:dio/dio.dart';

class ChatRepository {
  final DioClient _dioClient;

  ChatRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<MessageModel>> getAllMessages(String conversationId) async {
    try {
      var response = await _dioClient.get(
        ApiEndpoints.getAllMessages,
        queryParameters: {'conversationId': conversationId},
      );
      CommonResponseModel commonResponseModel = CommonResponseModel.fromJson(
        response.data,
      );
      return commonResponseModel.data
          .map<MessageModel>((item) => MessageModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } on TypeError catch (e) {
      throw ApiError(message: e.toString(), code: 0);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}
