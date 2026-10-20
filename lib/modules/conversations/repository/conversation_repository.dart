import 'package:chatter/constants/api_endpoints.dart';
import 'package:chatter/core/common/models/common_response_model.dart';
import 'package:chatter/core/network/dio_client.dart';
import 'package:chatter/modules/conversations/models/conversations_model.dart';
import 'package:flutter/foundation.dart';

class ConversationRepository {
  final DioClient _dioClient;

  ConversationRepository({required DioClient dioClient})
    : _dioClient = dioClient;

  Future<List<ConversationModel>> getAllConversations() async {
    final response = await _dioClient.get(ApiEndpoints.getAllConversations);
    CommonResponseModel commonResponseModel =
        await compute(commonResponseFromJson, response.data);

    return List<ConversationModel>.from(
      commonResponseModel.data.map((x) => ConversationModel.fromJson(x)),
    );
  }
}
