import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/face_search_result_entity.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/core/utils/face_image_utils.dart';
import 'package:pm_app/app/core/utils/perf_log.dart';
import 'package:pm_app/app/data/models/entities/check_in_out_entity.dart';
import 'package:pm_app/app/data/repositories/check_in_repository.dart';
import 'package:pm_app/app/data/repositories/face_id_repository.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../../../data/models/entities/face_search_response_entity.dart';
import '../../../../data/models/enums/load_status.dart';

part 'face_scan_state.dart';

class FaceScanCubit extends Cubit<FaceScanState> {
  FaceIdRepository faceIdRepository;
  CheckInRepository checkInRepository;

  FaceScanCubit({
    required this.faceIdRepository,
    required this.checkInRepository,
  }) : super(FaceScanState());

  void onResetStatus() {
    emit(FaceScanState());
  }

  /// Xác thực khuôn mặt rồi chấm công ngay trong cùng một luồng (một loading duy nhất).
  /// Trước đây màn camera đóng sau bước xác thực, màn chấm công mới upload lại ảnh.
  Future<void> verifyAndCheckIn(
    File file, {
    required int locationId,
    required double latitude,
    required double longitude,
  }) async {
    final currentEmployeeId = GlobalData.instance.userProfile?.employeeId;
    if (currentEmployeeId == null) {
      _emitScanFailure(S.current.common_face_profile_not_ready);
      await deleteQuietly(file.path);
      return;
    }

    emit(state.copyWith(scanStatus: LoadStatus.LOADING));
    final stopwatch = Stopwatch()..start();

    try {
      // 1. Xác thực khuôn mặt
      final FaceSearchResponseEntity res = await faceIdRepository
          .searchEmployeeFace(file);
      perfLog('face search ${stopwatch.elapsedMilliseconds} ms');
      final results = res.searchData?.searchResults ?? [];

      if (results.isEmpty) {
        _emitScanFailure(S.current.common_face_no_match);
        return;
      }

      final matchedFace = results.first;
      if (currentEmployeeId != matchedFace.employeeId) {
        _emitScanFailure(S.current.common_face_wrong_user);
        return;
      }

      // 2. Chấm công
      final checkInRes = await checkInRepository.userCheckInOut(
        file.path,
        locationId,
        latitude,
        longitude,
      );
      perfLog('face search + check in ${stopwatch.elapsedMilliseconds} ms');
      final check = checkInRes.data != null
          ? mapObject(checkInRes.data, CheckInOutEntity.fromJson)
          : null;

      if (check?.employeeId == null) {
        _emitScanFailure(
          _nonEmpty(checkInRes.message) ??
              S.current.common_check_in_failed_retry,
        );
        return;
      }

      emit(
        state.copyWith(
          scanStatus: LoadStatus.SUCCESS,
          faceResult: matchedFace,
          checkInResult: check,
        ),
      );
    } on DioException catch (e, s) {
      logger.d(e);
      logger.d(s);
      _emitScanFailure(_mapScanErrorMessage(e));
    } catch (e, s) {
      logger.d(e);
      logger.d(s);
      _emitScanFailure(S.current.common_face_verify_unavailable);
    } finally {
      await deleteQuietly(file.path);
    }
  }

  String? _nonEmpty(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value.trim();

  void _emitScanFailure(String message) {
    emit(
      state.copyWith(
        scanStatus: LoadStatus.FAILURE,
        faceResult: FaceSearchResultEntity(),
        scanMsg: message,
      ),
    );
  }

  String _mapScanErrorMessage(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return S.current.common_server_unreachable_check_network;
    }

    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode >= 500) {
      return S.current.common_server_busy_retry_later;
    }

    // Lỗi 4xx: ưu tiên thông báo server trả về ({"message": ...} hoặc FastAPI {"detail": ...}).
    // Kèm mã lỗi + API để phân biệt lỗi nhận diện khuôn mặt hay lỗi chấm công khi báo lỗi.
    final api = error.requestOptions.path.contains('search-face')
        ? S.current.common_face_api_recognition
        : S.current.common_face_api_check_in;
    return _serverMessage(error.response?.data) ??
        S.current.common_check_in_unavailable_code(api, statusCode);
  }

  String? _serverMessage(dynamic data) {
    if (data is! Map) return null;
    final message = data['message'];
    if (message is String) return _nonEmpty(message);
    final detail = data['detail'];
    if (detail is String) return _nonEmpty(detail);
    if (detail is Map && detail['message'] is String) {
      return _nonEmpty(detail['message'] as String);
    }
    // FastAPI lỗi validate: {"detail": [{"msg": ...}, ...]}
    if (detail is List && detail.isNotEmpty && detail.first is Map) {
      final msg = (detail.first as Map)['msg'];
      if (msg is String) return _nonEmpty(msg);
    }
    return null;
  }

  void updateFaceValid(bool valid) {
    if (state.isFaceValid != valid) {
      emit(state.copyWith(isFaceValid: valid));
    }
  }

  void onChangeFilePath(String path) {
    emit(state.copyWith(fileImgPath: path));
  }
}
