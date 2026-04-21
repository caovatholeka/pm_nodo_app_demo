import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/face_search_result_entity.dart';
import 'package:pm_app/app/data/repositories/face_id_repository.dart';

import '../../../../data/models/entities/face_search_response_entity.dart';
import '../../../../data/models/enums/load_status.dart';

part 'face_scan_state.dart';

class FaceScanCubit extends Cubit<FaceScanState> {
  FaceIdRepository faceIdRepository;

  FaceScanCubit({required this.faceIdRepository}) : super(FaceScanState());

  void onResetStatus() {
    emit(state.copyWith(scanStatus: LoadStatus.INITIAL, scanMsg: ""));
  }

  void searchFace(File file) async {
    final currentEmployeeId = GlobalData.instance.userProfile?.employeeId;
    if (currentEmployeeId == null) {
      _emitScanFailure(
        "Thông tin người dùng chưa sẵn sàng. Vui lòng đợi tải hồ sơ rồi thử lại.",
      );
      return;
    }

    emit(state.copyWith(scanStatus: LoadStatus.LOADING));

    try {
      final FaceSearchResponseEntity res = await faceIdRepository
          .searchEmployeeFace(file);
      final results = res.searchData?.searchResults ?? [];

      if (results.isEmpty) {
        _emitScanFailure(
          "Không tìm thấy khuôn mặt khớp với tài khoản của bạn.",
        );
        return;
      }

      final matchedFace = results.first;
      if (currentEmployeeId == matchedFace.employeeId) {
        emit(
          state.copyWith(
            scanStatus: LoadStatus.SUCCESS,
            faceResult: matchedFace,
          ),
        );
        return;
      }

      _emitScanFailure("Sai nhận diện người dùng.");
    } on DioException catch (e, s) {
      logger.d(e);
      logger.d(s);
      _emitScanFailure(_mapScanErrorMessage(e));
    } catch (e, s) {
      logger.d(e);
      logger.d(s);
      _emitScanFailure(
        "Không thể xác thực khuôn mặt lúc này. Vui lòng thử lại.",
      );
    }
  }

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
      return "Không thể kết nối tới máy chủ nhận diện khuôn mặt. Vui lòng kiểm tra mạng và thử lại.";
    }

    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode >= 500) {
      return "Máy chủ nhận diện khuôn mặt đang bận. Vui lòng thử lại sau.";
    }

    return "Không thể xác thực khuôn mặt lúc này. Vui lòng thử lại.";
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
