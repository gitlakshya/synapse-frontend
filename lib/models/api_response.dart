class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final ApiError? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode, String? errorCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      error: ApiError(message: message, code: errorCode),
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    try {
      if (json['success'] == true || json['status'] == 'success') {
        return ApiResponse.success(
          fromJson(json['data']),
          message: json['message'],
          statusCode: json['statusCode'],
        );
      } else {
        return ApiResponse.error(
          json['message'] ?? 'Unknown error',
          statusCode: json['statusCode'],
          errorCode: json['errorCode'],
        );
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }
}

class ApiError {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  ApiError({
    required this.message,
    this.code,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'Unknown error',
      code: json['code'],
      details: json['details'],
    );
  }
}