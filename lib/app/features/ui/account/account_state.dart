import 'package:equatable/equatable.dart';
import '../../../data/models/entities/profile_entity.dart';
import '../../../data/models/enums/load_status.dart';

class AccountState extends Equatable {
  final LoadStatus loadStatus;
  final ProfileEntity? profile;

  const AccountState({
    this.loadStatus = LoadStatus.INITIAL,
    this.profile,
  });

  AccountState copyWith({
    LoadStatus? loadStatus,
    ProfileEntity? profile,
  }) {
    return AccountState(
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [loadStatus, profile];
}

