import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:player/repo/player/player_api.dart';
import 'package:player/repo/repo_client.dart';
import '../../utils/all_utils.dart';
import '../entity/basic_response.dart';

class PlayerClient implements DataClient {
  final Dio _dio = Dio();

  PlayerClient() {
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: print,
    ));
  }

  @override
  init() {}

  PlayerApi _makeApi() => PlayerApi(_dio);

  Future<CommonResponse<T>> _requestCall<T>(ApiCall<T> apiCall) async {
    T? payload;
    CommonError? error;
    try {
      payload = await apiCall.call();
    } on Exception catch (obj) {
      logError('player call failed: ${obj.toString()}');
      error = handleException(obj);
    }
    return CommonResponse(response: payload, error: error);
  }

  CommonError? handleException(Exception obj) {
    if (obj is DioException) {
      final res = obj.response;
      if (res?.data != null) {
        return CommonError(
          errorCode: apiNetworkError,
          errorMessage: obj.message,
        );
      } else {
        String errorCode;
        String? errorMsg;
        if (obj.error is SocketException) {
          errorCode = apiNetworkError;
          errorMsg = obj.message;
        } else if (obj.error is TimeoutException) {
          errorCode = apiRequestTimeoutError;
          errorMsg = obj.message;
        } else {
          errorCode = apiHttpServerError;
          errorMsg = obj.message;
        }
        return CommonError(
          errorCode: errorCode,
          errorMessage: errorMsg,
        );
      }
    }
    return CommonError(
      errorCode: apiUnknownError,
      errorMessage: obj.toString(),
    );
  }
}
