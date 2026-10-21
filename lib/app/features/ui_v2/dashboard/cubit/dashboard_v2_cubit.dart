import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/dashboard_v2_models.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'package:pm_app/app/data/repositories/dashboard_repository.dart';

/// Dashboard v2 — đồng bộ với Dashboard web. Mỗi thẻ tải riêng (song song), lỗi thẻ nào
/// chỉ thẻ đó báo lỗi. Một bộ chọn tháng chung cho cả màn (như bộ lọc "Tháng" của web).
class DashboardV2Cubit extends Cubit<DashboardV2State> {
  final DashboardRepository repository;

  DashboardV2Cubit(this.repository, {DateTime? now})
      : super(DashboardV2State.initial(now ?? DateTime.now()));

  Future<void> loadAll() async {
    await Future.wait([
      _load<DashboardCountCard>(
        (s, status, data) => s.copyWith(requestsStatus: status, requests: data),
        () async => DashboardCountCard.fromJson(
            await repository.getDashboardRequests(state.month, state.year)),
      ),
      _load<DashboardCountCard>(
        (s, status, data) => s.copyWith(pendingStatus: status, pending: data),
        () async => DashboardCountCard.fromJson(
            await repository.getDashboardPending(state.month, state.year)),
      ),
      _load<DashboardBehaviour>(
        (s, status, data) => s.copyWith(behaviourStatus: status, behaviour: data),
        () async => DashboardBehaviour.fromJson(
            await repository.getDashboardBehaviour(state.month, state.year)),
      ),
      _load<DashboardCountCard>(
        (s, status, data) => s.copyWith(headcountStatus: status, headcount: data),
        () async =>
            DashboardCountCard.fromJson(await repository.getDashboardHeadcount()),
      ),
      _load<DashboardBirthdays>(
        (s, status, data) => s.copyWith(birthdaysStatus: status, birthdays: data),
        () async => DashboardBirthdays.fromJson(
            await repository.getDashboardBirthdays(state.month, state.year)),
      ),
      _load<DashboardAlerts>(
        (s, status, data) => s.copyWith(alertsStatus: status, alerts: data),
        () async => DashboardAlerts.fromJson(
            await repository.getDashboardAlerts(state.month, state.year)),
      ),
    ]);
  }

  /// Đổi tháng (năm hiện tại, như web) rồi tải lại toàn bộ.
  Future<void> changeMonth(int month) async {
    if (month == state.month) return;
    emit(state.copyWith(month: month));
    await loadAll();
  }

  Future<void> _load<T>(
    DashboardV2State Function(DashboardV2State s, LoadStatus status, T? data) apply,
    Future<T> Function() fetch,
  ) async {
    final month = state.month;
    emit(apply(state, LoadStatus.LOADING, null));
    try {
      final data = await fetch();
      if (isClosed || month != state.month) return; // đã đổi tháng khác trong lúc tải
      emit(apply(state, LoadStatus.SUCCESS, data));
    } catch (e, s) {
      logger.e("Dashboard v2 load error: $e, where: $s");
      if (isClosed || month != state.month) return;
      emit(apply(state, LoadStatus.FAILURE, null));
    }
  }
}

class DashboardV2State extends Equatable {
  final int month;
  final int year;

  final LoadStatus requestsStatus;
  final DashboardCountCard? requests;
  final LoadStatus pendingStatus;
  final DashboardCountCard? pending;
  final LoadStatus behaviourStatus;
  final DashboardBehaviour? behaviour;
  final LoadStatus headcountStatus;
  final DashboardCountCard? headcount;
  final LoadStatus birthdaysStatus;
  final DashboardBirthdays? birthdays;
  final LoadStatus alertsStatus;
  final DashboardAlerts? alerts;

  const DashboardV2State({
    required this.month,
    required this.year,
    this.requestsStatus = LoadStatus.INITIAL,
    this.requests,
    this.pendingStatus = LoadStatus.INITIAL,
    this.pending,
    this.behaviourStatus = LoadStatus.INITIAL,
    this.behaviour,
    this.headcountStatus = LoadStatus.INITIAL,
    this.headcount,
    this.birthdaysStatus = LoadStatus.INITIAL,
    this.birthdays,
    this.alertsStatus = LoadStatus.INITIAL,
    this.alerts,
  });

  factory DashboardV2State.initial(DateTime now) =>
      DashboardV2State(month: now.month, year: now.year);

  /// Dữ liệu null = giữ nguyên dữ liệu cũ (đang tải lại thì vẫn hiện số tháng trước).
  DashboardV2State copyWith({
    int? month,
    LoadStatus? requestsStatus,
    DashboardCountCard? requests,
    LoadStatus? pendingStatus,
    DashboardCountCard? pending,
    LoadStatus? behaviourStatus,
    DashboardBehaviour? behaviour,
    LoadStatus? headcountStatus,
    DashboardCountCard? headcount,
    LoadStatus? birthdaysStatus,
    DashboardBirthdays? birthdays,
    LoadStatus? alertsStatus,
    DashboardAlerts? alerts,
  }) {
    return DashboardV2State(
      month: month ?? this.month,
      year: year,
      requestsStatus: requestsStatus ?? this.requestsStatus,
      requests: requests ?? this.requests,
      pendingStatus: pendingStatus ?? this.pendingStatus,
      pending: pending ?? this.pending,
      behaviourStatus: behaviourStatus ?? this.behaviourStatus,
      behaviour: behaviour ?? this.behaviour,
      headcountStatus: headcountStatus ?? this.headcountStatus,
      headcount: headcount ?? this.headcount,
      birthdaysStatus: birthdaysStatus ?? this.birthdaysStatus,
      birthdays: birthdays ?? this.birthdays,
      alertsStatus: alertsStatus ?? this.alertsStatus,
      alerts: alerts ?? this.alerts,
    );
  }

  @override
  List<Object?> get props => [
        month,
        year,
        requestsStatus,
        requests,
        pendingStatus,
        pending,
        behaviourStatus,
        behaviour,
        headcountStatus,
        headcount,
        birthdaysStatus,
        birthdays,
        alertsStatus,
        alerts,
      ];
}
