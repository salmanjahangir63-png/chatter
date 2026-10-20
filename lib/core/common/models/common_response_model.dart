CommonResponseModel commonResponseFromJson<T>(dynamic json) =>
    CommonResponseModel.fromJson(json);

class CommonResponseModel {
  final String result;
  final String message;
  final dynamic data;

  CommonResponseModel({
    required this.result,
    required this.message,
    required this.data,
  });

  factory CommonResponseModel.fromJson(Map<String, dynamic> json) {
    return CommonResponseModel(
      result: json['result'],
      message: json['message'],
      data: json['data'],
    );
  }
}
