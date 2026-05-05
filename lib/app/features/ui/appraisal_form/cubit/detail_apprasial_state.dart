part of 'detail_apprasial_cubit.dart';

class CreateAppraisalState extends Equatable {
  final LoadStatus? loadDetail;
  final LoadStatus updateStatus;
  final bool? isEdit;
  final bool? isDetail;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String note;
  final Map<int, double?> hours;
  final Map<int, String?> formTypes;
  final bool isSubmitting;
  final List<EvaluationEntity>? listEvaluations;
  final EvaluationEntity? detailEvaluation;
  final String? errMsg;

  final int currentTabIndex;
  final MasterDataItem? currentTabItem;

  const CreateAppraisalState({
    this.listEvaluations,
    this.detailEvaluation,
    this.loadDetail,
    this.updateStatus = LoadStatus.INITIAL,
    this.isEdit,
    this.isDetail,
    this.fromDate,
    this.toDate,
    this.note = '',
    this.hours = const {},
    this.formTypes = const {},
    this.isSubmitting = false,
    this.errMsg,
    this.currentTabIndex = 0,
    this.currentTabItem,
  });
  bool get isFormValid {
    return fromDate != null && toDate != null;
  }

  CreateAppraisalState copyWith({
    EvaluationEntity? detailEvaluation,
    List<EvaluationEntity>? listEvaluations,
    LoadStatus? loadDetail,
    LoadStatus? updateStatus,
    bool? isEdit,
    bool? isDetail,
    DateTime? fromDate,
    DateTime? toDate,
    String? note,
    Map<int, double?>? hours,
    Map<int, String?>? formTypes,
    bool? isSubmitting,
    String? errMsg,
    bool resetLines = false,
    bool clearFromDate = false,
    bool clearToDate = false,
    int? currentTabIndex,
    MasterDataItem? currentTabItem,
  }) {
    return CreateAppraisalState(
      detailEvaluation: detailEvaluation ?? this.detailEvaluation,
      listEvaluations: listEvaluations ?? this.listEvaluations,
      loadDetail: loadDetail ?? this.loadDetail,
      updateStatus: updateStatus ?? this.updateStatus,
      isEdit: isEdit ?? this.isEdit,
      isDetail: isDetail ?? this.isDetail,
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      note: note ?? this.note,
      hours: resetLines ? {} : (hours ?? this.hours),
      formTypes: resetLines ? {} : (formTypes ?? this.formTypes),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errMsg: errMsg ?? this.errMsg,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      currentTabItem: currentTabItem ?? this.currentTabItem,
    );
  }

  @override
  List<Object?> get props => [
    loadDetail,
    fromDate,
    toDate,
    note,
    hours,
    formTypes,
    isSubmitting,
    updateStatus,
    isEdit,
    isDetail,
    listEvaluations,
    detailEvaluation,
    errMsg,
    currentTabIndex,
    currentTabItem,
  ];
}
