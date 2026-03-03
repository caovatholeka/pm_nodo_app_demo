part of 'apprasial_form_cubit.dart';

class ApprasialFormState extends Equatable {
  final LoadStatus loadDataStatus;

  List<EvaluationEntity>? listEvaluations; // danh sách đánh giá
  EvaluationEntity? detailEvaluation; // chi tiết đánh giá

  ApprasialFormState({
    this.loadDataStatus = LoadStatus.INITIAL,
    this.listEvaluations,
    this.detailEvaluation
  });

  ApprasialFormState copyWith({
    LoadStatus? loadDataStatus,
    List<EvaluationEntity>? listEvaluations,
    EvaluationEntity? detailEvaluation
  }) {
    return ApprasialFormState(
      loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      listEvaluations: listEvaluations ?? this.listEvaluations,
      detailEvaluation: detailEvaluation ?? this.detailEvaluation
    );
  }

  @override
  List<Object?> get props => [
    loadDataStatus,
    listEvaluations,
    detailEvaluation,
  ];

}