
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pm_app/app/core/helper/response_mapper.dart';
import 'package:pm_app/app/data/models/entities/schedule_entity.dart';
import 'package:pm_app/app/data/models/entities/work_trip_entity.dart';
import 'package:pm_app/app/data/models/param/create_work_trip_param.dart';
import 'package:pm_app/app/data/repositories/work_trip_repository.dart';
import 'package:uuid/uuid.dart';

import '../../../config/app_config.dart';
import '../../../core/helper/attach_file_helper.dart';
import '../../../core/logger/logger.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/local/attach_file.dart';
import '../../../data/models/entities/file_entity.dart';
import '../../../data/models/entities/leave_day_entity.dart';
import '../../../data/models/entities/user_entity.dart';
import '../../../data/models/enums/load_status.dart';
import '../../../data/repositories/upload_repository.dart';
import '../../widgets/snack_bar_message.dart';

part 'work_trip_state.dart';

class WorkTripCubit extends Cubit<WorkTripState> {
  UploadRepository uploadRepo;
  WorkTripRepository tripRepository;
  WorkTripCubit({
    required this.uploadRepo,
    required this.tripRepository
  }) : super(WorkTripState());

  getListWorkTrips() async{
    emit(state.copyWith(loadDataStatus: LoadStatus.LOADING));
    try{
      List<WorkTripEntity>? list;
      final res = await tripRepository.getListBusinessTrip();
      if(res.data != null){
        list = mapList(res.data, WorkTripEntity.fromJson);
        emit(state.copyWith(loadDataStatus: LoadStatus.SUCCESS,listWorkTrips: list));
      }

    }catch(e){
      logger.d(e);
      emit(state.copyWith(loadDataStatus: LoadStatus.FAILURE));
    }

  }

  void createNewWorkTrip() async {
    emit(state.copyWith(createStatus: LoadStatus.LOADING));
    List<int> userIds = [];
    for(UserEntity user in (state.currentUsers ?? [])){
      userIds.add(user.id ?? 0);
    }
    try{
      CreateWorkTripParam createParam = CreateWorkTripParam(
        employeeIds: userIds,
        note: state.note ?? "",
        address: state.address ?? "",
        needTicket: state.needTicket ?? false,
        needRoom: state.needRoom ?? false,
        schedules: state.listScheduleDays
      );

      logger.d("createParam :: ${createParam.toJson()}");

      final res = await tripRepository.createBusinessTrip(createParam);
      if((res.schedules ?? []).isNotEmpty){
        emit(state.copyWith(createStatus: LoadStatus.SUCCESS,errMsg: res.message));
      }else{
        emit(state.copyWith(createStatus: LoadStatus.FAILURE,errMsg: res.message));
      }

    }catch(e){
      logger.d(e);
      emit(state.copyWith(createStatus: LoadStatus.FAILURE));
    }
  }

  void getListUsers() async{
    try {
      final List<UserEntity>? list;
      final res = await tripRepository.getListEmployees(page: 1,limit: 200);
      if(res.data != null){
        list = mapList(res.data, UserEntity.fromJson);
        emit(state.copyWith(listUsers: list));
      }else{
        emit(state.copyWith(listUsers: []));
      }

    }catch(e){
      logger.d(e);
      emit(state.copyWith(listUsers: []));
    }
  }

  // date time
  void getNowTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat(AppConfig.dateTimeFormat).format(now);
    emit(state.copyWith(fromDate: formattedDate, fromDateTime: now));
  }

  void setFromDate(DateTime dateTime) {
    String formattedDate = DateFormat(AppConfig.birthdayReservedFormat).format(dateTime);
    emit(state.copyWith(fromDate: AppDateUtils.changeIso8601StringToDateTimeString(formattedDate), fromDateTime: dateTime));
  }

  void onChangeFromDate(String fromDate){
    emit(state.copyWith(fromDate: fromDate));
  }

  void setToDate(DateTime dateTime) {
    String formattedDate = DateFormat(AppConfig.birthdayReservedFormat).format(dateTime);
    emit(state.copyWith(toDate: AppDateUtils.changeIso8601StringToDateTimeString(formattedDate), toDateTime: dateTime));
  }

  void onChangeToDate(String toDate){
    emit(state.copyWith(toDate: toDate));
  }

  onChangeUser(String user){
    emit(state.copyWith(strUsers: user));
  }

  onChangeCurrentUsers(List<UserEntity> users){
    emit(state.copyWith(currentUsers: users));
  }

  onChangeAddress(String address){
    emit(state.copyWith(address: address));
  }

  onChangeNote(String note){
    emit(state.copyWith(note: note));
  }

  void onChangeListSchedulesDays(List<ScheduleEntity> list) async{
    emit(state.copyWith(listScheduleDays: []));
    emit(state.copyWith(listScheduleDays: list));
  }

  onChangeNeedTicket(){
    bool need = state.needTicket ?? false;
    emit(state.copyWith(needTicket: !need));
  }

  onChangeNeedRoom(){
    bool need = state.needRoom ?? false;
    emit(state.copyWith(needRoom: !need));
  }

  onchangeIsOverNight(){
    bool change = state.isOvernight ?? false;
    emit(state.copyWith(isOvernight: !change));
  }

  // browser file
  void warningTooManyFile() async {
    state.copyWith(errMsg: "Đã đạt số lượng file tối đa");
  }

  void warningTooLargeFile() async {
    state.copyWith(errMsg: "File dung lượng tối đa chỉ 10 MB");
  }

  void addFile(List<AttachFile>? files) async {
    if (files == null || files.isEmpty) return;
    emit(state.copyWith(addFileStatus: LoadStatus.LOADING));
    try {
      List<FileEntity> fileUploadInfo =
      await uploadRepo.uploadFiles(files[0].file!);
      if (fileUploadInfo != null && fileUploadInfo.isNotEmpty) {
        FileEntity fileUpload = fileUploadInfo[0];
        files[0].fileUpload = fileUpload;
      }

      List<AttachFile> results = []..addAll(state.files);
      results.add(files[0]);

      emit(state.copyWith(addFileStatus: LoadStatus.SUCCESS, files: results));
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(addFileStatus: LoadStatus.FAILURE));
    }
  }

  void addUploadedFile(List<FileEntity> files) async {
    emit(state.copyWith(addFileStatus: LoadStatus.LOADING));
    // try {
    List<AttachFile> results = state.files;
    if (files.isNotEmpty) {
      files.forEach((element) {
        var uuid = const Uuid();
        var id = uuid.v1();
        String? name = element.name ?? element.url?.split("/").last;

        /// tạo ra attach file để hiển thị trong danh sách đính kèm
        AttachFile file = AttachFile(
          id: id,
          name: name ?? '',
          urlPath: element.absoluteUrl,
          //path: value,
          mime: AttachFileHelper.shared.getMimeType(name ?? ''),
          fileUpload: element,
        );
        results.add(file);
      });
    }

    emit(state.copyWith(addFileStatus: LoadStatus.SUCCESS, files: results));
    // } catch (e) {
    //   logger.e(e);
    //   emit(state.copyWith(addFileStatus: LoadStatus.FAILURE));
    // }
  }

  void deleteFile(String id) {
    emit(state.copyWith(deleteFileStatus: LoadStatus.LOADING));
    try {
      List<AttachFile> results = state.files;
      if (results.isNotEmpty) {
        AttachFile file = results.where((element) {
          return element.id == id;
        }).first;
        if (file != null) results.remove(file);
      }

      emit(
          state.copyWith(deleteFileStatus: LoadStatus.SUCCESS, files: results));
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(deleteFileStatus: LoadStatus.FAILURE));
    }
  }

  void editFile({required AttachFile file, required String id}) {
    emit(state.copyWith(editFileStatus: LoadStatus.LOADING));
    try {
      List<AttachFile> results = state.files;
      if (results.isNotEmpty) {
        AttachFile file = results.where((element) {
          return element.id == id;
        }).first;
        if (file != null) {
          int pos = results.indexOf(file);
          if (pos != -1) results[pos] = file;
        }
      }
      emit(state.copyWith(editFileStatus: LoadStatus.SUCCESS, files: results));
    } catch (e) {
      logger.e(e);
      emit(state.copyWith(editFileStatus: LoadStatus.FAILURE));
    }
  }

}