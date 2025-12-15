part of 'justification_cubit.dart';

class JustificationState extends Equatable{
  final LoadStatus loadStatus;
  List<JustificationEntity>? listJustifications;

  JustificationState({
    this.loadStatus = LoadStatus.INITIAL,
    this.listJustifications,
  });

  JustificationState copyWith({
    LoadStatus? loadStatus,
    List<JustificationEntity>? listJustifications,
  }) {
    return JustificationState(
      loadStatus: loadStatus ?? this.loadStatus,
      listJustifications:  listJustifications ?? this.listJustifications,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    listJustifications,
  ];
}