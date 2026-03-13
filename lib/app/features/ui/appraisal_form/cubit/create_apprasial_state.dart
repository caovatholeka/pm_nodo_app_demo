part of 'create_apprasial_cubit.dart';

class CreateAppraisalState extends Equatable {
  final LoadStatus? loadDetail;
  final bool? isCreate;
  final bool? isDetail;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String note;
  final Map<int, double?> hours;
  final Map<int, String?> formTypes;
  final bool isSubmitting;
  final List<EvaluationEntity>? listEvaluations; 
  final EvaluationEntity? detailEvaluation;

  final int currentTabIndex;
  final MasterDataItem? currentTabItem;

  const CreateAppraisalState({
    this.listEvaluations,
    this.detailEvaluation,
    this.loadDetail,
    this.isCreate,
    this.isDetail,
    this.fromDate,
    this.toDate,
    this.note = '',
    this.hours = const {},
    this.formTypes = const {},
    this.isSubmitting = false,
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
    bool? isCreate,
    bool? isDetail,
    DateTime? fromDate,
    DateTime? toDate,
    String? note,
    Map<int, double?>? hours,
    Map<int, String?>? formTypes,
    bool? isSubmitting,
    bool resetLines = false,
    int? currentTabIndex,
    MasterDataItem? currentTabItem,
  }) {
    return CreateAppraisalState(
      detailEvaluation: detailEvaluation ?? this.detailEvaluation,
      listEvaluations: listEvaluations ?? this.listEvaluations,
      loadDetail: loadDetail ?? this.loadDetail,
      isCreate: isCreate ?? this.isCreate,
      isDetail: isDetail ?? this.isDetail,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      note: note ?? this.note,
      hours: resetLines ? {} : (hours ?? this.hours),
      formTypes: resetLines ? {} : (formTypes ?? this.formTypes),
      isSubmitting: isSubmitting ?? this.isSubmitting,
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
    isCreate,
    isDetail,
    listEvaluations,
    detailEvaluation,
    currentTabIndex,
    currentTabItem,
  ];
}
