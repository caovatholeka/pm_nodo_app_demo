part of 'attendance_data_cubit.dart';

class AttendanceDataState extends Equatable {
  final LoadStatus loadStatus;
  final ProfileEntity? profile; 
  final List<DateTime> checkInDays; 
  final bool isMonthView; 
  final String? selectedMonth;
  final String? selectedYear;
  final String? reason;
  final String? selectedDateTime;
  DateTime? selectedDate;

  final List<AttendanceEntity>? listAttendances;
  final List<WorkEntity>? listSelectedEntries;

  final DateTime? focusedMonth;
  final Map<DateTime, String>? attendanceDateMap;
  final Map<DateTime, List<WorkEntity>>? entriesByDate;

   AttendanceDataState({
    this.loadStatus = LoadStatus.INITIAL,
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
    this.entriesByDate
  });

  AttendanceDataState copyWith({
    LoadStatus? loadStatus,
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
  }) {
    return AttendanceDataState(
      loadStatus: loadStatus ?? this.loadStatus,
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
      entriesByDate: entriesByDate ?? this.entriesByDate
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
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
      ];
}
