part of 'check_in_cubit.dart';

class CheckInState extends Equatable {

  final LoadStatus checkInStatus;
  final LoadStatus checkOutStatus;
  final LoadStatus getCheckInfo;
  final LoadStatus updateExplain;
  final LoadStatus? locationStatus;

  final String? address;
  final Position? position;
  final Position? positionParam;

  // danh sách điểm chấm công và điểm hiện tại
  final List<CheckInInfoEntity>? listCheckInfos;
  final CheckInInfoEntity? currentCheckInEntity;

  final String? errMsg;
  final String? errStatus;

  final CheckInOutEntity? checkInOutResponse;
  final String? actionCheck;

  final bool hasLateOrEarly;

  final bool isMapExpanded;

  const CheckInState({
    this.checkInStatus = LoadStatus.INITIAL,
    this.checkOutStatus = LoadStatus.INITIAL,
    this.getCheckInfo = LoadStatus.INITIAL,
    this.updateExplain = LoadStatus.INITIAL,
    this.locationStatus = LoadStatus.INITIAL,
    this.address,
    this.position,
    this.positionParam,
    this.listCheckInfos,
    this.currentCheckInEntity,
    this.errMsg,
    this.errStatus,
    this.checkInOutResponse,
    this.actionCheck,
    this.hasLateOrEarly = false,
    this.isMapExpanded = false
  });

  CheckInState copyWith({
    LoadStatus? checkInStatus,
    LoadStatus? checkOutStatus,
    LoadStatus? getCheckInfo,
    LoadStatus? updateExplain,
    LoadStatus? locationStatus,
    String? address,
    Position? position,
    Position? positionParam,
    String? errMsg,
    String? errStatus,
    List<CheckInInfoEntity>? listCheckInfos,
    CheckInInfoEntity? currentCheckInEntity,
    CheckInOutEntity? checkInOutResponse,
    String? actionCheck,
    bool? hasLateOrEarly,
    bool? isMapExpanded
  }){
    return CheckInState(
        checkInStatus: checkInStatus ?? this.checkInStatus,
        checkOutStatus: checkOutStatus ?? this.checkOutStatus,
        getCheckInfo: getCheckInfo ?? this.getCheckInfo,
        updateExplain: updateExplain ?? this.updateExplain,
        locationStatus: locationStatus ?? this.locationStatus,
        address: address ?? this.address,
        position: position ?? this.position,
        positionParam: positionParam ?? this.positionParam,
        errMsg: errMsg ?? this.errMsg,
        errStatus: errStatus ?? this.errStatus,
      listCheckInfos: listCheckInfos ?? this.listCheckInfos,
        currentCheckInEntity: currentCheckInEntity ?? this.currentCheckInEntity,
      checkInOutResponse: checkInOutResponse ?? this.checkInOutResponse,
      actionCheck: actionCheck ?? this.actionCheck,
      hasLateOrEarly: hasLateOrEarly ?? this.hasLateOrEarly,
      isMapExpanded: isMapExpanded ?? this.isMapExpanded
    );
  }

  @override
  List<Object?> get props => [
    checkInStatus,
    checkOutStatus,
    getCheckInfo,
    updateExplain,
    locationStatus,
    address,
    position,
    positionParam,
    errMsg,
    errStatus,
    listCheckInfos,
    currentCheckInEntity,
    checkInOutResponse,
    actionCheck,
    hasLateOrEarly,
    isMapExpanded
  ];
}
