import 'dart:io';
import 'package:dio/dio.dart';
import '../../data/models/entities/general_error_entity.dart';
import '../../../generated/l10n.dart';

class ErrorUtils {

  /// Thông báo lỗi server trả về trong body ({"message": ...} hoặc {"detail": ...}),
  /// ví dụ "Chỉ có thể xóa đơn ở trạng thái Nháp."; null nếu không có.
  static String? serverMessage(Object? e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message'] ?? data['detail'];
        if (msg is String && msg.trim().isNotEmpty) return msg;
      }
    }
    return null;
  }

  static String messageFromError(DioException? e){
    String text = "";
    try {
      GeneralErrorCode error = GeneralErrorCode.fromJson(e?.response?.data);
      text = error.errors?.message ?? '';
    } catch (e){
      text = S.current.common_error_occurred_excl;
    }
    return text;
  }

  static String networkErrorToMessage(dynamic e) {
    try {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return S.current.common_connection_error_excl;
        }
        if (e.response?.data is Map<String, dynamic>) {
          if (e.response?.data['errors'] != null) {
            return e.response?.data['errors'];
          }

          if (e.response?.data['errorType'] == 'error-duplicate-channel-name' ||
              e.response?.data['errorType'] == 'error-duplicate-handle' ||
              e.response?.data['error'] == 'team-name-already-exists') {
            return S.current.common_group_name_exists;
          }

          if (e.response?.data['errorType'] == 'error-invalid-room-name') {
            return S.current.common_group_name_no_diacritics;
          }
        }
        if (e.type == DioExceptionType.unknown && e.error is SocketException) {
          return S.current.common_server_unreachable_retry;
        }
        if (e.response != null && (e.response?.statusCode ?? 0) > 500) {
          return S.current.common_system_error_excl;
        }

        if (e.response != null && e.response?.statusCode == 403) {
          return S.current.common_no_permission_feature;
        }
      }
    } catch (e1) {}
    return S.current.common_error_has_occurred_excl;
  }

  static String errorToMessage(dynamic e,String key) {
    try {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return S.current.common_connection_timeout;
        }
        if (e.response?.data is Map<String, dynamic>) {
          if (e.response?.data['errors'] != null) {
            return e.response?.data['errors'][key];
          }
        }
        if (e.type == DioExceptionType.unknown && e.error is SocketException) {
          return S.current.common_server_connection_lost;
        }

        int? statusCode = e.response?.statusCode;
        if (statusCode != null && statusCode > 500) {
          return S.current.justification_errorHappern;
        }
      }
    } catch (error) {
      return S.current.justification_errorHappern;
    }
    return S.current.justification_errorHappern;
  }
}
