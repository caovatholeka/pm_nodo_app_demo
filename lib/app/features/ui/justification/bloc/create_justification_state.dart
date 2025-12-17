import 'package:equatable/equatable.dart';

class DropdownItem {
  final String id;
  final String name;

  const DropdownItem({
    required this.id,
    required this.name,
  });
}

class CreateJustificationState extends Equatable {
  final List<DropdownItem> reasons;
  final List<DropdownItem> methods;

  final DropdownItem? selectedReason;
  final DropdownItem? selectedMethod;

  final String date;
  final String hours;
  final String note;

  final bool isSubmitting;

  const CreateJustificationState({
    this.reasons = const [],
    this.methods = const [],
    this.selectedReason,
    this.selectedMethod,
    this.date = '',
    this.hours = '',
    this.note = '',
    this.isSubmitting = false,
  });

  bool get isFormValid =>
      selectedReason != null &&
      selectedMethod != null &&
      date.isNotEmpty &&
      hours.isNotEmpty &&
      note.isNotEmpty;

  CreateJustificationState copyWith({
    List<DropdownItem>? reasons,
    List<DropdownItem>? methods,
    DropdownItem? selectedReason,
    DropdownItem? selectedMethod,
    String? date,
    String? hours,
    String? note,
    bool? isSubmitting,
    bool clear = false,
  }) {
    if (clear) {
      return const CreateJustificationState();
    }

    return CreateJustificationState(
      reasons: reasons ?? this.reasons,
      methods: methods ?? this.methods,
      selectedReason: selectedReason ?? this.selectedReason,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      date: date ?? this.date,
      hours: hours ?? this.hours,
      note: note ?? this.note,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        reasons,
        methods,
        selectedReason,
        selectedMethod,
        date,
        hours,
        note,
        isSubmitting,
      ];
}
