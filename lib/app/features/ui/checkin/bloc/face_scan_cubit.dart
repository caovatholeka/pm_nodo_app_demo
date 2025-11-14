
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/global_data.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/face_search_result_entity.dart';
import 'package:pm_app/app/data/repositories/face_id_repository.dart';

import '../../../../data/models/entities/face_search_response_entity.dart';
import '../../../../data/models/enums/load_status.dart';
import '../../../../data/repositories/check_in_repository.dart';

part 'face_scan_state.dart';

class FaceScanCubit extends Cubit<FaceScanState> {
  FaceIdRepository faceIdRepository;

  FaceScanCubit({
    required this.faceIdRepository
  }) : super(FaceScanState());


  void onResetStatus(){
    emit(state.copyWith(scanStatus: LoadStatus.INITIAL
    ));
  }
  void searchFace(File file) async{
      emit(state.copyWith(scanStatus: LoadStatus.LOADING));

      try{
        FaceSearchResponseEntity res = await faceIdRepository.searchEmployeeFace(file);
        if(res.searchData != null && (res.searchData?.searchResults ?? []).isNotEmpty
          // && GlobalData.instance.userProfile?.id.toString() ==  (res.searchData?.searchResults ?? []).first.employeeId
        ){
          emit(state.copyWith(scanStatus: LoadStatus.SUCCESS,faceResult: (res.searchData?.searchResults ?? []).first));
        }else{
          emit(state.copyWith(scanStatus: LoadStatus.FAILURE,faceResult: FaceSearchResultEntity()));
        }
      }catch(e,s){
        logger.d(e);
        logger.d(s);
        emit(state.copyWith(scanStatus: LoadStatus.FAILURE));
      }
  }

  void updateFaceValid(bool valid) {
    if (state.isFaceValid != valid) {
      emit(state.copyWith(isFaceValid: valid));
    }
  }
}