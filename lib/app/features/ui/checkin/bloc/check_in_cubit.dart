
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

  // lấy thông tin các điểm check-in / check - out
  void getListCheckInInfo() async{
    emit(state.copyWith(getCheckInfo: LoadStatus.LOADING));
    try {
      final response = await checkInRepository.getListWorkLocations();
      List<CheckInInfoEntity>? list;
      if (response.data != null) {
        list = mapList(response.data, CheckInInfoEntity.fromJson);
      }

      // hiển thị điểm checkin gần nhất
      CheckInInfoEntity? check =  await findNearestCheckIn(list ?? []);

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
        if((check?.shiftFlag?.isLate ?? false) ||
            (check?.shiftFlag?.isEarly ?? false)){
          emit(state.copyWith(hasLateOrEarly: true));
        }

        emit(state.copyWith(checkInStatus: LoadStatus.SUCCESS,checkInOutResponse: check));
        // lưu hành động check in/out
        SharedPrefsHelper.setCheckInOutAction(check?.action ?? "");
        onChangeActionCheck(check?.action ?? "");
      }else{
        emit(state.copyWith(checkInStatus: LoadStatus.FAILURE,checkInOutResponse: check));
      }
    }catch(e){
      logger.d(e);
      emit(state.copyWith(checkInStatus: LoadStatus.FAILURE));
    }
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

  /*
  void onChangeAddress(Position position) async {
    emit(state.copyWith(positionParam: position));

    // final acc = position.accuracy;
    // logger.d("New position: ${position.latitude}, ${position.longitude}, acc=$acc m");

    // if (acc > 80) {
    //   logger.d(" Bỏ qua position vì accuracy quá kém: $acc m");
    //   return;
    // }

    if (position.latitude == state.position?.latitude &&
        position.longitude == state.position?.longitude &&
        (state.address ?? '').isNotEmpty) {
      return;
    }

    final oldPos = state.position;
    if (oldPos != null) {
      final metersDistanceBetween = Geolocator.distanceBetween(
        oldPos.latitude,
        oldPos.longitude,
        position.latitude,
        position.longitude,
      );
      logger.d("Check distance between: $metersDistanceBetween m");

      if (metersDistanceBetween < 10) {
        return;
      }
    }

    emit(state.copyWith(position: position, address: ''));

    logger.d(
        "lat=${position.latitude}, lng=${position.longitude}, acc=${position.accuracy}m, "
            "speed=${position.speed}, heading=${position.heading}, ts=${position.timestamp}"
    );

    try {
      final placeMarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placeMarks.isNotEmpty) {
        final placeMark = placeMarks.first;
        logger.d(placeMark.toString());

        String address = [
          placeMark.street,
          placeMark.subAdministrativeArea,
          placeMark.administrativeArea,
        ]
            .where((e) => e != null && e.isNotEmpty)
            .join(", ");

        emit(state.copyWith(address: address));
        logger.d("New address: $address");
      }
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
    }
  }
   */

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


  Future<CheckInInfoEntity?> findNearestCheckIn(
      List<CheckInInfoEntity> list,
      ) async {
    if (list.isEmpty) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        logger.w('Location permission not granted');
        return null;
      }
    }

    final position = state.position ??
        await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

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