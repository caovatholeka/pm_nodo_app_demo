part of 'face_scan_cubit.dart';

class FaceScanState extends Equatable {
  final LoadStatus scanStatus;
  final FaceSearchResultEntity? faceResult;
  final bool isFaceValid;
  final String? fileImgPath;
  final String? scanMsg;
  // Kết quả chấm công khi xác thực + chấm công thành công trong cùng luồng
  final CheckInOutEntity? checkInResult;

  const FaceScanState({
    this.scanStatus = LoadStatus.INITIAL,
    this.isFaceValid = false,
    this.faceResult,
    this.fileImgPath,
    this.scanMsg,
    this.checkInResult,
  });

  FaceScanState copyWith({
    LoadStatus? scanStatus,
    bool? isFaceValid,
    FaceSearchResultEntity? faceResult,
    String? fileImgPath,
    String? scanMsg,
    CheckInOutEntity? checkInResult,
  }){
    return FaceScanState(
      scanStatus: scanStatus ?? this.scanStatus,
      isFaceValid: isFaceValid ?? this.isFaceValid,
      faceResult: faceResult ?? this.faceResult,
      fileImgPath: fileImgPath ?? this.fileImgPath,
      scanMsg: scanMsg ?? this.scanMsg,
      checkInResult: checkInResult ?? this.checkInResult,
    );
  }

  @override
  List<Object?> get props => [
    scanStatus,
    isFaceValid,
    faceResult,
    fileImgPath,
    scanMsg,
    checkInResult,
  ];
}
