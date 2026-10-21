import 'dart:io';
import 'package:dio/dio.dart';
import '../../data/models/entities/general_error_entity.dart';

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
      text = "Có lỗi xảy ra!";
    }
    return text;
  }

  static String networkErrorToMessage(dynamic e) {
    try {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return "Đã xảy ra lỗi kết nối!";
        }
        if (e.response?.data is Map<String, dynamic>) {
          if (e.response?.data['errors'] != null) {
            return e.response?.data['errors'];
          }

          if (e.response?.data['errorType'] == 'error-duplicate-channel-name' ||
              e.response?.data['errorType'] == 'error-duplicate-handle' ||
              e.response?.data['error'] == 'team-name-already-exists') {
            return 'Tên nhóm đã tồn tại, vui lòng đặt tên khác!';
          }

          if (e.response?.data['errorType'] == 'error-invalid-room-name') {
            return 'Tên nhóm không được đặt có dấu!';
          }
        }
        if (e.type == DioExceptionType.unknown && e.error is SocketException) {
          return 'Không thể kết nối tới máy chủ xin vui lòng thử lại!';
        }
        if (e.response != null && (e.response?.statusCode ?? 0) > 500) {
          return "Đã xảy ra lỗi hệ thống!";
        }

        if (e.response != null && e.response?.statusCode == 403) {
          return 'Bạn không có quyền truy cập chức năng này!';
        }
      }
    } catch (e1) {}
    return "Đã có lỗi xảy ra!";
  }

  static String errorToMessage(dynamic e,String key) {
    try {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return "Kết nối quá hạn";
        }
        if (e.response?.data is Map<String, dynamic>) {
          if (e.response?.data['errors'] != null) {
            return e.response?.data['errors'][key];
          }
        }
        if (e.type == DioExceptionType.unknown && e.error is SocketException) {
          return "Mất kết nối với máy chủ";
        }

        int? statusCode = e.response?.statusCode;
        if (statusCode != null && statusCode > 500) {
          return "Đã xảy ra lỗi";
        }
      }
    } catch (error) {
      return "Đã xảy ra lỗi";
    }
    return "Đã xảy ra lỗi";
  }
}
