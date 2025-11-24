part of 'attendance_data_cubit.dart';

class AttendanceDataState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus detailStatus;
  final ProfileEntity? profile; 
  final List<DateTime> checkInDays; 
  final bool isMonthView; 
  final String? selectedMonth;
  final String? selectedYear;
  final String? reason;
  final String? selectedDateTime;
  DateTime? selectedDate;
  final List<ExplanationEntity>? listAttendanceHistory;

  final List<AttendanceEntity>? listAttendances;
  final List<WorkEntity>? listSelectedEntries;

  final DateTime? focusedMonth;
  final Map<DateTime, String>? attendanceDateMap;
  final Map<DateTime, List<WorkEntity>>? entriesByDate;

  // detail cham cong
  final List<WorkEntity>? listDetailEntry;

   AttendanceDataState({
    this.loadStatus = LoadStatus.INITIAL,
     this.detailStatus = LoadStatus.INITIAL,
    this.profile,
    this.checkInDays = const [],
    this.isMonthView = true,
    this.selectedMonth,
    this.selectedYear,
     this.selectedDateTime,
     this.selectedDate,
     this.listSelectedEntries,
    this.reason,
    this.listAttendances,
    this.focusedMonth,
    this.attendanceDateMap,
    this.entriesByDate,
     this.listAttendanceHistory,
     this.listDetailEntry
  });

  AttendanceDataState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? detailStatus,
    ProfileEntity? profile,
    List<DateTime>? checkInDays,
    bool? isMonthView,
    String? selectedDateTime,
    DateTime? selectedDate,
    String? selectedMonth,
    String? selectedYear,
    String? reason,
    List<AttendanceEntity>? listAttendances,
    DateTime? focusedMonth,
    Map<DateTime, String>? attendanceDateMap,
    List<WorkEntity>? listSelectedEntries,
    Map<DateTime, List<WorkEntity>>? entriesByDate,
    List<ExplanationEntity>? listAttendanceHistory,
    List<WorkEntity>? listDetailEntry
  }) {
    return AttendanceDataState(
      loadStatus: loadStatus ?? this.loadStatus,
      detailStatus: detailStatus ?? this.detailStatus,
      profile: profile ?? this.profile,
      checkInDays: checkInDays ?? this.checkInDays,
      isMonthView: isMonthView ?? this.isMonthView,
      listSelectedEntries: listSelectedEntries ?? this.listSelectedEntries,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      reason: reason ?? this.reason,
      listAttendances: listAttendances ?? this.listAttendances,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      attendanceDateMap: attendanceDateMap ?? this.attendanceDateMap,
      entriesByDate: entriesByDate ?? this.entriesByDate,
        listAttendanceHistory : listAttendanceHistory ?? this.listAttendanceHistory,
      listDetailEntry: listDetailEntry ?? this.listDetailEntry
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    detailStatus,
    profile,
    checkInDays,
    isMonthView,
    selectedDateTime,
    selectedDate,
    selectedMonth,
    selectedYear,
    reason,
    listAttendances,
    focusedMonth,
    attendanceDateMap,
    entriesByDate,
    listSelectedEntries,
    listAttendanceHistory,
    listDetailEntry
      ];
}
