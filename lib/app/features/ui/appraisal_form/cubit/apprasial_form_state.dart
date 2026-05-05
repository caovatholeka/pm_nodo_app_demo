part of 'apprasial_form_cubit.dart';

class ApprasialFormState extends Equatable {
  final LoadStatus loadDataStatus;
  final List<EvaluationEntity>? listEvaluations;
  final EvaluationEntity? detailEvaluation;
  final String? startDateFilter;
  final String? endDateFilter;

  const ApprasialFormState({
    this.loadDataStatus = LoadStatus.INITIAL,
    this.listEvaluations,
    this.detailEvaluation,
    this.endDateFilter,
    this.startDateFilter,
  });

  ApprasialFormState copyWith({
    LoadStatus? loadDataStatus,
    List<EvaluationEntity>? listEvaluations,
    EvaluationEntity? detailEvaluation,
    String? startDateFilter,
    String? endDateFilter,
  }) {
    return ApprasialFormState(
      loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      listEvaluations: listEvaluations ?? this.listEvaluations,
      detailEvaluation: detailEvaluation ?? this.detailEvaluation,
      startDateFilter: startDateFilter ?? this.startDateFilter,
      endDateFilter: endDateFilter ?? this.endDateFilter,
    );
  }

  @override
  List<Object?> get props => [
    loadDataStatus,
    listEvaluations,
    detailEvaluation,
    startDateFilter,
    endDateFilter,
  ];
}
