
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/data/local/shared_prefs_helper.dart';
import 'package:pm_app/app/data/models/entities/check_in_out_entity.dart';
import '../../../../core/logger/logger.dart';
import '../../../../data/models/entities/check_in_info_entity.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/check_in_repository.dart';
import 'package:geocoding/geocoding.dart';

part 'check_in_state.dart';

class CheckInCubit extends Cubit<CheckInState> {
  CheckInRepository checkInRepository;


  CheckInCubit({
    required this.checkInRepository
  }) : super(CheckInState());

  void onResetState(){
    emit(state.copyWith(
        getCheckInfo: LoadStatus.INITIAL,
        checkInStatus: LoadStatus.INITIAL,
        checkOutStatus: LoadStatus.INITIAL,
        updateExplain: LoadStatus.INITIAL,
        // listCheckInfos: [],
        // currentCheckInEntity: CheckInInfoEntity()
    ));
  }

  Future<bool> _isLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // Danh sách điểm chấm công gần nhất đã tải (để tính lại điểm gần nhất khi có vị trí)
  List<CheckInInfoEntity> _allLocations = [];

  /// Mở màn chấm công: xoá trạng thái của lần mở trước (cubit dùng chung cả app) — trước đây
  /// vị trí GPS cũ, cờ muộn/sớm cũ... bị giữ lại và dùng cho lần chấm sau.
  void onOpenPage() {
    _allLocations = [];
    emit(CheckInState());
  }

  // lấy thông tin các điểm check-in / check - out
  void getListCheckInInfo() async{
    emit(state.copyWith(getCheckInfo: LoadStatus.LOADING));
    try {
      final response = await checkInRepository.getListWorkLocations();
      List<CheckInInfoEntity>? list;
      if (response.data != null) {
        list = mapList(response.data, CheckInInfoEntity.fromJson);
      }
      _allLocations = list ?? [];

      // Điểm gần nhất tính theo vị trí đã có; chưa có vị trí (GPS đang lấy song song) thì
      // tính lại ngay khi có vị trí (onChangeAddress → _refreshNearest). Trước đây chờ GPS
      // ngay tại đây, không giới hạn thời gian → trong nhà có thể kẹt ở màn loading.
      final check = state.position == null
          ? null
          : _nearestTo(_allLocations, state.position!);

      if(check != null){
        emit(state.copyWith(getCheckInfo: LoadStatus.SUCCESS,
            listCheckInfos: list,
            currentCheckInEntity: check));
      }else{
        emit(state.copyWith(getCheckInfo: LoadStatus.SUCCESS,
            listCheckInfos: [],
            currentCheckInEntity: CheckInInfoEntity()));
      }

    }catch(e,s){
      logger.d(e);
      logger.d(s);
      emit(state.copyWith(getCheckInfo: LoadStatus.FAILURE,
          listCheckInfos: [],currentCheckInEntity: null ));
    }
  }


  void doCheckInGps(String file) async{
    logger.d("Check-In");
    emit(state.copyWith(checkInStatus: LoadStatus.LOADING));
    try {
      final res = await checkInRepository.
        userCheckInOut(file,
          state.currentCheckInEntity?.id ?? 0,
          state.position?.latitude ?? 0.0,
          state.position?.longitude ?? 0.0
      );
      CheckInOutEntity? check;
      if(res.data != null){
        check = mapObject(res.data, CheckInOutEntity.fromJson);
      }
      if(check?.employeeId != null){
        onCheckInCompleted(check!);
      }else{
        emit(state.copyWith(checkInStatus: LoadStatus.FAILURE,checkInOutResponse: check));
      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(checkInStatus: LoadStatus.FAILURE));
    }
  }

  /// Lượt chấm đã thành công (màn khuôn mặt gọi API chấm công) → cập nhật state để
  /// màn chấm công hiển thị kết quả / hỏi giải trình như trước.
  void onCheckInCompleted(CheckInOutEntity check) {
    // Gán lại mỗi lần (trước đây chỉ bật true, không tắt → sau 1 lần muộn, lần nào cũng hỏi)
    emit(state.copyWith(
      hasLateOrEarly: (check.shiftFlag?.isLate ?? false) ||
          (check.shiftFlag?.isEarly ?? false),
    ));
    emit(state.copyWith(checkInStatus: LoadStatus.SUCCESS, checkInOutResponse: check));
    // lưu hành động check in/out
    SharedPrefsHelper.setCheckInOutAction(check.action ?? "");
    onChangeActionCheck(check.action ?? "");
  }

  void onChangeCurrentCheckInPlace(CheckInInfoEntity check){
    emit(state.copyWith(currentCheckInEntity : check));
  }

  void onExpandMap(){
    bool expand = state.isMapExpanded;
    emit(state.copyWith(isMapExpanded : !expand));
  }

  void doCheckOutGps(String file,) async{
    logger.d("Check-Out");
    emit(state.copyWith(checkOutStatus: LoadStatus.LOADING));
    try {
      final res = await checkInRepository.
      userCheckInOut(file,
          state.currentCheckInEntity?.id ?? 0,
          state.position?.latitude ?? 0.0,
          state.position?.longitude ?? 0.0
      );
      CheckInOutEntity? check;
      if(res.data != null){
        check = mapObject(res.data, CheckInOutEntity.fromJson);
      }
      if(check?.employeeId != null){
        emit(state.copyWith(checkOutStatus: LoadStatus.SUCCESS,checkInOutResponse: check));
        // lưu hành động check in/out
        SharedPrefsHelper.setCheckInOutAction(check?.action ?? "");
        onChangeActionCheck(check?.action ?? "");
      }else{
        emit(state.copyWith(checkOutStatus: LoadStatus.FAILURE,checkInOutResponse: check));
      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(checkOutStatus: LoadStatus.FAILURE));
    }
  }

  void updateExplanation(String reason, int id) async{
    emit(state.copyWith(updateExplain: LoadStatus.LOADING));
    try{
      final param = {
        "biometric_data_id" : id,
        "attendance_explanation" : reason
      };
      await checkInRepository.updateExplanation(param);
      emit(state.copyWith(updateExplain: LoadStatus.SUCCESS));
    }catch(e,s){
      logger.d("err : $e");
      logger.d("ese : $s");
      emit(state.copyWith(updateExplain: LoadStatus.FAILURE));
    }
  }

  void onChangeActionCheck(String check) async {
    emit(state.copyWith(actionCheck: check));
  }


  void onChangeAddress(Position p) async {
    emit(state.copyWith(positionParam: p));

    final acc = p.accuracy;
    final ts = p.timestamp;
    final now = DateTime.now();

    int? ageSec;
    final diff = now.difference(ts).inSeconds;
    ageSec = diff < 0 ? 0 : diff;
  
    logger.d("lat=${p.latitude}, lng=${p.longitude}, acc=${acc}m, age=${ageSec}s");

    if (state.position == null) {
      if (ageSec > 300) {
        logger.d("Ignore very old cached position when no state.position yet");
      } else {
        emit(state.copyWith(position: p, address: state.address ?? ''));
        _refreshNearest();
      }
    }

    const maxAccForCheckin = 100.0;
    final isAccOk = acc > 0 && acc <= maxAccForCheckin;
    final isFreshOk = (ageSec == null) ? true : ageSec <= 60;

    if (!isAccOk || !isFreshOk) {
      logger.d("Skip update for checkin: accOk=$isAccOk freshOk=$isFreshOk");
      return;
    }

    final old = state.position;
    if (old != null) {
      final dist = Geolocator.distanceBetween(
        old.latitude, old.longitude,
        p.latitude, p.longitude,
      );
      final accImprove = old.accuracy - acc; // >0 là tốt hơn

      if (dist < 10 && accImprove < 15) return;
    }

    // accept good position
    emit(state.copyWith(position: p, address: ''));
    _refreshNearest();

    try {
      final placeMarks = await placemarkFromCoordinates(p.latitude, p.longitude);
      if (placeMarks.isNotEmpty) {
        final pm = placeMarks.first;
        final address = [
          pm.street, pm.subAdministrativeArea, pm.administrativeArea,
        ].where((e) => (e ?? '').isNotEmpty).join(", ");
        emit(state.copyWith(address: address));
      }
    } catch (_) {}
  }


  /// Đã có danh sách điểm chấm công + vị trí mới → cập nhật điểm gần nhất (danh sách và GPS
  /// được lấy song song, cái nào về sau thì tính lúc đó).
  void _refreshNearest() {
    final position = state.position;
    if (_allLocations.isEmpty || position == null) return;
    final nearest = _nearestTo(_allLocations, position);
    if (nearest == null || nearest.id == state.currentCheckInEntity?.id) return;
    emit(state.copyWith(listCheckInfos: _allLocations, currentCheckInEntity: nearest));
  }

  CheckInInfoEntity? _nearestTo(List<CheckInInfoEntity> list, Position position) {
    if (list.isEmpty) return null;

    logger.d(
        "current position :: ${position.latitude} , ${position.longitude}");

    CheckInInfoEntity? nearest;
    double minDist = double.infinity;

    for (final item in list) {
      if (item.latitude == null || item.longitude == null) continue;

      final d = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        item.latitude!,
        item.longitude!,
      );

      if (nearest == null || d < minDist) {
        minDist = d;
        nearest = item;
      }
    }

    logger.d('nearest dist = $minDist, place = ${nearest?.name}');
    return nearest;
  }

}
