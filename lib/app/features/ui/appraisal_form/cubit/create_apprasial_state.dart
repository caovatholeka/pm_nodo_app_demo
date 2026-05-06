part of 'create_apprasial_cubit.dart';

const Object _createApprasialErrorUnset = Object();

class CreateApprasialState extends Equatable {
  final LoadStatus loadDataStatus;
  final String? errorMessage;

  const CreateApprasialState({
    this.loadDataStatus = LoadStatus.INITIAL,
    this.errorMessage,
  });

  CreateApprasialState copyWith({LoadStatus? loadDataStatus,Object? errorMessage = _createApprasialErrorUnset,}) {
    return CreateApprasialState(
      loadDataStatus: loadDataStatus ?? this.loadDataStatus,
      errorMessage:
          identical(errorMessage, _createApprasialErrorUnset)
              ? this.errorMessage:errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    loadDataStatus,
    errorMessage,
  ];
}
