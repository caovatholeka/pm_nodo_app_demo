import 'package:equatable/equatable.dart';
import 'package:pm_app/app/data/models/entities/profile_entity.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';

class AttendanceDataState extends Equatable {
  final LoadStatus loadStatus;
  final ProfileEntity? profile; 
  final List<DateTime> checkInDays; 
  final bool isMonthView; 
  final String selectedMonth;
  final String selectedYear;
  final String? reason; 

  const AttendanceDataState({
    this.loadStatus = LoadStatus.INITIAL,
    this.profile,
    this.checkInDays = const [],
    this.isMonthView = true,
    this.selectedMonth = "Tháng 11",
    this.selectedYear = "2025",
    this.reason,
  });

  AttendanceDataState copyWith({
    LoadStatus? loadStatus,
    ProfileEntity? profile,
    List<DateTime>? checkInDays,
    bool? isMonthView,
    String? selectedMonth,
    String? selectedYear,
    String? reason,
  }) {
    return AttendanceDataState(
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
      checkInDays: checkInDays ?? this.checkInDays,
      isMonthView: isMonthView ?? this.isMonthView,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      reason: reason ?? this.reason,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        profile,
        checkInDays,
        isMonthView,
        selectedMonth,
        selectedYear,
        reason,
      ];
}
