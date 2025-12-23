part of 'work_trip_cubit.dart';

class WorkTripState extends Equatable {
  final LoadStatus loadDataStatus;
  final LoadStatus detailStatus;
  final LoadStatus createStatus;
  final LoadStatus submitStatus;
  final LoadStatus deleteStatus;
  final LoadStatus updateStatus;

  final String? errMsg;

  final List<WorkTripEntity>? listWorkTrips;
  final WorkTripEntity? detailWorkTrip;

  final List<UserEntity>? listUsers;
  final List<UserEntity>? currentUsers;
  final String? strUsers;

  final String? note;
  final String? address;

  DateTime? fromDateTime;
  DateTime? toDateTime;
  String? fromDate; // từ ngày
  String? toDate;  // đến ngày

  // cần phòng khách sạn
  final bool? needRoom;
  // vé máy bay
  final bool? needTicket;

  // qua đêm
  final bool? isOvernight;

  // số ngày công tác
  List<ScheduleEntity>? listScheduleDays;

  // upload file
  /// dùng để lưu danh sách file hiện tại
  List<AttachFile> files;

  /// thêm file
  LoadStatus? addFileStatus;

  /// sửa file
  LoadStatus editFileStatus;

  /// xóa file
  LoadStatus deleteFileStatus;

  WorkTripState({
    this.loadDataStatus = LoadStatus.INITIAL,
    this.detailStatus = LoadStatus.INITIAL,
    this.createStatus = LoadStatus.INITIAL,
    this.submitStatus = LoadStatus.INITIAL,
    this.updateStatus = LoadStatus.INITIAL,
    this.deleteStatus = LoadStatus.INITIAL,

    this.errMsg,
    this.listWorkTrips,
    this.detailWorkTrip,
    this.listUsers,
    this.currentUsers,
    this.strUsers,
    this.address,
    this.note,
    this.files = const [],
    this.addFileStatus,
    this.editFileStatus = LoadStatus.INITIAL,
    this.deleteFileStatus = LoadStatus.INITIAL,
    this.fromDateTime,
    this.toDateTime,
    this.fromDate,
    this.toDate,
    this.listScheduleDays,
    this.needRoom,
    this.needTicket,
    this.isOvernight
  });

  WorkTripState copyWith({
    bool resetDateTime = false,
    LoadStatus? loadDataStatus,
    LoadStatus? detailStatus,
    LoadStatus? createStatus,
    LoadStatus? submitStatus,
    LoadStatus? updateStatus,
    LoadStatus? deleteStatus,
    String? errMsg,
    List<WorkTripEntity>? listWorkTrips,
    WorkTripEntity? detailWorkTrip,
    List<UserEntity>? listUsers,
    List<UserEntity>? currentUsers,
    String? strUsers,
    String? note,
    String? address,
    List<AttachFile>? files,
    LoadStatus? addFileStatus,
    LoadStatus? editFileStatus,
    LoadStatus? deleteFileStatus,
    DateTime? fromDateTime,
    DateTime? toDateTime,
    String? fromDate,
    String? toDate,
    List<ScheduleEntity>? listScheduleDays,
    bool? needRoom,
    bool? needTicket,
    bool? isOvernight,
  }) {
    return WorkTripState(
        loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      detailStatus: detailStatus ?? this.detailStatus,
      createStatus: createStatus ?? this.createStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      updateStatus: updateStatus ?? this.updateStatus,
      errMsg: errMsg ?? this.errMsg,
      listWorkTrips: listWorkTrips ?? this.listWorkTrips,
      detailWorkTrip: detailWorkTrip ?? this.detailWorkTrip,
      listUsers: listUsers ?? this.listUsers,
      currentUsers: currentUsers ?? this.currentUsers,
      strUsers: strUsers ?? this.strUsers,
      address: address ?? this.address,
      note: note ?? this.note,
      files: files ?? this.files,
      addFileStatus: addFileStatus ?? this.addFileStatus,
      editFileStatus: editFileStatus ?? this.editFileStatus,
      deleteFileStatus: deleteFileStatus ?? this.deleteFileStatus,
      fromDateTime: resetDateTime ? null : (fromDateTime ?? this.fromDateTime),
      toDateTime: resetDateTime ? null : (toDateTime ?? this.toDateTime),
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      listScheduleDays: listScheduleDays ?? this.listScheduleDays,
      needRoom: needRoom ?? this.needRoom,
      isOvernight: isOvernight ?? this.isOvernight,
      needTicket: needTicket ?? this.needTicket
    );
  }

  @override
  List<Object?> get props => [
    loadDataStatus,
    detailStatus,
    createStatus,
    updateStatus,
    submitStatus,
    deleteStatus,
    errMsg,
    listWorkTrips,
    detailWorkTrip,
    listUsers,
    address,
    note,
    currentUsers,
    strUsers,
    files,
    fromDateTime,
    toDateTime,
    fromDate,
    toDate,
    addFileStatus,
    editFileStatus,
    deleteFileStatus,
    listScheduleDays,
  ];
}