part of 'explanation_cubit.dart';

class ExplanationState extends Equatable {
  final bool isLoading;
  final ProfileEntity? profile;
  final String? error;
  final String? reason;
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
    this.error,
    this.reason,
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
    String? error,
    String? reason,
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
      error: error,
      reason: reason ?? this.reason,
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
    error, reason,
    submitSuccess,
    selectedYear,
    selectedMonth,
    listWorkEntries
  ];
}
