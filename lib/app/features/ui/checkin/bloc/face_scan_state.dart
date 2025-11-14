part of 'face_scan_cubit.dart';

class FaceScanState extends Equatable {
  final LoadStatus scanStatus;
  final FaceSearchResultEntity? faceResult;
  final bool isFaceValid;

  const FaceScanState({
    this.scanStatus = LoadStatus.INITIAL,
    this.isFaceValid = false,
    this.faceResult
  });

  FaceScanState copyWith({
    LoadStatus? scanStatus,
    bool? isFaceValid,
    FaceSearchResultEntity? faceResult
  }){
    return FaceScanState(
      scanStatus: scanStatus ?? this.scanStatus,
      isFaceValid: isFaceValid ?? this.isFaceValid,
      faceResult: faceResult ?? this.faceResult
    );
  }

  @override
  List<Object?> get props => [
    scanStatus,
    faceResult
  ];
}