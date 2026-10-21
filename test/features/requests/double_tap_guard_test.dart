import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:pm_app/app/data/models/entities/justification_entity.dart';
import 'package:pm_app/app/data/models/entities/overtime_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/models/param/justification_approve_param.dart';
import 'package:pm_app/app/data/models/param/justification_cancel_param.dart';
import 'package:pm_app/app/data/models/response/common_response.dart';
import 'package:pm_app/app/data/repositories/jutification_repository.dart';
import 'package:pm_app/app/data/repositories/overtime_repository.dart';
import 'package:pm_app/app/features/ui/justification/bloc/justification_detail_cubit.dart';
import 'package:pm_app/app/features/ui/overtime/cubit/overtime_detail_cubit.dart';

class _OtRepo extends Fake implements OvertimeRepository {
  int submitCalls = 0;
  final gate = Completer<void>();

  @override
  Future<OvertimeEntity> getOTDetail(int id) async =>
      OvertimeEntity.fromJson({'id': id, 'employee_id': 66});

  @override
  Future<OvertimeEntity> submitOTP(int id) async {
    submitCalls++;
    await gate.future;
    return OvertimeEntity.fromJson({'id': id});
  }
}

class _JRepo extends Fake implements JutificationRepository {
  int approveCalls = 0;
  int cancelCalls = 0;
  final gate = Completer<void>();

  @override
  Future<JustificationEntity> getDetailAttendance(int id) async =>
      JustificationEntity.fromJson({'id': id, 'employee_id': 66});

  @override
  Future<CommonResponse> approveJustification(JustificationApproveParam body) async {
    approveCalls++;
    await gate.future;
    return CommonResponse();
  }

  @override
  Future<CommonResponse> cancelJustification(int id, JustificationCancelParam body) async {
    cancelCalls++;
    await gate.future;
    return CommonResponse();
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

  test('OT: bấm Gửi duyệt 2 lần liên tiếp chỉ gửi 1 lần, gửi xong không bật loading lần 2',
      () async {
    final cubit = OvertimeDetailCubit();
    await cubit.getDetailOT(5);
    final states = <OvertimeDetailState>[];
    final sub = cubit.stream.listen(states.add);

    final f1 = cubit.submitApproval();
    final f2 = cubit.submitApproval(); // bấm lần 2 khi lần 1 chưa xong
    otRepo.gate.complete();
    await Future.wait([f1, f2]);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(otRepo.submitCalls, 1);
    expect(cubit.state.submitSuccess, isTrue);
    // Không còn lượt loadStatus = LOADING sau khi gửi (nguyên nhân kẹt loading trước đây).
    expect(states.where((s) => s.loadStatus == LoadStatus.LOADING), isEmpty);
  });

  test('Đi muộn/về sớm: bấm Duyệt / Từ chối 2 lần liên tiếp chỉ gọi API 1 lần', () async {
    final cubit = JustificationDetailCubit();
    await cubit.getDetail(7);

    final a1 = cubit.approveJustification(JustificationApproveParam(exceptionIds: [7]));
    final a2 = cubit.approveJustification(JustificationApproveParam(exceptionIds: [7]));
    final c1 = cubit.cancelJustification(7, JustificationCancelParam(note: 'x'));
    final c2 = cubit.cancelJustification(7, JustificationCancelParam(note: 'x'));
    jRepo.gate.complete();
    await Future.wait([a1, a2, c1, c2]);

    expect(jRepo.approveCalls, 1);
    expect(jRepo.cancelCalls, 1);
    expect(cubit.state.approveStatus, LoadStatus.SUCCESS);
    expect(cubit.state.cancelStatus, LoadStatus.SUCCESS);
  });
}
