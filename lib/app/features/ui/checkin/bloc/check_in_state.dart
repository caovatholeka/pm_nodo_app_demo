part of 'check_in_cubit.dart';

class CheckInState extends Equatable {

  final LoadStatus checkInStatus;
  final LoadStatus checkOutStatus;
  final LoadStatus getCheckInfo;

  final String? address;
  final Position? position;
  final Position? positionParam;

  // danh sách điểm chấm công và điểm hiện tại
  final List<CheckInInfoEntity>? listCheckInfos;
  final CheckInInfoEntity? currentCheckInEntity;

  final String? errMsg;
  final String? errStatus;

  const CheckInState({
    this.checkInStatus = LoadStatus.INITIAL,
    this.checkOutStatus = LoadStatus.INITIAL,
    this.getCheckInfo = LoadStatus.INITIAL,
    this.address,
    this.position,
    this.positionParam,
    this.listCheckInfos,
    this.currentCheckInEntity,
    this.errMsg,
    this.errStatus
  });

  CheckInState copyWith({
    LoadStatus? checkInStatus,
    LoadStatus? checkOutStatus,
    LoadStatus? getCheckInfo,
    String? address,
    Position? position,
    Position? positionParam,
    String? errMsg,
    String? errStatus,
    List<CheckInInfoEntity>? listCheckInfos,
    CheckInInfoEntity? currentCheckInEntity
  }){
    return CheckInState(
        checkInStatus: checkInStatus ?? this.checkInStatus,
        checkOutStatus: checkOutStatus ?? this.checkOutStatus,
        getCheckInfo: getCheckInfo ?? this.getCheckInfo,
        address: address ?? this.address,
        position: position ?? this.position,
        positionParam: positionParam ?? this.positionParam,
        errMsg: errMsg ?? this.errMsg,
        errStatus: errStatus ?? this.errStatus,
      listCheckInfos: listCheckInfos ?? this.listCheckInfos,
        currentCheckInEntity: currentCheckInEntity ?? this.currentCheckInEntity
    );
  }

  @override
  List<Object?> get props => [
    checkInStatus,
    checkOutStatus,
    getCheckInfo,
    address,
    position,
    positionParam,
    errMsg,
    errStatus,
    listCheckInfos,
    currentCheckInEntity
  ];
}