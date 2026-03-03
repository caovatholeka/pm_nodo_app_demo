part of 'appraisal_cubit.dart';

class AppraisalState extends Equatable{
  final LoadStatus loadStatus;
  String? errMsg;
  String? errStatus;

  final List<AppraisalEntity>? listAppraisalEntities;
  final AppraisalEntity? detailAppraisal;

  String? startDateFilter;
  String? endDateFilter;

  AppraisalState({
    required this.loadStatus,
    this.errMsg,
    this.errStatus,
    this.listAppraisalEntities,
    this.detailAppraisal,
    this.startDateFilter,
    this.endDateFilter,
  });

  AppraisalState copyWith({
    bool resetDateTime = false,
    LoadStatus? loadStatus,
    String? errMsg,
    String? errStatus,
    List<AppraisalEntity>? listAppraisalEntities,
    AppraisalEntity? detailAppraisal,
    String? startDateFilter,
    String? endDateFilter,
  }) {
    return AppraisalState(
      loadStatus: loadStatus ?? this.loadStatus,
      errMsg: errMsg ?? this.errMsg,
      errStatus: errStatus ?? this.errStatus,
      listAppraisalEntities: listAppraisalEntities ?? this.listAppraisalEntities,
      detailAppraisal: detailAppraisal ?? this.detailAppraisal,
      startDateFilter: startDateFilter ?? this.startDateFilter,
      endDateFilter: endDateFilter ?? this.endDateFilter,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        errMsg,
        errStatus,
        listAppraisalEntities,
        detailAppraisal,
        startDateFilter,
        endDateFilter
      ];
}