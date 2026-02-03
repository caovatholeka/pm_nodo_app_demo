part of 'face_scan_cubit.dart';

class FaceScanState extends Equatable {
  final LoadStatus scanStatus;
  final FaceSearchResultEntity? faceResult;
  final bool isFaceValid;
  final String? fileImgPath;
  final String? scanMsg;

  const FaceScanState({
    this.scanStatus = LoadStatus.INITIAL,
    this.isFaceValid = false,
    this.faceResult,
    this.fileImgPath,
    this.scanMsg,
  });

  FaceScanState copyWith({
    LoadStatus? scanStatus,
    bool? isFaceValid,
    FaceSearchResultEntity? faceResult,
    String? fileImgPath,
    String? scanMsg
  }){
    return FaceScanState(
      scanStatus: scanStatus ?? this.scanStatus,
      isFaceValid: isFaceValid ?? this.isFaceValid,
      faceResult: faceResult ?? this.faceResult,
      fileImgPath: fileImgPath ?? this.fileImgPath,
      scanMsg: scanMsg ?? this.scanMsg
    );
  }

  @override
  List<Object?> get props => [
    scanStatus,
    faceResult,
    fileImgPath,
    scanMsg
  ];
}
