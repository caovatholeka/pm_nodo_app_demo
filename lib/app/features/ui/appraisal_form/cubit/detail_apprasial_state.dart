part of 'detail_apprasial_cubit.dart';

class CreateAppraisalState extends Equatable {
  final LoadStatus? loadDetail;
  final LoadStatus loadJobStatus;
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
  final List<JobTitleEntity>? jobTitles;
  final String? errMsg;
  final bool? isHRReview;
  final bool? isManagerAssess;

  final int currentTabIndex;
  final MasterDataItem? currentTabItem;

  const CreateAppraisalState({
    this.listEvaluations,
    this.detailEvaluation,
    this.loadDetail,
    this.loadJobStatus = LoadStatus.INITIAL,
    this.updateStatus = LoadStatus.INITIAL,
    this.isEdit,
    this.isDetail,
    this.fromDate,
    this.toDate,
    this.note = '',
    this.hours = const {},
    this.formTypes = const {},
    this.isSubmitting = false,
    this.jobTitles,
    this.errMsg,
    this.currentTabIndex = 0,
    this.currentTabItem,
    this.isHRReview,
    this.isManagerAssess,
  });

  bool get isDateRangeValid {
    if (fromDate == null || toDate == null) return false;
    return !fromDate!.isAfter(toDate!);
  }

  bool get isFormValid {
    return fromDate != null && toDate != null && isDateRangeValid;
  }

  CreateAppraisalState copyWith({
    EvaluationEntity? detailEvaluation,
    List<EvaluationEntity>? listEvaluations,
    LoadStatus? loadDetail,
    LoadStatus? loadJobStatus,
    LoadStatus? updateStatus,
    bool? isEdit,
    bool? isDetail,
    DateTime? fromDate,
    DateTime? toDate,
    String? note,
    Map<int, double?>? hours,
    Map<int, String?>? formTypes,
    bool? isSubmitting,
    List<JobTitleEntity>? jobTitles,
    String? errMsg,
    bool resetLines = false,
    bool clearFromDate = false,
    bool clearToDate = false,
    int? currentTabIndex,
    MasterDataItem? currentTabItem,
    bool? isHRReview,
    bool? isManagerAssess,
  }) {
    return CreateAppraisalState(
      detailEvaluation: detailEvaluation ?? this.detailEvaluation,
      listEvaluations: listEvaluations ?? this.listEvaluations,
      loadDetail: loadDetail ?? this.loadDetail,
      loadJobStatus: loadJobStatus ?? this.loadJobStatus,
      updateStatus: updateStatus ?? this.updateStatus,
      isEdit: isEdit ?? this.isEdit,
      isDetail: isDetail ?? this.isDetail,
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      note: note ?? this.note,
      hours: resetLines ? {} : (hours ?? this.hours),
      formTypes: resetLines ? {} : (formTypes ?? this.formTypes),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      jobTitles: jobTitles ?? this.jobTitles,
      errMsg: errMsg ?? this.errMsg,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      currentTabItem: currentTabItem ?? this.currentTabItem,
      isHRReview: isHRReview ?? this.isHRReview,
      isManagerAssess: isManagerAssess ?? this.isManagerAssess,
    );
  }

  @override
  List<Object?> get props => [
    loadDetail,
    loadJobStatus,
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
    jobTitles,
    errMsg,
    currentTabIndex,
    currentTabItem,
    isHRReview,
    isManagerAssess,
  ];
}
