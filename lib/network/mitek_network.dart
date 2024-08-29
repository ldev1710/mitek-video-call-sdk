part of '../mitek_video_call_sdk.dart';

class _MTNetwork {
  static late Dio _dio;
  static final _MTNetwork _instance = _MTNetwork._internal();
  static _MTNetwork get instance => _instance;
  _MTNetwork._internal();
  factory _MTNetwork() {
    _dio = Dio();
    _dio
      ..options.baseUrl = MTNetworkConstant.url
      ..options.connectTimeout = const Duration(seconds: MTConstant.connectTimeOut)
      ..options.receiveTimeout = const Duration(seconds: MTConstant.receiveTimeOut)
      ..options.responseType = ResponseType.json;
    return _instance;
  }

  String? _apiKey;

  void setApiKey({required String apiKey}) {
    _apiKey = apiKey;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.get(
        path,
        options: Options(
          headers: {
            'x-api-key': _apiKey,
          },
        ),
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      return Response(requestOptions: RequestOptions(), data: null);
    }
  }

  Future<Response> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.post(
        uri,
        options: Options(
          headers: {
            'x-api-key': _apiKey,
          },
        ),
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      return Response(requestOptions: RequestOptions(), data: null);
    }
  }
}
