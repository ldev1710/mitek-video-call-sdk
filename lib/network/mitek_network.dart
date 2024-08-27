import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mitek_video_call_sdk/utils/constants.dart';

class MTNetwork {
  static late Dio _dio;
  static final MTNetwork _instance = MTNetwork._internal();
  static MTNetwork get instance => _instance;
  MTNetwork._internal();
  factory MTNetwork() {
    _dio = Dio();
    _dio
      ..options.baseUrl = MTNetworkConstant.url
      ..options.connectTimeout = const Duration(seconds: MTConstant.connectTimeOut)
      ..options.receiveTimeout = const Duration(seconds: MTConstant.receiveTimeOut)
      ..options.responseType = ResponseType.json;
    _dio.interceptors.add(AuthorizationInterceptor());
    return _instance;
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

class AuthorizationInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {}

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {}
}
