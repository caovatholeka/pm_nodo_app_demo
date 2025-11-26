
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

  void onChangeAddress(Position position) async {
    emit(state.copyWith(positionParam: position));
    if (position.latitude == state.position?.latitude &&
        position.longitude == state.position?.longitude &&
        (state.address ?? '').isNotEmpty) {
      return;
    }
    final metersDistanceBetween = Geolocator.distanceBetween(
        state.position?.latitude ?? 0,
        state.position?.longitude ?? 0,
        position.latitude,
        position.longitude);
    logger.d("Check distance between: $metersDistanceBetween m");
    if (metersDistanceBetween < 10) {
      return;
    }
    emit(state.copyWith(position: position, address: ''));
    List<Placemark> placeMarks = [];
    try {
      placeMarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
    }
    if (placeMarks.isNotEmpty) {
      final placeMark = placeMarks.first;
      logger.d(placeMark.toString());
      String address = [
        placeMark.street,
        placeMark.subAdministrativeArea,
        placeMark.administrativeArea,
      ].where((element) => element != null && element.isNotEmpty).join(", ");
      emit(state.copyWith(address: address));
      logger.d(address);
    }
  }

  Future<CheckInInfoEntity?> findNearestCheckIn(List<CheckInInfoEntity> list) async {
    if (list.isEmpty) return null;

    CheckInInfoEntity nearest = list.first;
    double minDist = Geolocator.distanceBetween(
      state.position?.latitude ?? 0.0, state.position?.longitude ?? 0.0,
      nearest.latitude ?? 0.0, nearest.longitude ?? 0.0,
    );

    for (int i = 1; i < list.length; i++) {
      final d = Geolocator.distanceBetween(
        state.position?.latitude ?? 0.0, state.position?.longitude ?? 0.0,
        list[i].latitude ?? 0.0, list[i].longitude ?? 0.0,
      );
      if (d < minDist) {
        minDist = d;
        nearest = list[i];
      }
    }
    return nearest;
  }

}