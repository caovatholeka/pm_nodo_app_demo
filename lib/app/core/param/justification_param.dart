class JustificationParam {
  final String? code;
  final String? date;
  final String? type;
  final String? creator;
  final String? status;
  final int? statusId;
  final String? employeeName;
  final String? departmentName;
  final String? fromDate;
  final String? toDate;
  final String? reason;
  final String? approver;
  final String? follower;
  final String? method;

  const JustificationParam({
    this.code,
    this.date,
    this.approver,
    this.creator,
    this.departmentName,
    this.employeeName,
    this.follower,
    this.fromDate,
    this.method,
    this.reason,
    this.status,
    this.statusId,
    this.toDate,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      if (code != null && code!.isNotEmpty) 'code': code,
      if (date != null && date!.isNotEmpty) 'date': date,
      if (type != null && type!.isNotEmpty) 'type': type,
      if (creator != null && creator!.isNotEmpty) 'creator': creator,
      if (status != null && status!.isNotEmpty) 'status': status,
      if (statusId != null) 'status_id': statusId,
      if (employeeName != null && employeeName!.isNotEmpty)
        'employee_name': employeeName,
      if (departmentName != null && departmentName!.isNotEmpty)
        'department_name': departmentName,
      if (fromDate != null && fromDate!.isNotEmpty)
        'from_date': fromDate,
      if (toDate != null && toDate!.isNotEmpty)
        'to_date': toDate,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
      if (approver != null && approver!.isNotEmpty) 'approver': approver,
      if (follower != null && follower!.isNotEmpty) 'follower': follower,
      if (method != null && method!.isNotEmpty) 'method': method,
    };
  }

  JustificationParam copyWith({
    String? code,
    String? date,
    String? type,
    String? creator,
    String? status,
    int? statusId,
    String? employeeName,
    String? departmentName,
    String? fromDate,
    String? toDate,
    String? reason,
    String? approver,
    String? follower,
    String? method,
    bool clear = false,
  }) {
    if (clear) {
      return const JustificationParam();
    }

    return JustificationParam(
      code: code ?? this.code,
      date: date ?? this.date,
      type: type ?? this.type,
      creator: creator ?? this.creator,
      status: status ?? this.status,
      statusId: statusId ?? this.statusId,
      employeeName: employeeName ?? this.employeeName,
      departmentName: departmentName ?? this.departmentName,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      approver: approver ?? this.approver,
      follower: follower ?? this.follower,
      method: method ?? this.method,
    );
  }

  bool get isEmpty =>
      (code == null || code!.trim().isEmpty) &&
      (date == null || date!.trim().isEmpty) &&
      (type == null || type!.trim().isEmpty) &&
      (creator == null || creator!.trim().isEmpty) &&
      (status == null || status!.trim().isEmpty) &&
      statusId == null &&
      (employeeName == null || employeeName!.trim().isEmpty) &&
      (departmentName == null || departmentName!.trim().isEmpty) &&
      (fromDate == null || fromDate!.trim().isEmpty) &&
      (toDate == null || toDate!.trim().isEmpty) &&
      (reason == null || reason!.trim().isEmpty) &&
      (approver == null || approver!.trim().isEmpty) &&
      (follower == null || follower!.trim().isEmpty) &&
      (method == null || method!.trim().isEmpty);
}
