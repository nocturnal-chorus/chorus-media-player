class CommonResponse<T> {
  T? response;
  CommonError? error;

  CommonResponse({this.response, this.error});

  CommonResponse.fromJson(dynamic json) {
    response = json['response'];
    error = json['error'];
  }
}

class CommonError {
  String errorCode;
  String? errorMessage;

  CommonError({required this.errorCode, this.errorMessage});
}

const String apiNetworkError = '-1';

const String apiRequestTimeoutError = '-2';

const String apiServerError = '-3';

const String apiHttpServerError = '-4';

const String apiNoNetworkError = '-5';

const String apiUnknownError = '-6';
