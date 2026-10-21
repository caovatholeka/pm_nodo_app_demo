import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/jutification_repository.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';
import 'package:pm_app/app/features/ui/justification/bloc/justification_detail_cubit.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/overtime_detail_cubit.dart';

/// Lỗi giống server trả khi xóa đơn không còn ở Nháp (HTTP 400 {"message": ...}).
DioException _serverError(String message) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    response: Response(requestOptions: req, statusCode: 400, data: {'message': message}),
    type: DioExceptionType.badResponse,
  );
}

class _OtRepo extends Fake implements OvertimeRepository {
  int deleteCalls = 0;
  int submitCalls = 0;
  Completer<void> gate = Completer<void>();
  Object? deleteError;

  @override
  Future<OvertimeEntity> getOTDetail(int id) async =>
      OvertimeEntity.fromJson({'id': id, 'employee_id': 66});

  @override
  Future<dynamic> deleteOTRequest(int id) async {
    deleteCalls++;
    await gate.future;
    if (deleteError != null) throw deleteError!;
    return {'id': id};
  }

  @override
  Future<OvertimeEntity> submitOTP(int id) async {
    submitCalls++;
    await gate.future;
    return OvertimeEntity.fromJson({'id': id});
  }
}

class _JRepo extends Fake implements JutificationRepository {
  int deleteCalls = 0;
  Completer<void> gate = Completer<void>();
  Object? deleteError;

  @override
  Future<JustificationEntity> getDetailAttendance(int id) async =>
      JustificationEntity.fromJson({'id': id, 'employee_id': 66});

  @override
  Future<dynamic> deleteJustification(int id) async {
    deleteCalls++;
    await gate.future;
    if (deleteError != null) throw deleteError!;
    return {'id': id};
  }
}

void main() {
  final getIt = GetIt.instance;
  late _OtRepo otRepo;
  late _JRepo jRepo;

  setUp(() async {
    await getIt.reset();
    otRepo = _OtRepo();
    jRepo = _JRepo();
    getIt.registerSingleton<OvertimeRepository>(otRepo);
    getIt.registerSingleton<JutificationRepository>(jRepo);
  });

  group('Đơn OT', () {
    test('bấm Xóa 2 lần liên tiếp chỉ gọi API 1 lần, xong thì SUCCESS', () async {
      final cubit = OvertimeDetailCubit();
      await cubit.getDetailOT(5);

      final f1 = cubit.deleteOT();
      final f2 = cubit.deleteOT(); // bấm lần 2 khi lần 1 chưa xong
      expect(cubit.state.deleteStatus, LoadStatus.LOADING);
      otRepo.gate.complete();
      await Future.wait([f1, f2]);

      expect(otRepo.deleteCalls, 1);
      expect(cubit.state.deleteStatus, LoadStatus.SUCCESS);
    });

    test('xóa lỗi → FAILURE kèm thông báo của server', () async {
      final cubit = OvertimeDetailCubit();
      await cubit.getDetailOT(5);
      otRepo.deleteError = _serverError('Chỉ có thể xóa đơn ở trạng thái Nháp.');
      otRepo.gate.complete();

      await cubit.deleteOT();

      expect(cubit.state.deleteStatus, LoadStatus.FAILURE);
      expect(cubit.state.deleteError, 'Chỉ có thể xóa đơn ở trạng thái Nháp.');
      cubit.resetDeleteStatus();
      expect(cubit.state.deleteStatus, LoadStatus.INITIAL);
    });

    test('bấm Gửi duyệt 2 lần liên tiếp chỉ gửi 1 lần, gửi xong không bật loading lần 2',
        () async {
      final cubit = OvertimeDetailCubit();
      await cubit.getDetailOT(5);
      final states = <OvertimeDetailState>[];
      final sub = cubit.stream.listen(states.add);

      final f1 = cubit.submitApproval();
      final f2 = cubit.submitApproval();
      otRepo.gate.complete();
      await Future.wait([f1, f2]);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(otRepo.submitCalls, 1);
      expect(cubit.state.submitSuccess, isTrue);
      // Không còn lượt loadStatus = LOADING sau khi gửi (nguyên nhân kẹt loading trước đây).
      expect(states.where((s) => s.loadStatus == LoadStatus.LOADING), isEmpty);
    });
  });

  group('Đơn đi muộn/về sớm', () {
    test('bấm Xóa 2 lần liên tiếp chỉ gọi API 1 lần', () async {
      final cubit = JustificationDetailCubit();
      await cubit.getDetail(7);

      final f1 = cubit.deleteJustification();
      final f2 = cubit.deleteJustification();
      jRepo.gate.complete();
      await Future.wait([f1, f2]);

      expect(jRepo.deleteCalls, 1);
      expect(cubit.state.deleteStatus, LoadStatus.SUCCESS);
      // Xóa thành công KHÔNG được bật cờ "gửi duyệt thành công" như code cũ.
      expect(cubit.state.submitSuccess, isFalse);
    });

    test('xóa lỗi → FAILURE kèm thông báo của server', () async {
      final cubit = JustificationDetailCubit();
      await cubit.getDetail(7);
      jRepo.deleteError = _serverError('Chỉ có thể xóa đơn ở trạng thái Nháp.');
      jRepo.gate.complete();

      await cubit.deleteJustification();

      expect(cubit.state.deleteStatus, LoadStatus.FAILURE);
      expect(cubit.state.deleteError, 'Chỉ có thể xóa đơn ở trạng thái Nháp.');
    });
  });
}
