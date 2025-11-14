import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
        listCheckInfos: [],
        currentCheckInEntity: CheckInInfoEntity()
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
      // final response = await checkInRepository.searchCheckInStatus(param,20,0);
      // TeachingEntity? teachingEntity;
      //
      // if (response.data != null) {
      //   teachingEntity = mapObject(response.data, TeachingEntity.fromJson);
      // }
      //
      // // hiển thị thông tin tiết hiện tại hoặc gần nhất
      // CheckInInfoEntity? check =
      // getUpComingCheckEntity(teachingEntity?.content ?? []);
      //
      // logger.d("check ::: ${check?.toJson()}");
      // if(check != null){
      //   emit(state.copyWith(getCheckInfo: LoadStatus.SUCCESS,
      //       listCheckInfos: teachingEntity?.content,
      //       currentCheckInEntity: check));
      // }else{
      //   emit(state.copyWith(getCheckInfo: LoadStatus.SUCCESS,
      //       listCheckInfos: [],
      //       currentCheckInEntity: CheckInInfoEntity()));
      // }

    }catch(e,s){
      logger.d(e);
      logger.d(s);
      emit(state.copyWith(getCheckInfo: LoadStatus.FAILURE,
          listCheckInfos: [],currentCheckInEntity: null ));
    }
  }


  void doCheckInGps() async{
    logger.d("Check-In");
    emit(state.copyWith(checkInStatus: LoadStatus.LOADING));
  }

  void doCheckOutGps() async{
    logger.d("Check-Out");
    emit(state.copyWith(checkInStatus: LoadStatus.LOADING));

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
      nearest.latitude ?? 0.0, nearest.longtitude ?? 0.0,
    );

    for (int i = 1; i < list.length; i++) {
      final d = Geolocator.distanceBetween(
        state.position?.latitude ?? 0.0, state.position?.longitude ?? 0.0,
        list[i].latitude ?? 0.0, list[i].longtitude ?? 0.0,
      );
      if (d < minDist) {
        minDist = d;
        nearest = list[i];
      }
    }
    return nearest;
  }

}