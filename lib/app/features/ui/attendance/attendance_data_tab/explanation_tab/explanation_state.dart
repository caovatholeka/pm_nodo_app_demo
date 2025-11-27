part of 'explanation_cubit.dart';

class ExplanationState extends Equatable {
  final bool isLoading;
  final ProfileEntity? profile;
  final String? errorMsg;
  final String? reason;
  final String? startTime;
  final String? endTime;
  final bool submitSuccess;
  final LoadStatus loadStatus;
  final LoadStatus sendInvalidStatus;

  // danh sach giai trinh
  final List<WorkEntryEntity>? listWorkEntries;
  final int? selectedMonth;
  final int? selectedYear;


  const ExplanationState({
    this.loadStatus = LoadStatus.INITIAL,
    this.sendInvalidStatus = LoadStatus.INITIAL,
    this.isLoading = false,
    this.profile,
    this.errorMsg,
    this.reason,
    this.startTime,
    this.endTime,
    this.submitSuccess = false,
    this.selectedYear,
    this.selectedMonth,
    this.listWorkEntries
  });

  ExplanationState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? sendInvalidStatus,
    bool? isLoading,
    ProfileEntity? profile,
    String? errorMsg,
    String? reason,
    String? startTime,
    String? endTime,
    bool? submitSuccess,
    int? selectedMonth,
    int? selectedYear,
    List<WorkEntryEntity>? listWorkEntries
  }) {
    return ExplanationState(
      loadStatus: loadStatus ?? this.loadStatus,
      sendInvalidStatus: sendInvalidStatus ?? this.sendInvalidStatus,
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
        errorMsg: errorMsg ?? this.errorMsg,
      reason: reason ?? this.reason,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      listWorkEntries: listWorkEntries ?? this.listWorkEntries
    );
  }

  @override
  List<Object?> get props => [loadStatus,
    sendInvalidStatus,
    isLoading, profile,
    errorMsg, reason,
    startTime,endTime,
    submitSuccess,
    selectedYear,
    selectedMonth,
    listWorkEntries
  ];
}
